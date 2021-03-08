# Create instance: swerv_0, and set properties
  set swerv_0 [ create_bd_cell -type ip -vlnv [dict get $cpu_vlnv $project_name] swerv_0 ]
  set cpu_clk [get_bd_pins swerv_0/clk]

  # Create interface connections
  connect_bd_intf_net [get_bd_intf_pins axi_mem_intercon_1/S00_AXI] [get_bd_intf_pins swerv_0/lsu_axi]
  set iaxi [get_bd_intf_pins swerv_0/ifu_axi]
  
  # Create port connections
  connect_bd_net [get_bd_pins RVController_0/rv_rstn] [get_bd_pins swerv_0/rst_n]

# Add debug module
if 0 {
  # Insert JTAG interface port and connect it to the core
  create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:jtag_rtl:2.0 CoreJTAG
  connect_bd_intf_net [get_bd_intf_ports CoreJTAG] [get_bd_intf_pins swerv_0/jtag]

  create_bd_port -dir I -type rst JTAG_RST
  set_property CONFIG.POLARITY ACTIVE_LOW [get_bd_ports JTAG_RST]
  connect_bd_net [get_bd_ports JTAG_RST] [get_bd_pins swerv_0/jtag_trst_n]
} else {
  set tapasco_toolflow $::env(TAPASCO_HOME_TOOLFLOW)
  set_property ip_repo_paths [concat [get_property ip_repo_paths [current_project]] $tapasco_toolflow/vivado/common/ip/DMI/] [current_project]
  update_ip_catalog

  create_bd_intf_port -mode Slave -vlnv esa.informatik.tu-darmstadt.de:user:DMI_rtl:1.0 DMI
  connect_bd_intf_net [get_bd_intf_ports DMI] [get_bd_intf_pins swerv_0/DMI]
}

proc create_specific_addr_segs {} {
  variable lmem
  # Create specific address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces swerv_0/lsu_axi] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
  create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces swerv_0/lsu_axi] [get_bd_addr_segs rv_dmem_ctrl/S_AXI/Mem0] SEG_rv_dmem_ctrl_Mem0
  create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces swerv_0/ifu_axi] [get_bd_addr_segs rv_imem_ctrl/S_AXI/Mem0] SEG_rv_imem_ctrl_Mem0
}

proc get_external_mem_addr_space {} {
  return [get_bd_addr_spaces swerv_0/lsu_axi]
}
