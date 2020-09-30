This folder contains the code running on the RISC-V core. You need to set the size of the instruction memory by setting the variable SIZE when calling make. This example code needs at least a size of 0x6000 to be compilable. SIZE must match the BRAM_SIZE you used to build your PE. With the STACK_SIZE option you can specify how much space is reserved for the stack by picolibc (default is 1K). Also, if you use the riscv32 compiler you need to pass GCC_VERSION=riscv32 to your make command which could end up like this:

```
make SIZE=0x6000 STACK_SIZE=2K GCC_VERSION=riscv32
```

Copy the compiled binary in the *bin/* folder to your device and pass it as the first argument to the host software.
