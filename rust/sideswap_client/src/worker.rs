use super::*;
use gdk_common::model::{GDKRUST_json, TransactionMeta};
use gdk_common::session::Session;
use gdk_electrum::{ElectrumSession, NativeNotif};
use sideswap_api::*;
use sideswap_common::*;
use sideswap_libwally::*;
use std::collections::{BTreeMap, BTreeSet, HashMap};
use std::sync::{
    mpsc::{Receiver, Sender},
    Mutex,
};
use types::Amount;
use types::Env;

const CLIENT_API_KEY: &str = "f8b7a12ee96aa68ee2b12ebfc51d804a4a404c9732652c298d24099a3d922a84";

const USER_AGENT: &str = "SideSwap.v2";

const COOKIE_FILE_NAME: &str = "sideswap.cookie";
const ASSETS_FILE_NAME: &str = "assets.json";

const SERVER_REQUEST_TIMEOUT: std::time::Duration = std::time::Duration::from_secs(5);
const SERVER_REQUEST_POOL_PERIOD: std::time::Duration = std::time::Duration::from_secs(1);

const RFQ_TIMEOUT: std::time::Duration = std::time::Duration::from_secs(10);

const BALANCE_MIN_BLOCK_HEIGHT: u32 = 1;

#[derive(Eq, PartialEq)]
enum PegDir {
    In,
    Out,
}

pub struct Wallet {
    session: ElectrumSession,
    sent_txs: BTreeSet<String>,
    last_balances: BTreeMap<String, Amount>,

    active_swap: Option<ActiveSwap>,
    psbt: Option<String>,
    psbt_keys: Option<PsbtKeys>,

    send_tx: Option<TransactionMeta>,
    external_peg: Option<ExternalPeg>,
    internal_peg: Option<InternalPeg>,
}

pub struct ServerResp(Option<RequestId>, Result<Response, Error>);

pub struct RfqResp(OrderId, Result<Offer, ()>);

#[derive(Hash, Ord, PartialOrd, Eq, PartialEq, Clone)]
pub enum AssetId {
    Bitcoin,
    Elements(String),
}

struct InternalPeg {
    send_amount: i64,
    recv_amount: i64,
    peg_tx: TransactionMeta,
}

struct ExternalPeg {
    order_id: OrderId,
    recv_addr: Option<String>,
}

pub struct Data {
    env: Env,
    assets: BTreeMap<AssetId, Asset>,
    assets_old: Vec<Asset>,
    tickers: BTreeMap<String, AssetId>,
    from_sender: Sender<ffi::FromMsg>,
    ws_sender: Sender<ws::WrappedRequest>,
    resp_receiver: Receiver<ServerResp>,
    rfq_receiver: Receiver<RfqResp>,
    params: ffi::StartParams,
    notif_context: *mut NotifContext,
    wallet: Option<Wallet>,
}

pub struct ActiveSwap {
    order_id: OrderId,
    tx_info: Swap,
    inputs: Vec<gdk_common::model::UnspentOutput>,
    total_utxos_amount: Amount,
    change_amount: Amount,
}

#[derive(Debug)]
enum Message {
    Ui(ffi::ToMsg),
    ServerConnected,
    ServerDisconnected,
    ServerNotification(Notification),
    Notif(serde_json::Value),
}

struct NotifContext(Mutex<Sender<serde_json::Value>>);

extern "C" fn notification_callback(context: *const libc::c_void, json: *const GDKRUST_json) {
    let context = unsafe { &*(context as *const NotifContext) };
    let json = unsafe { (*json).0.clone() };
    context.0.lock().unwrap().send(json).unwrap();
}

macro_rules! send_request {
    ($sender:expr, $t:ident, $value:expr) => {
        match $sender.send_request(Request::$t($value)) {
            Ok(Response::$t(value)) => Ok(value),
            Ok(_) => Err(anyhow!("unexpected response type")),
            Err(error) => Err(error),
        }
    };
}

fn timestamp_now() -> i64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_millis() as i64
}

