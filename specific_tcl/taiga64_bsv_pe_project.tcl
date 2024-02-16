# Create instance: taiga_0, and set properties
set taiga_0 [ create_bd_cell -type ip -vlnv [dict get $cpu_vlnv $project_name] taiga_0 ]
set cpu_clk [get_bd_pins taiga_0/clk]

# Create interface connections
set axi_io_port [get_bd_intf_pins taiga_0/m_axi]
set axi_mem_port [get_bd_intf_pins taiga_0/m_axi_cache]

set ibram [get_bd_intf_pins taiga_0/instruction_bram]
set dbram [get_bd_intf_pins taiga_0/data_bram]

# Create port connections
connect_bd_net [get_bd_pins RVController_0/rv_rstn] [get_bd_pins taiga_0/rstn]
connect_bd_net [get_bd_ports CLK] [get_bd_pins dmem/clka]
connect_bd_net [get_bd_pins dmem/rsta] [get_bd_pins RVController_0/rv_reset]
connect_bd_net [get_bd_ports CLK] [get_bd_pins imem/clka]
connect_bd_net [get_bd_pins imem/rsta] [get_bd_pins RVController_0/rv_reset]


startgroup
set_property -dict [list CONFIG.Enable_32bit_Address {true} CONFIG.Use_Byte_Write_Enable {true} CONFIG.Byte_Size {8} CONFIG.Assume_Synchronous_Clk {true} CONFIG.Write_Width_A {64} CONFIG.Write_Depth_A [expr $lmem / 8] CONFIG.Read_Width_A {64} CONFIG.Write_Width_B {64} CONFIG.Read_Width_B {64} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Register_PortB_Output_of_Memory_Primitives {false} CONFIG.Use_RSTA_Pin {true} CONFIG.Use_RSTB_Pin {true} CONFIG.use_bram_block {Stand_Alone} CONFIG.EN_SAFETY_CKT {false}] [get_bd_cells dmem]
endgroup

startgroup
set_property -dict [list CONFIG.Enable_32bit_Address {true} CONFIG.Use_Byte_Write_Enable {true} CONFIG.Byte_Size {8} CONFIG.Assume_Synchronous_Clk {true} CONFIG.Write_Width_A {64} CONFIG.Write_Depth_A [expr $lmem / 8] CONFIG.Read_Width_A {64} CONFIG.Write_Width_B {64} CONFIG.Read_Width_B {64} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Register_PortB_Output_of_Memory_Primitives {false} CONFIG.Use_RSTA_Pin {true} CONFIG.Use_RSTB_Pin {true} CONFIG.use_bram_block {Stand_Alone} CONFIG.EN_SAFETY_CKT {false}] [get_bd_cells imem]
endgroup


proc create_specific_addr_segs {} {
  variable lmem
  # Create specific address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces taiga_0/m_axi] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
}

proc get_external_mem_addr_space {} {
  return [get_bd_addr_spaces taiga_0/m_axi_cache]
}

