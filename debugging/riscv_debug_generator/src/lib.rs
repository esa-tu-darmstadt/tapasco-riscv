extern crate capnp;
extern crate capnpc;
extern crate tapasco;
extern crate snafu;
#[macro_use]
extern crate getset;

mod tapasco_riscv_capnp {
    #![allow(dead_code)]
    include!("../schema/tapasco_riscv_capnp.rs");
}
pub mod riscv_debug_generator;

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}