impl Data {
    fn update_tx_list(&mut self) {
        if self.assets.is_empty() || self.wallet.is_none() {
            return;
        }
        let wallet = self.wallet.as_ref().expect("wallet must be set");
        let opt = gdk_common::model::GetTransactionsOpt {
            count: usize::MAX,
            ..gdk_common::model::GetTransactionsOpt::default()
        };
        let new_txs = wallet
            .session
            .get_transactions(&opt)
            .expect("getting transaction list failed")
            .0
            .into_iter()
            .filter(|tx| wallet.sent_txs.get(&tx.txhash).is_none())
            .map(|tx| {
                let balances = tx
                    .satoshi
                    .iter()
                    .filter_map(|(asset_id, balance)| {
                        // filter only known assets
                        self.assets
                            .get(&AssetId::Elements(asset_id.clone()))
                            .map(|asset| ffi::proto::Balance {
                                ticker: asset.ticker.clone(),
                                amount: balance.clone(),
                            })
                    })
                    .collect();
                let tx_copy = ffi::proto::Transaction {
                    txid: tx.txhash.clone(),
                    balances,
                    block_height: tx.block_height,
                    created_at: tx.created_at,
                    memo: tx.memo.clone(),
                };
                tx_copy
            })
            .collect::<Vec<_>>();
        let wallet = self.wallet.as_mut().expect("wallet must be set");
        for new_tx in new_txs.iter() {
            wallet.sent_txs.insert(new_tx.txid.clone());
        }
        let msg = ffi::proto::from::NewTx { txs: new_txs };
        self.from_sender
            .send(ffi::proto::from::Msg::NewTx(msg))
            .unwrap();
    }

    fn update_balances(&mut self) {
        if self.assets.is_empty() || self.wallet.is_none() {
            return;
        }
        let wallet = self.wallet.as_mut().expect("wallet must be set");
        let balances = wallet
            .session
            .get_unspent_outputs(&serde_json::Value::Null)
            .expect("getting unspent outputs failed");

        for (asset, utxos) in balances.0.into_iter() {
            let utxos = utxos
                .into_iter()
                .filter(|v| v.block_height >= BALANCE_MIN_BLOCK_HEIGHT)
                .collect::<Vec<_>>();
            let amount = utxos.iter().map(|utxo| utxo.satoshi as i64).sum();
            let asset = self.assets.get(&AssetId::Elements(asset));
            if let Some(asset) = asset {
                let last_amount = wallet.last_balances.get(&asset.ticker).cloned();
                if last_amount != Some(Amount::from_sat(amount)) {
                    let balance_copy = ffi::proto::Balance {
                        ticker: asset.ticker.clone(),
                        amount,
                    };
                    self.from_sender
                        .send(ffi::proto::from::Msg::BalanceUpdate(balance_copy))
                        .unwrap();
                    wallet
                        .last_balances
                        .insert(asset.ticker.clone(), Amount::from_sat(amount));
                }
            }
        }
    }

    fn cookie_path(&self) -> std::path::PathBuf {
        std::path::Path::new(&self.params.data_path).join(COOKIE_FILE_NAME)
    }
    fn assets_path(&self) -> std::path::PathBuf {
        std::path::Path::new(&self.params.data_path).join(ASSETS_FILE_NAME)
    }

    fn try_process_ws_connected(&mut self) -> Result<(), anyhow::Error> {
        info!("connected to server");
        let cookie = std::fs::read_to_string(self.cookie_path()).ok();
        let version = env!("CARGO_PKG_VERSION");

        let resp = send_request!(
            self,
            LoginClient,
            LoginClientRequest {
                api_key: CLIENT_API_KEY.into(),
                cookie,
                user_agent: USER_AGENT.to_owned(),
                version: version.to_owned(),
            }
        )?;

        if let Err(e) = std::fs::write(self.cookie_path(), &resp.cookie) {
            error!("can't write cookie: {}", &e);
        };

        let assets = send_request!(self, Assets, None)?.assets;
        if assets != self.assets_old {
            if let Err(e) = self.save_assets(&assets) {
                error!("can't save assets file: {}", &e);
            }
            self.register_assets(assets);
        }

        let server_status = send_request!(self, ServerStatus, None)?;
        self.process_server_status(server_status);

        self.update_balances();
        self.update_tx_list();

        Ok(())
    }

    fn process_ws_connected(&mut self) {
        if let Err(e) = self.try_process_ws_connected() {
            // TODO: Report login error
        }
    }

    fn process_ws_disconnected(&mut self) {
        warn!("disconnected from server");
    }

    fn process_server_status(&mut self, resp: ServerStatus) {
        let status_copy = ffi::proto::ServerStatus {
            min_peg_in_amount: resp.min_peg_in_amount,
            min_peg_out_amount: resp.min_peg_out_amount,
            server_fee_percent_peg_in: resp.server_fee_percent_peg_in,
            server_fee_percent_peg_out: resp.server_fee_percent_peg_out,
        };
        self.from_sender
            .send(ffi::proto::from::Msg::ServerStatus(status_copy))
            .unwrap();
    }

    fn process_swap_notification(&mut self, msg: SwapNotification) {
        // Check that we expect that notification
        match self.wallet.as_ref().and_then(|v| v.active_swap.as_ref()) {
            Some(v) if v.order_id == msg.order_id => v,
            _ => return,
        };
        match msg.state {
            SwapState::ReviewOffer(_) => unreachable!("must be already handled"),
            SwapState::WaitPsbt => self.swap_send_psbt(),
            SwapState::WaitSign(psbt) => self.swap_send_sign(psbt),
            SwapState::Failed(error) => self.swap_failed(error),
            SwapState::Done(txid) => self.swap_succeed(txid),
        }
    }

