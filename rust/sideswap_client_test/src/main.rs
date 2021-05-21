use gdk_common::model::GDKRUST_json;
use gdk_common::session::Session;
use gdk_electrum::{ElectrumSession, NativeNotif};
use sideswap_api::*;
use sideswap_common::*;
use sideswap_libwally::*;
use std::collections::BTreeMap;
use std::ptr::null;
use std::time::Duration;
use types::Amount;

#[macro_use]
extern crate log;

const CLIENT_API_KEY: &str = "f8b7a12ee96aa68ee2b12ebfc51d804a4a404c9732652c298d24099a3d922a84";

extern "C" fn notification_callback(_context: *const libc::c_void, json: *const GDKRUST_json) {
    unsafe {
        let result = serde_json::to_string(&(*json).0).unwrap();
        println!("callback: {}", &result);
    }
}

const SERVER_REQUEST_TIMEOUT: std::time::Duration = std::time::Duration::from_secs(5);

enum Msg {
    Connected,
    Disconnected,
    Notification(Notification),
}

fn main() {
    std::env::set_var("RUST_LOG", "info");
    env_logger::init();

    let parsed_network = get_network(Env::Local);

    let url = gdk_electrum::determine_electrum_url_from_net(&parsed_network).unwrap();
    let db_root = "/tmp/gdk_test".to_owned();

    let mut session = ElectrumSession::new_session(parsed_network, &db_root, url).unwrap();

    session.connect(&serde_json::Value::Null).unwrap();
    session.notify = NativeNotif(Some((notification_callback, null())));

    let mnemonic = "conduct soccer bounce master spawn lend cruel certain wash cry easy awesome";
    let mnemonic = gdk_common::mnemonic::Mnemonic::from(mnemonic.to_owned());

    session.login(&mnemonic, None).unwrap();

    std::thread::sleep(Duration::from_millis(1000));

    info!("starting up");

    let (msg_tx, msg_rx) = std::sync::mpsc::channel::<Msg>();
    let env_data = types::env_data(sideswap_common::types::Env::Local);
    let (ws_tx, ws_rx) = ws::start(
        env_data.host.to_owned(),
        env_data.port.to_owned(),
        env_data.use_tls,
    );
    let current_request_id = std::sync::Arc::new(std::sync::atomic::AtomicI64::new(0));
    let (resp_tx, resp_rx) = std::sync::mpsc::channel::<Result<Response, Error>>();
    let current_request_id_copy = std::sync::Arc::clone(&current_request_id);

    let msg_tx_copy = msg_tx.clone();
    std::thread::spawn(move || {
        for msg in ws_rx {
            match msg {
                ws::WrappedResponse::Connected => {
                    msg_tx_copy.send(Msg::Connected).unwrap();
                }
                ws::WrappedResponse::Disconnected => {
                    msg_tx_copy.send(Msg::Disconnected).unwrap();
                }
                ws::WrappedResponse::Response(ResponseMessage::Response(
                    Some(RequestId::Int(request_id)),
                    response,
                )) => {
                    let pending_request_id =
                        current_request_id_copy.load(std::sync::atomic::Ordering::Relaxed);
                    if request_id != pending_request_id {
                        panic!(
                            "unexpected request_id response: {}, expecting: {}",
                            request_id, pending_request_id
                        );
                    }
                    resp_tx.send(response).unwrap();
                }
                ws::WrappedResponse::Response(ResponseMessage::Response(_, _)) => {
                    panic!("invalid request_id response");
                }
                ws::WrappedResponse::Response(ResponseMessage::Notification(notification)) => {
                    msg_tx_copy.send(Msg::Notification(notification)).unwrap();
                }
            }
        }
    });

    let send_request = |request: Request| -> Result<Response, Error> {
        current_request_id.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
        let request_id = current_request_id.load(std::sync::atomic::Ordering::Relaxed);
        ws_tx
            .send(ws::WrappedRequest::Request(RequestMessage::Request(
                RequestId::Int(request_id),
                request,
            )))
            .unwrap();
        resp_rx
            .recv_timeout(SERVER_REQUEST_TIMEOUT)
            .expect("request timeout")
    };

    macro_rules! send_request {
        ($t:ident, $value:expr) => {
            match send_request(Request::$t($value)) {
                Ok(Response::$t(value)) => Ok(value),
                Ok(_) => panic!("unexpected response type"),
                Err(error) => Err(error),
            }
        };
    }

    struct ActiveSwap {
        utxos: Vec<gdk_common::model::UnspentOutput>,
        change_amount: Amount,
        swap: Option<Swap>,
        keys: Option<PsbtKeys>,
    }

    let mut _assets = Vec::new();
    let mut swaps: BTreeMap<OrderId, ActiveSwap> = BTreeMap::new();

    loop {
        let msg = msg_rx.recv().unwrap();

        match msg {
            Msg::Connected => {
                info!("connected to server");

                send_request!(
                    LoginClient,
                    LoginClientRequest {
                        api_key: CLIENT_API_KEY.to_owned(),
                        cookie: None,
                        user_agent: "".into(),
                        version: "".into()
                    }
                )
                .expect("client login failed");

                _assets = send_request!(Assets, None)
                    .expect("loading assets failed")
                    .assets;

                let send_asset = "2684bbac0fa7ad544ec8eee43c35156346e5d641d24a4b9d5d8f183e3f2d8fb9";
                let recv_asset = "ac1775bb717c60a9a4adc3587bd166350e016938b1e34f4b8e2e490dfd03817a";
                let send_amount = Amount::from_sat(5400);

                let utxos = session
                    .get_unspent_outputs(&serde_json::Value::Null)
                    .unwrap();
                let send_utxos = utxos.0.get(send_asset).unwrap();

                let utxos_amount =
                    Amount::from_sat(send_utxos.iter().map(|v| v.satoshi).sum::<u64>() as i64);
                let change_amount: Amount = utxos_amount - send_amount;
                assert!(change_amount.to_sat() >= 0);

                let with_change = utxos_amount > send_amount;

                let rfq = MatchRfq {
                    send_asset: send_asset.to_owned(),
                    recv_asset: recv_asset.to_owned(),
                    send_amount: send_amount.to_sat(),
                    utxo_count: send_utxos.len() as i32,
                    with_change,
                };
                let response = send_request!(MatchRfq, MatchRfqRequest { rfq: rfq.clone() })
                    .expect("sending RFQ failed");

                swaps.insert(
                    response.order_id.clone(),
                    ActiveSwap {
                        change_amount,
                        utxos: send_utxos.clone(),
                        swap: None,
                        keys: None,
                    },
                );
                info!("sending quote succeed");
            }

            Msg::Disconnected => {
                warn!("disconnected from server");
            }

            Msg::Notification(notification) => match notification {
                Notification::RfqCreated(_) => {}
                Notification::RfqRemoved(_) => {}

                Notification::Swap(swap) => {
                    let order_id = &swap.order_id;
                    let active_swap = swaps.get_mut(&order_id).expect("swap must exists");
                    match &swap.state {
                        SwapState::ReviewOffer(offer) => {
                            info!("waiting user offer accept");
                            active_swap.swap = Some(offer.swap.clone());

                            send_request!(
                                Swap,
                                SwapRequest {
                                    order_id: order_id.clone(),
                                    action: SwapAction::Accept,
                                }
                            )
                            .expect("accepting swap failed");
                        }
                        SwapState::WaitPsbt => {
                            let sw = active_swap.swap.as_ref().expect("swap must be set");

                            let psbt_info = PsbtInfo {
                                send_asset: sw.send_asset.clone(),
                                recv_asset: sw.recv_asset.clone(),
                                recv_amount: sw.recv_amount,
                                change_amount: active_swap.change_amount.to_sat(),
                                utxos: active_swap.utxos.clone(),
                            };
                            let (psbt, keys) = generate_psbt(&session, &psbt_info).unwrap();

                            active_swap.keys = Some(keys);

                            send_request!(
                                Swap,
                                SwapRequest {
                                    order_id: swap.order_id.clone(),
                                    action: SwapAction::Psbt(psbt),
                                }
                            )
                            .expect("sending PSBT failed");
                        }
                        SwapState::WaitSign(psbt) => {
                            let keys = active_swap.keys.as_ref().unwrap();

                            let signed_psbt =
                                sign_psbt(&psbt, &session.wallet.as_ref().unwrap(), &keys).unwrap();

                            send_request!(
                                Swap,
                                SwapRequest {
                                    order_id: swap.order_id.clone(),
                                    action: SwapAction::Sign(signed_psbt),
                                }
                            )
                            .expect("sending signed PSBT failed");
                        }
                        SwapState::Failed(error) => {
                            info!("swap failed: {:?}", error);
                        }
                        SwapState::Done(txid) => {
                            info!("swap succeed, txid: {}", &txid);
                        }
                    }
                }
                _ => {}
            },
        }
    }
}
