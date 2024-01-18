#[allow(non_snake_case)]
#[allow(unused_imports)]
use ethers::prelude::*;
use async_std::task;
use tokio::task::spawn_blocking;

fn main() {
    task::block_on(async {
        // Wrap the Tokio-specific code in spawn_blocking
        let provider = spawn_blocking(|| {
            Provider::<Http>::connect("https://polygon-rpc.com")
        })
        .await
        .unwrap()
        .unwrap();

        let block_number = provider.get_block_number().await.unwrap();
        println!("Latest block number on Polygon: {:?}", block_number);
    });
}
