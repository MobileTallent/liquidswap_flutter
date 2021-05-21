use std::env;

fn main() {
    let wally_dir = env::var("WALLI_DIR").unwrap_or_else(|_| {
        let home_dir = env::var("HOME").unwrap();
        format!(
            "{}/distr/install/libwally/x86_64-unknown-linux-gnu/lib",
            &home_dir
        )
    });
    println!("cargo:rustc-link-lib=static=wallycore");
    println!("cargo:rustc-link-lib=static=secp256k1");
    println!("cargo:rustc-link-search=native={}", wally_dir);
}