    fn cleanup_swaps(&mut self) {
        let wallet = self.wallet.as_mut().expect("wallet must be set");
        wallet.active_swap = None;
        wallet.psbt = None;
        wallet.psbt_keys = None;
        wallet.external_peg = None;
        wallet.internal_peg = None;
    }

    fn swap_send_psbt(&mut self) {
        let wallet = self.wallet.as_ref().expect("wallet must be set");
        let active_swap = wallet.active_swap.as_ref().expect("must be set");
        let tx_info = &active_swap.tx_info;

        let psbt_info = PsbtInfo {
            send_asset: tx_info.send_asset.clone(),
            recv_asset: tx_info.recv_asset.clone(),
            recv_amount: tx_info.recv_amount,
            change_amount: active_swap.change_amount.to_sat(),
            utxos: active_swap.inputs.clone(),
        };

        let (psbt, keys) = generate_psbt(&wallet.session, &psbt_info).unwrap();

        let swap_resp = send_request!(
            self,
            Swap,
            SwapRequest {
                order_id: active_swap.order_id.clone(),
                action: SwapAction::Psbt(psbt),
            }
        );
        if let Err(e) = swap_resp {
            // TODO: report swap error
        };
        let wallet = self.wallet.as_mut().expect("wallet must be set");
        wallet.psbt_keys = Some(keys);
    }

    fn swap_send_sign(&mut self, psbt: String) {
        let wallet = self.wallet.as_mut().expect("wallet must be set");
        let keys = wallet.psbt_keys.as_ref().unwrap();
        let signed_psbt =
            sideswap_libwally::sign_psbt(&psbt, &wallet.session.wallet.as_ref().unwrap(), &keys)
                .unwrap();
        let active_swap = wallet
            .active_swap
            .as_ref()
            .expect("active_order_id must be set")
            .clone();

        let order_id = active_swap.order_id.clone();
        let swap_resp = send_request!(
            self,
            Swap,
            SwapRequest {
                order_id,
                action: SwapAction::Sign(signed_psbt),
            }
        );
        if let Err(e) = swap_resp {
            // TODO: report swap error
        };
    }

    fn swap_failed(&mut self, error: SwapError) {
        let error = match error {
            SwapError::Cancelled => return,
            SwapError::Timeout => "timeout",
            SwapError::ServerError => "server error",
            SwapError::DealerError => "dealer error",
            SwapError::ClientError => "client error",
        };
        self.from_sender
            .send(ffi::proto::from::Msg::SwapFailed(error.to_owned()))
            .unwrap();

        self.cleanup_swaps();
    }

    fn swap_succeed(&mut self, txid: String) {
        let wallet = self.wallet.as_ref().expect("wallet must be set");
        let active_swap = wallet.active_swap.as_ref().expect("must be set");
        let created_at = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_millis() as i64;
        let swap_succeed = ffi::proto::from::Msg::SwapSucceed(ffi::proto::from::SwapSucceed {
            sent_amount: active_swap.tx_info.send_amount,
            recv_amount: active_swap.tx_info.recv_amount,
            txid,
            created_at,
            recv_addr: None,
        });
        self.from_sender.send(swap_succeed).unwrap();
        self.cleanup_swaps();
    }

    fn process_wallet_notif(&mut self, msg: serde_json::Value) {
        let msg = msg.as_object().expect("expected object notification");
        let event = msg
            .get("event")
            .expect("expected event filed")
            .as_str()
            .expect("expected string event");
        match event {
            "transaction" => {
                self.update_tx_list();
                self.update_balances();
            }
            _ => {}
        }
    }

