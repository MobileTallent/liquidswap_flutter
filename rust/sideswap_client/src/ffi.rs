use prost::Message;
use sideswap_common::types::Env;
use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::sync::mpsc::{Receiver, Sender};
use std::sync::Once;

pub mod proto {
    include!(concat!(env!("OUT_DIR"), "/sideswap.proto.rs"));
}

pub type ToMsg = proto::to::Msg;
pub type FromMsg = proto::from::Msg;

static INIT_LOGGER_FLAG: Once = Once::new();

pub struct StartParams {
    pub data_path: String,
}

pub struct Client {
    to_sender: Sender<ToMsg>,
    to_receiver: Option<Receiver<ToMsg>>,
    env: Env,
}

pub struct RecvMessage(Vec<u8>);

// Send pointers to Dart as u64 (even on 32-bit platforms)
pub type IntPtr = u64;

#[no_mangle]
pub extern "C" fn sideswap_client_create() -> IntPtr {
    let client = create();
    let client = Box::into_raw(client);
    client as IntPtr
}

#[no_mangle]
pub extern "C" fn sideswap_client_start(client: IntPtr, work_dir: *const c_char, dart_port: i64) {
    let client = unsafe { &mut *(client as *mut Client) };
    let work_dir = unsafe { std::ffi::CStr::from_ptr(work_dir) };
    let start_params = StartParams {
        data_path: work_dir.to_str().unwrap().to_owned(),
    };
    start(client, start_params, dart_port);
}

#[no_mangle]
pub extern "C" fn sideswap_send_request(client: IntPtr, data: *const u8, len: usize) {
    assert!(client != 0);
    assert!(data != std::ptr::null());
    let client = unsafe { &mut *(client as *mut Client) };
    let slice = unsafe { std::slice::from_raw_parts(data, len) };
    let to = proto::To::decode(slice).expect("message decode failed");
    let msg = to.msg.expect("empty to message");
    client
        .to_sender
        .send(msg)
        .expect("sending to message failed");
}

pub const SIDESWAP_BITCOIN: i32 = 1;
pub const SIDESWAP_ELEMENTS: i32 = 2;

#[no_mangle]
pub extern "C" fn sideswap_check_addr(client: IntPtr, addr: *const c_char, addr_type: i32) -> bool {
    assert!(client != 0);
    assert!(addr != std::ptr::null());
    let addr = unsafe { CStr::from_ptr(addr) }
        .to_str()
        .expect("invalid c-str");
    let client = unsafe { &mut *(client as *mut Client) };
    match addr_type {
        SIDESWAP_BITCOIN => check_bitcoin_address(client, addr),
        SIDESWAP_ELEMENTS => check_elements_address(client, addr),
        _ => panic!("unexpected type"),
    }
}

const INVALID_AMOUNT: i64 = i64::MIN;

#[no_mangle]
pub extern "C" fn sideswap_parse_bitcoin_amount(amount: *const c_char) -> i64 {
    let amount = unsafe { CStr::from_ptr(amount) }
        .to_str()
        .expect("invalid c-str");
    bitcoin::SignedAmount::from_str_in(amount, bitcoin::Denomination::Bitcoin)
        .map(|value| value.as_sat())
        .unwrap_or(INVALID_AMOUNT)
}

#[no_mangle]
pub extern "C" fn sideswap_parsed_amount_valid(amount: i64) -> bool {
    amount != INVALID_AMOUNT
}

#[no_mangle]
pub extern "C" fn sideswap_msg_ptr(msg: IntPtr) -> *const u8 {
    assert!(msg != 0);
    let msg = unsafe { &*(msg as *const RecvMessage) };
    msg.0.as_ptr()
}

#[no_mangle]
pub extern "C" fn sideswap_msg_len(msg: IntPtr) -> usize {
    assert!(msg != 0);
    let msg = unsafe { &*(msg as *const RecvMessage) };
    msg.0.len()
}

#[no_mangle]
pub extern "C" fn sideswap_msg_free(msg: IntPtr) {
    assert!(msg != 0);
    let msg = unsafe { Box::from_raw(msg as *mut RecvMessage) };
    std::mem::drop(msg);
}

#[no_mangle]
pub extern "C" fn sideswap_generate_mnemonic12() -> *mut c_char {
    let str = sideswap_libwally::generate_mnemonic12();
    let value = CString::new(str).unwrap();
    value.into_raw()
}

#[no_mangle]
pub extern "C" fn sideswap_verify_mnemonic(mnemonic: *const c_char) -> bool {
    let mnemonic = unsafe { CStr::from_ptr(mnemonic) };
    sideswap_libwally::verify_mnemonic(&mnemonic.to_str().unwrap())
}

#[no_mangle]
pub extern "C" fn sideswap_string_free(str: *mut c_char) {
    unsafe {
        CString::from_raw(str);
    }
}

#[cfg(target_os = "android")]
fn init_log() {
    let level = if cfg!(debug_assertions) {
        log::Level::Debug
    } else {
        log::Level::Info
    };
    android_logger::init_once(android_logger::Config::default().with_min_level(level));
}

#[cfg(not(target_os = "android"))]
fn init_log() {
    if cfg!(debug_assertions) && std::env::var_os("RUST_LOG").is_none() {
        std::env::set_var("RUST_LOG", "debug,hyper=info");
    }
    env_logger::init();
}

fn create() -> Box<Client> {
    INIT_LOGGER_FLAG.call_once(|| {
        init_log();
    });

    info!("started");

    let env = if cfg!(debug_assertions) {
        Env::Local
    } else {
        Env::Prod
    };

    let (to_sender, to_receiver) = std::sync::mpsc::channel::<ToMsg>();

    Box::new(Client {
        env,
        to_sender,
        to_receiver: Some(to_receiver),
    })
}

fn start(client: &mut Client, params: StartParams, dart_port: i64) {
    let env = client.env;
    let to_receiver = client.to_receiver.take().unwrap();
    let (from_sender, from_receiver) = std::sync::mpsc::channel::<FromMsg>();
    std::thread::spawn(move || {
        super::worker::start_processing(env, to_receiver, from_sender, params);
    });

    std::thread::spawn(move || {
        let port = allo_isolate::Isolate::new(dart_port);
        for msg in from_receiver {
            let from = proto::From { msg: Some(msg) };
            let mut buf = Vec::new();
            from.encode(&mut buf).expect("encoding message failed");
            let msg = std::boxed::Box::new(RecvMessage(buf));
            let msg_ptr = Box::into_raw(msg) as IntPtr;
            let result = port.post(msg_ptr);
            assert!(result == true);
        }
    });
}

fn check_bitcoin_address(client: &Client, addr: &str) -> bool {
    let addr = match addr.parse::<bitcoin::Address>() {
        Ok(a) => a,
        Err(_) => return false,
    };
    match client.env {
        Env::Local => addr.network == bitcoin::Network::Regtest,
        Env::Prod | Env::Staging => addr.network == bitcoin::Network::Bitcoin,
    }
}

fn check_elements_address(client: &Client, addr: &str) -> bool {
    let addr = match addr.parse::<elements::Address>() {
        Ok(v) => v,
        Err(_) => return false,
    };
    if !addr.is_blinded() {
        return false;
    }
    match client.env {
        Env::Local => *addr.params == elements::AddressParams::ELEMENTS,
        Env::Prod | Env::Staging => *addr.params == elements::AddressParams::LIQUID,
    }
}
