#![allow(non_snake_case)]
#![allow(unused)]

use dioxus::prelude::*;

fn main() {
    
    dioxus_web::launch(app);
}

fn app(cx: Scope) -> Element {
    render! {
        h1 { "h" }
    }
}