    fn process_pegout_request_local(
        &mut self,
        req: ffi::proto::to::SwapRequest,
    ) -> Result<ffi::proto::from::SwapReview, anyhow::Error> {
        let tx_amount = req.send_amount.expect("amount must be set");
        let recv_addr = req.recv_addr.expect("recv_addr must be set");

        let request = Request::PegOut(PegOutRequest {
            mainchain_addr: recv_addr.clone(),
            send_amount: Some(tx_amount),
        });
        let resp = self.send_request(request);
        let resp = match resp {
            Ok(Response::PegOut(resp)) => resp,
            Ok(_) => bail!("unexpected server response"),
            Err(e) => bail!("server error: {}", e.to_string()),
        };

        let recv_amount = resp
            .recv_amount
            .ok_or_else(|| anyhow!("invalid response, recv_amount is not set"))?;
        let server_fee = tx_amount - recv_amount;
        ensure!(server_fee >= 0, "unexpected server_fee");

        let lbtc_asset_id = self.tickers.get(TICKER_LBTC).expect("unknown ticker");
        let lbtc_asset = self.assets.get(&lbtc_asset_id).expect("unknown asset");
        let amount = gdk_common::model::AddressAmount {
            address: resp.elements_addr.clone(),
            satoshi: tx_amount as u64,
            asset_tag: Some(lbtc_asset.asset_id.clone()),
        };
        let mut details = gdk_common::model::CreateTransaction {
            addressees: vec![amount],
            fee_rate: None,
            subaccount: None,
            send_all: None,
            previous_transaction: HashMap::new(),
            memo: None,
            utxos: None,
        };
        let wallet = self.wallet.as_mut().expect("wallet must be set");
        let peg_tx = wallet
            .session
            .create_transaction(&mut details)
            .map_err(|e| anyhow!("can't create tx: {}", e.to_string()))?;

        let network_fee = peg_tx.fee as i64;
        let send_amount = tx_amount + peg_tx.fee as i64;

        wallet.internal_peg = Some(InternalPeg {
            peg_tx,
            send_amount: tx_amount,
            recv_amount,
        });

        Ok(ffi::proto::from::SwapReview {
            send_asset: TICKER_LBTC.to_owned(),
            recv_asset: TICKER_BTC.to_owned(),
            created_at: resp.created_at,
            expires_at: resp.expires_at,
            recv_amount,
            send_amount,
            server_fee,
            network_fee,
        })
    }

    fn process_peg_request_external(
        &mut self,
        peg_dir: PegDir,
        req: ffi::proto::to::SwapRequest,
    ) -> Result<ffi::proto::from::SwapWaitTx, anyhow::Error> {
        let wallet = self.wallet.as_mut().expect("wallet must be set");
        let recv_addr_orig = req.recv_addr;
        let recv_addr = recv_addr_orig.clone().unwrap_or_else(|| {
            assert!(peg_dir == PegDir::In);
            wallet
                .session
                .get_receive_address(&serde_json::Value::Null)
                .expect("can't get new address")
                .address
        });
        let request = match peg_dir {
            PegDir::In => Request::PegIn(PegInRequest {
                elements_addr: recv_addr,
                send_amount: None,
            }),
            PegDir::Out => Request::PegOut(PegOutRequest {
                mainchain_addr: recv_addr,
                send_amount: None,
            }),
        };
        let resp = self.send_request(request);
        let (peg_addr, order_id) = match resp {
            Ok(Response::PegIn(resp)) => (resp.mainchain_addr, resp.order_id),
            Ok(Response::PegOut(resp)) => (resp.elements_addr, resp.order_id),
            Ok(_) => bail!("unexpected response"),
            Err(e) => bail!("peg request failed: {}", e.to_string()),
        };

        let status_request = match peg_dir {
            PegDir::In => Request::PegInStatus(PegInStatusRequest {
                order_id: order_id.clone(),
            }),
            PegDir::Out => Request::PegOutStatus(PegOutStatusRequest {
                order_id: order_id.clone(),
            }),
        };
        let status_resp = self.send_request(status_request);
        match status_resp {
            Ok(Response::PegInStatus(status)) => self.process_peg_status_update(status),
            Ok(Response::PegOutStatus(status)) => self.process_peg_status_update(status),
            Ok(_) => bail!("unexpected response"),
            Err(e) => bail!("status request failed: {}", e.to_string()),
        };

        let wallet = self.wallet.as_mut().expect("wallet must be set");
        wallet.external_peg = Some(ExternalPeg {
            order_id: order_id.clone(),
            recv_addr: recv_addr_orig.clone(),
        });

        Ok(ffi::proto::from::SwapWaitTx {
            peg_addr,
            recv_addr: recv_addr_orig,
        })
    }

