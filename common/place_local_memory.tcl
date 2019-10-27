# Create instance: axi_interconnect_1, and set properties (minimize area)
  set axi_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_1 ]
  set_property CONFIG.STRATEGY {1} $axi_interconnect_1

  # Create instance: axi_mem_intercon_1, and set properties (maximize performance)
  set axi_mem_intercon_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon_1 ]
  # reduce NUM_MI later for direct bram connection
  set_property -dict [ list \
   CONFIG.NUM_MI {3} \
   CONFIG.NUM_SI {1} \
   CONFIG.STRATEGY {0} \
   CONFIG.ENABLE_ADVANCED_OPTIONS {1} \
   CONFIG.S00_HAS_DATA_FIFO {0} \
 ] $axi_mem_intercon_1

  # Create instance: dmem, and set properties
  set dmem [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 dmem ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {true} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
 ] $dmem

  # Create instance: imem, and set properties
  set imem [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 imem ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {true} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
 ] $imem
 
 # Create instance: ps_dmem_ctrl, and set properties
  set ps_dmem_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl ps_dmem_ctrl ]
  set_property -dict [ list \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $ps_dmem_ctrl

  # Create instance: ps_imem_ctrl, and set properties
  set ps_imem_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl ps_imem_ctrl ]
  set_property -dict [ list \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $ps_imem_ctrl

  # Create instance: rst_CLK_100M, and set properties
  set rst_CLK_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_CLK_100M ]

  # Create instance: rv_dmem_ctrl, and set properties
  set rv_dmem_ctrl [ create_bd_cell -type ip -vlnv esa.cs.tu-darmstadt.de:axi:axi_ctrl rv_dmem_ctrl ]
  set_property -dict [ list \
   CONFIG.MEM_SIZE [expr $lmem] \
 ] $rv_dmem_ctrl

  # Create instance: rv_imem_ctrl, and set properties
  set rv_imem_ctrl [ create_bd_cell -type ip -vlnv esa.cs.tu-darmstadt.de:axi:axi_ctrl rv_imem_ctrl ]
  set_property -dict [ list \
   CONFIG.MEM_SIZE [expr $lmem] \
   CONFIG.READ_ONLY {1} \
 ] $rv_imem_ctrl
