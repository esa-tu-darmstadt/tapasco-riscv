# TaPaSCo RISC-V
This repository contains everything necessary to use RISC-V processors as TaPaSCo Processing Elements (PEs). Feel free to file issues if 
you encounter any bugs.

## Project structure
The folder **IP** contains the PE controller and the processor IPs after these have been built. After a successful build the folder also contains the PEs as IP blocks.

The folder **riscv** contains all scripts required to download and package the RISC-V processors as IP-XACT cores.

The folder **programming** contains a C template that should assist new users in writing code for the PE processor. It also gets populated with examples.

The folder **common** contains TCL scripts which place and connect common components which are shared in all PEs, independent from the chosen processor.

The folder **specific_tcl** contains one TCL script per processor and places/connects the components which depend on the chosen processor, e.g. instantiate the correct IP and connect the memory busses.

## Dependencies
The project might work with other configurations, but it was tested with the following setup:
* Vivado 2018.3
* TaPaSCo 2019.10
* Git
* Bash

If you provide a setup with these components (and their own dependencies) the project should work fine.

## Currently available PEs
* [SpinalHDL's VexRiscv](https://github.com/SpinalHDL/VexRiscv)
* [VectorBlox' Orca](https://github.com/cahz/orca)
* [Bluespec Inc.'s Piccolo](https://github.com/bluespec/Piccolo) in RV32ACIMU configuration
* [Bluespec Inc.'s Flute](https://github.com/bluespec/Flute) in RV32ACIMU configuration
* [Western Digital's SweRV](https://github.com/westerndigitalcorporation/swerv_eh1)
* [Taiga](https://gitlab.com/sfu-rcl/Taiga)
* [PicoRV32](https://github.com/cliffordwolf/picorv32)

## Building and using a PE in TaPaSCo
First clone this repository.
You can build PEs for all platforms which are supported by TaPaSCo.
To build a PE for a certain RISC-V processor you can simply call:

`make PROCESSOR_pe`.

The Makefile then downloads the processor, builds an IP core for the processor (if not provided by the developer) and builds the PE. Each
PE is directly imported into TaPaSCo. The corresponding names of the processors can be taken from the following table.

##### Table 1: Processors
| Processor                  | Target       |
|----------------------------|--------------|
| SpinalHDL VexRiscv         | vexriscv_pe  |
| Vectorblox Orca            | orca_pe      |
| Bluespec Inc. Piccolo (32 Bit) | piccolo32_pe |
| Bluespec Inc. Flute (32 Bit) | flute32_pe |
| PicoRV32                   | picorv32_pe  |
| WDC's SweRV                | swerv_pe     |
| Taiga                      | taiga_pe     |

### Configuration parameters
You can configure the build of the PEs with several parameters. These can either work for all PEs or just for specific ones. You can find the configuration parameters in the following table

##### Table 2: Configuration Parameters
| Parameter | Effect | Applicable PEs | Default value |
|-----------|--------|----------------|---------------|
| BRAM_SIZE | Determines the size of one local memory block in B | all | 0x4000 |
| CACHE | Enables the instruction/data cache of the processor | ORCA | true |

So if you want to build a PE of the SpinalHDL VexRiscv processor, you would use `make vexriscv_pe`. Furthermore the size of the PE's local memory can be changed by providing
the parameter BRAM_SIZE to the `make` command. Please note that instruction and data memory are separate, so by providing BRAM_SIZE you provide the size of each of those, 
e.g. BRAM_SIZE=0x4000 makes a local memory size of 0x8000.

For more information on PE local memory please refer to the [documentation](https://github.com/esa-tu-darmstadt/tapasco/blob/master/documentation/pe-local-memories.md).

## Publications
Heinz, C., Lavan, Y., Hofmann, J., and Koch, A. (2019). A Catalog and In-Hardware Evaluation of Open-Source Drop-In Compatible RISC-V Softcore Processors. In *IEEE Proc. International Conference on ReConFigurable Computing and FPGAs (ReConFig)*. IEEE. 