    fn process_swap_request_atomic(
        &mut self,
        req: ffi::proto::to::SwapRequest,
    ) -> Result<ffi::proto::from::SwapReview, anyhow::Error> {
        let wallet = self.wallet.as_mut().expect("wallet must be set");
        let send_asset = match self.tickers.get(&req.send_ticker) {
            Some(AssetId::Elements(asset_id)) => asset_id.clone(),
            _ => panic!("unknown ticker"),
        };
        let recv_asset = match self.tickers.get(&req.recv_ticker) {
            Some(AssetId::Elements(asset_id)) => asset_id.clone(),
            _ => panic!("unknown ticker"),
        };
        let send_amount = req.send_amount.expect("send_amount must be set");

        let mut all_utxos = wallet
            .session
            .get_unspent_outputs(&serde_json::Value::Null)
            .unwrap();
        let asset_utxos = all_utxos
            .0
            .remove(&send_asset)
            .ok_or_else(|| anyhow!("not enough UTXO"))?;

        let mut asset_utxos = asset_utxos
            .into_iter()
            .filter(|v| v.block_height >= BALANCE_MIN_BLOCK_HEIGHT)
            .collect::<Vec<_>>();

        let utxo_amounts: Vec<_> = asset_utxos.iter().map(|v| v.satoshi as i64).collect();
        let total: i64 = utxo_amounts.iter().sum();
        ensure!(total >= send_amount, "not enough UTXO");

        let selected = types::select_utxo(utxo_amounts, send_amount);
        let selected_amount = selected.iter().cloned().sum();
        assert!(selected_amount >= send_amount);
        let mut selected_utxos = Vec::new();
        for amount in selected {
            let index = asset_utxos
                .iter()
                .position(|v| v.satoshi as i64 == amount)
                .expect("utxo must exists");
            let utxo = asset_utxos.swap_remove(index);
            selected_utxos.push(utxo);
        }

        let change_amount = selected_amount - send_amount;
        let with_change = change_amount != 0;

        let rfq = MatchRfq {
            send_asset: send_asset.clone(),
            send_amount: send_amount,
            recv_asset: recv_asset.clone(),
            utxo_count: selected_utxos.len() as i32,
            with_change,
        };

        // Drop old pending requests just in case
        while self.rfq_receiver.try_recv().is_ok() {}

        let rfq_resp = send_request!(self, MatchRfq, MatchRfqRequest { rfq: rfq.clone() });
        let rfq_resp = match rfq_resp {
            Ok(resp) => resp,
            Err(e) => bail!("request failed: {}", e.to_string()),
        };

        let rfq_result = self
            .rfq_receiver
            .recv_timeout(RFQ_TIMEOUT)
            .map_err(|_| anyhow!("RFQ timeout"))?;

        ensure!(
            rfq_result.0 == rfq_resp.order_id,
            "unexpected order_id in RFQ response"
        );
        let offer = rfq_result.1.map_err(|_| anyhow!("no RFQ received"))?;

        let wallet = self.wallet.as_mut().expect("wallet must be set");
        wallet.active_swap = Some(ActiveSwap {
            order_id: rfq_resp.order_id.clone(),
            tx_info: offer.swap.clone(),
            inputs: selected_utxos,
            total_utxos_amount: Amount::from_sat(selected_amount),
            change_amount: Amount::from_sat(change_amount),
        });

        Ok(ffi::proto::from::SwapReview {
            send_asset: req.send_ticker.clone(),
            recv_asset: req.recv_ticker.clone(),
            created_at: offer.created_at,
            expires_at: offer.expires_at,
            send_amount,
            recv_amount: offer.swap.recv_amount,
            network_fee: offer.swap.network_fee,
            server_fee: offer.swap.server_fee,
        })
    }

    fn process_swap_request(&mut self, req: ffi::proto::to::SwapRequest) {
        let result = if req.send_ticker == TICKER_LBTC && req.recv_ticker == TICKER_BTC {
            if req.send_amount.is_some() {
                self.process_pegout_request_local(req)
                    .map(|v| ffi::proto::from::Msg::SwapReview(v))
            } else {
                self.process_peg_request_external(PegDir::Out, req)
                    .map(|v| ffi::proto::from::Msg::SwapWaitTx(v))
            }
        } else if req.send_ticker == TICKER_BTC && req.recv_ticker == TICKER_LBTC {
            self.process_peg_request_external(PegDir::In, req)
                .map(|v| ffi::proto::from::Msg::SwapWaitTx(v))
        } else {
            self.process_swap_request_atomic(req)
                .map(|v| ffi::proto::from::Msg::SwapReview(v))
        };

        let result = result.unwrap_or_else(|e| {
            error!("request failed: {}", e.to_string());
            ffi::proto::from::Msg::SwapFailed(e.to_string())
        });

        self.from_sender.send(result).unwrap();
    }

    fn process_swap_cancel(&mut self) {
        let wallet = self.wallet.as_mut().expect("wallet must be set");
        if let Some(active_swap) = wallet.active_swap.take() {
            let _ = send_request!(
                self,
                Swap,
                SwapRequest {
                    order_id: active_swap.order_id,
                    action: SwapAction::Cancel,
                }
            );
        }

        self.cleanup_swaps();
    }

