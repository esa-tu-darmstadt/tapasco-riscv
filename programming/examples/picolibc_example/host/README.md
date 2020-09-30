This folder contains the code running on the host. The file *picolibctest_host.c* contains the actual code. In *rv_stdio.h* some functions are provided which help you setting up and tearing down the buffers for stdin/stdout properly. Copy this folder to your host and use cmake to compile it. The program can be run afterwards using:

```
./picolibctest_host picolibctest.bin
```

with the binary file containing the compiled RISC-V code.