    fn process_swap_accept(&mut self) {
        let wallet = self.wallet.as_ref().expect("wallet must be set");
        if let Some(active_swap) = wallet.active_swap.as_ref() {
            // TODO: Handle errors
            let resp = send_request!(
                self,
                Swap,
                SwapRequest {
                    order_id: active_swap.order_id.clone(),
                    action: SwapAction::Accept,
                }
            );
        }

        let wallet = self.wallet.as_mut().expect("wallet must be set");
        if let Some(data) = wallet.internal_peg.as_ref() {
            let tx_detail_signed = wallet.session.sign_transaction(&data.peg_tx).unwrap();
            // TODO: Correctly process broadcast error
            let txid = wallet.session.send_transaction(&tx_detail_signed).unwrap();

            let peg_detected = ffi::proto::from::Msg::SwapSucceed(ffi::proto::from::SwapSucceed {
                sent_amount: data.send_amount,
                recv_amount: data.recv_amount,
                txid: txid,
                created_at: timestamp_now(),
                recv_addr: None,
            });
            self.from_sender.send(peg_detected).unwrap();
            self.cleanup_swaps();
        }
    }

    fn process_get_recv_address(&mut self) {
        let wallet = self.wallet.as_mut().expect("wallet must be set");
        let addr = wallet
            .session
            .get_receive_address(&serde_json::Value::Null)
            .expect("can't get new address")
            .address;
        let addr = ffi::proto::Address { addr };
        self.from_sender
            .send(ffi::proto::from::Msg::RecvAddress(addr))
            .unwrap();
    }

    fn create_tx(
        &mut self,
        req: ffi::proto::to::CreateTx,
    ) -> Result<i64, gdk_electrum::error::Error> {
        let wallet = self.wallet.as_mut().expect("wallet must be set");
        let asset_id = self
            .tickers
            .get(&req.balance.ticker)
            .expect("unknown ticker");
        let asset = self.assets.get(&asset_id).expect("unknown asset");
        let amount = gdk_common::model::AddressAmount {
            address: req.addr,
            satoshi: req.balance.amount as u64,
            asset_tag: Some(asset.asset_id.clone()),
        };
        let mut details = gdk_common::model::CreateTransaction {
            addressees: vec![amount],
            fee_rate: None,
            subaccount: None,
            send_all: None,
            previous_transaction: HashMap::new(),
            memo: None,
            utxos: None,
        };
        let tx_detail_unsigned = wallet.session.create_transaction(&mut details)?;
        let network_fee = tx_detail_unsigned.fee as i64;
        wallet.send_tx = Some(tx_detail_unsigned);
        Ok(network_fee)
    }

    fn send_tx(
        &mut self,
        req: ffi::proto::to::SendTx,
    ) -> Result<String, gdk_electrum::error::Error> {
        let wallet = self.wallet.as_mut().expect("wallet must be set");
        let tx_detail_unsigned = wallet.send_tx.take().expect("send tx must be set");
        let tx_detail_signed = wallet.session.sign_transaction(&tx_detail_unsigned)?;
        let txid = wallet.session.send_transaction(&tx_detail_signed)?;
        if let Err(e) = wallet.session.set_transaction_memo(&txid, &req.memo, 0) {
            error!("setting memo failed");
        }
        Ok(txid)
    }

    fn process_create_tx(&mut self, req: ffi::proto::to::CreateTx) {
        let result = match self.create_tx(req) {
            Ok(network_fee) => ffi::proto::from::create_tx_result::Result::NetworkFee(network_fee),
            Err(e) => ffi::proto::from::create_tx_result::Result::ErrorMsg(e.to_string()),
        };
        let send_result = ffi::proto::from::CreateTxResult {
            result: Some(result),
        };
        self.from_sender
            .send(ffi::proto::from::Msg::CreateTxResult(send_result))
            .unwrap();
    }

    fn process_send_tx(&mut self, req: ffi::proto::to::SendTx) {
        let result = match self.send_tx(req) {
            Ok(txid) => ffi::proto::from::send_result::Result::Txid(txid),
            Err(e) => ffi::proto::from::send_result::Result::ErrorMsg(e.to_string()),
        };
        let send_result = ffi::proto::from::SendResult {
            result: Some(result),
        };
        self.from_sender
            .send(ffi::proto::from::Msg::SendResult(send_result))
            .unwrap();
    }

    // logins

    fn process_login_request(&mut self, req: ffi::proto::to::Login) {
        debug!("process login request...");
        self.process_logout_request();

        let env_data = types::env_data(self.env);
        let electrum_env = match self.env {
            Env::Prod | Env::Staging => sideswap_libwally::Env::Prod,
            Env::Local => sideswap_libwally::Env::Local,
        };
        let parsed_network = get_network(electrum_env);

        let url = gdk_electrum::determine_electrum_url_from_net(&parsed_network).unwrap();

        let cache_path = std::path::Path::new(&self.params.data_path)
            .join(env_data.cache_name)
            .to_str()
            .expect("invalid cache_path")
            .to_owned();

        let mut session = ElectrumSession::new_session(parsed_network, &cache_path, url).unwrap();

        session.notify = NativeNotif(Some((
            notification_callback,
            self.notif_context as *const libc::c_void,
        )));

        session.connect(&serde_json::Value::Null).unwrap();

        let mnemonic = gdk_common::mnemonic::Mnemonic::from(req.mnemonic.to_owned());

        session.login(&mnemonic, None).unwrap();

        let wallet = Wallet {
            psbt: None,
            psbt_keys: None,
            session,
            sent_txs: BTreeSet::new(),
            last_balances: BTreeMap::new(),
            send_tx: None,
            active_swap: None,
            internal_peg: None,
            external_peg: None,
        };

        self.wallet = Some(wallet);

        self.update_tx_list();
        self.update_balances();
    }

    fn process_logout_request(&mut self) {
        debug!("process logout request...");
        self.wallet = None;
    }

    fn process_peg_status_update(&mut self, status: PegStatus) {
        let wallet = match self.wallet.as_mut() {
            Some(v) => v,
            None => return,
        };
        let external_peg = match wallet.external_peg.as_ref() {
            Some(v) => v,
            None => return,
        };
        let first_peg_tx = match status.list.first() {
            Some(v) => v,
            None => return,
        };
        if external_peg.order_id != status.order_id {
            return;
        }

        let peg_detected = ffi::proto::from::Msg::SwapSucceed(ffi::proto::from::SwapSucceed {
            sent_amount: first_peg_tx.amount,
            recv_amount: first_peg_tx.payout.unwrap_or_default(),
            txid: first_peg_tx.tx_hash.clone(),
            created_at: first_peg_tx.created_at,
            recv_addr: external_peg.recv_addr.clone(),
        });
        self.from_sender.send(peg_detected).unwrap();
        self.cleanup_swaps();
    }

    fn process_set_memo(&mut self, req: ffi::proto::to::SetMemo) {
        let wallet = self.wallet.as_mut().expect("wallet must be set");
        wallet
            .session
            .set_transaction_memo(&req.txid, &req.memo, 0)
            .expect("setting memo failed");
    }

    // message processing

    fn send_request(&self, request: Request) -> Result<Response, anyhow::Error> {
        let active_request_id = ws::next_request_id();
        self.ws_sender
            .send(ws::WrappedRequest::Request(RequestMessage::Request(
                active_request_id.clone(),
                request,
            )))
            .unwrap();

        let started = std::time::Instant::now();
        loop {
            let resp = self.resp_receiver.recv_timeout(SERVER_REQUEST_POOL_PERIOD);
            match resp {
                Ok(ServerResp(Some(request_id), result)) => {
                    if request_id != active_request_id {
                        warn!("discard old response");
                        continue;
                    }
                    return result.map_err(|e| anyhow!("response failed: {}", e.message));
                }
                Ok(ServerResp(None, _)) => {
                    // should not happen
                    bail!("request failed");
                }
                Err(_) => {
                    let spent_time = std::time::Instant::now().duration_since(started);
                    if spent_time > SERVER_REQUEST_TIMEOUT {
                        bail!("request timeout");
                    }
                }
            };
        }
    }

    fn process_ui(&mut self, msg: ffi::ToMsg) {
        match msg {
            ffi::proto::to::Msg::Login(req) => self.process_login_request(req),
            ffi::proto::to::Msg::Logout(_) => self.process_logout_request(),
            ffi::proto::to::Msg::SwapRequest(req) => self.process_swap_request(req),
            ffi::proto::to::Msg::SwapCancel(_) => self.process_swap_cancel(),
            ffi::proto::to::Msg::SwapAccept(_) => self.process_swap_accept(),
            ffi::proto::to::Msg::GetRecvAddress(_) => self.process_get_recv_address(),
            ffi::proto::to::Msg::CreateTx(req) => self.process_create_tx(req),
            ffi::proto::to::Msg::SendTx(req) => self.process_send_tx(req),
            ffi::proto::to::Msg::SetMemo(req) => self.process_set_memo(req),
        }
    }

    fn process_ws_notification(&mut self, notification: Notification) {
        match notification {
            Notification::PegInStatus(status) => self.process_peg_status_update(status),
            Notification::PegOutStatus(status) => self.process_peg_status_update(status),
            Notification::ServerStatus(resp) => self.process_server_status(resp),
            Notification::MatchRfq(_) => {}
            Notification::Swap(msg) => self.process_swap_notification(msg),
            Notification::SwapStatus(_) => {}
            Notification::RfqCreated(_) => {}
            Notification::RfqRemoved(_) => {}
        }
    }

    pub fn register_assets(&mut self, assets: Assets) {
        types::check_assets(self.env, &assets);

        for asset in assets {
            let asset_id = AssetId::Elements(asset.asset_id.clone());
            let asset_copy = ffi::proto::Asset {
                asset_id: asset.asset_id.clone(),
                name: asset.name.clone(),
                ticker: asset.ticker.clone(),
                icon: asset.icon.clone(),
                precision: asset.precision as u32,
            };

            self.assets.insert(asset_id.clone(), asset.clone());
            self.tickers.insert(asset.ticker.clone(), asset_id);

            self.from_sender
                .send(ffi::proto::from::Msg::NewAsset(asset_copy))
                .unwrap();
        }
    }

    pub fn load_assets(&mut self) -> Result<(), anyhow::Error> {
        let str = std::fs::read_to_string(self.assets_path())?;
        let assets = serde_json::from_str::<Assets>(&str)?;
        self.assets_old = assets.clone();
        self.register_assets(assets);
        Ok(())
    }

    pub fn save_assets(&self, assets: &Assets) -> Result<(), anyhow::Error> {
        let str = serde_json::to_string(&assets)?;
        std::fs::write(self.assets_path(), &str)?;
        Ok(())
    }
}

pub fn start_processing(
    env: Env,
    to_receiver: Receiver<ffi::ToMsg>,
    from_sender: Sender<ffi::FromMsg>,
    params: ffi::StartParams,
) {
    let env_data = types::env_data(env);
    let (msg_sender, msg_receiver) = std::sync::mpsc::channel::<Message>();
    let (resp_sender, resp_receiver) = std::sync::mpsc::channel::<ServerResp>();
    let (rfq_sender, rfq_receiver) = std::sync::mpsc::channel::<RfqResp>();
    let (ws_sender, ws_receiver) =
        ws::start(env_data.host.to_owned(), env_data.port, env_data.use_tls);

    let msg_sender_copy = msg_sender.clone();
    std::thread::spawn(move || {
        while let Ok(msg) = ws_receiver.recv() {
            match msg {
                ws::WrappedResponse::Connected => {
                    msg_sender_copy.send(Message::ServerConnected).unwrap();
                }
                ws::WrappedResponse::Disconnected => {
                    msg_sender_copy.send(Message::ServerDisconnected).unwrap();
                }
                ws::WrappedResponse::Response(ResponseMessage::Notification(
                    Notification::MatchRfq(rfq_update),
                )) if rfq_update.status == MatchRfqStatus::Expired => {
                    rfq_sender
                        .send(RfqResp(rfq_update.order_id, Err(())))
                        .unwrap();
                }
                ws::WrappedResponse::Response(ResponseMessage::Notification(
                    Notification::Swap(SwapNotification {
                        order_id,
                        state: SwapState::ReviewOffer(offer),
                    }),
                )) => {
                    rfq_sender.send(RfqResp(order_id, Ok(offer))).unwrap();
                }
                ws::WrappedResponse::Response(ResponseMessage::Notification(notif)) => {
                    msg_sender_copy
                        .send(Message::ServerNotification(notif))
                        .unwrap();
                }
                ws::WrappedResponse::Response(ResponseMessage::Response(req_id, result)) => {
                    resp_sender.send(ServerResp(req_id, result)).unwrap();
                }
            }
        }
    });

    let msg_sender_copy = msg_sender.clone();
    std::thread::spawn(move || {
        while let Ok(msg) = to_receiver.recv() {
            msg_sender_copy.send(Message::Ui(msg)).unwrap();
        }
    });

    let (notif_sender, notif_receiver) = std::sync::mpsc::channel::<serde_json::Value>();
    let msg_sender_copy = msg_sender.clone();
    std::thread::spawn(move || {
        while let Ok(msg) = notif_receiver.recv() {
            msg_sender_copy.send(Message::Notif(msg)).unwrap();
        }
    });
    let notif_context = Box::new(NotifContext(Mutex::new(notif_sender)));
    let notif_context = Box::into_raw(notif_context);

    let mut state = Data {
        assets: BTreeMap::new(),
        assets_old: Vec::new(),
        tickers: BTreeMap::new(),
        from_sender,
        ws_sender,
        params,
        notif_context,
        env,
        wallet: None,
        resp_receiver,
        rfq_receiver,
    };

    if let Err(e) = state.load_assets() {
        debug!("can't load assets: {}", &e);
    }

    while let Ok(a) = msg_receiver.recv() {
        match &a {
            Message::Ui(ffi::proto::to::Msg::Login(_)) => debug!("new msg: login request..."),
            _ => debug!("new msg: {:?}", &a),
        };

        match a {
            Message::Notif(msg) => state.process_wallet_notif(msg),
            Message::Ui(msg) => state.process_ui(msg),
            Message::ServerConnected => state.process_ws_connected(),
            Message::ServerDisconnected => state.process_ws_disconnected(),
            Message::ServerNotification(msg) => state.process_ws_notification(msg),
        }
    }
}
