# Create instance: swerv_eh2_0, and set properties
  set swerv_eh2_0 [ create_bd_cell -type ip -vlnv [dict get $cpu_vlnv $project_name] swerv_eh2_0 ]
  set cpu_clk [get_bd_pins swerv_eh2_0/clk]

  # Create interface connections
  connect_bd_intf_net [get_bd_intf_pins axi_mem_intercon_1/S00_AXI] [get_bd_intf_pins swerv_eh2_0/lsu_axi]
  set iaxi [get_bd_intf_pins swerv_eh2_0/ifu_axi]
  
  # create constant zero
  create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0
  set_property -dict [list CONFIG.CONST_VAL {0}] [get_bd_cells xlconstant_0]

  # create constant one
  create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1

  # debug_rst_l must rise before rst_l
  connect_bd_net [get_bd_pins xlconstant_1/dout] [get_bd_pins swerv_eh2_0/dbg_rst_l]
  
  # create 128 bit wide constant zero
  create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_2
  set_property -dict [list CONFIG.CONST_WIDTH {128} CONFIG.CONST_VAL {0}] [get_bd_cells xlconstant_2]

  # clock enables must rise at the very start
  connect_bd_net [get_bd_pins xlconstant_1/dout] [get_bd_pins swerv_eh2_0/lsu_bus_clk_en]
  connect_bd_net [get_bd_pins xlconstant_1/dout] [get_bd_pins swerv_eh2_0/dma_bus_clk_en]
  connect_bd_net [get_bd_pins xlconstant_1/dout] [get_bd_pins swerv_eh2_0/ifu_bus_clk_en]
  connect_bd_net [get_bd_pins xlconstant_1/dout] [get_bd_pins swerv_eh2_0/dbg_bus_clk_en]

  # jtag test clock to one
  connect_bd_net [get_bd_pins xlconstant_1/dout] [get_bd_pins swerv_eh2_0/jtag_tck]
  # jtag to zero
  connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins swerv_eh2_0/jtag_trst_n]
  connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins swerv_eh2_0/jtag_tdi]
  connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins swerv_eh2_0/jtag_tms]

  ## wide identifiers
  # core_id to zero
  connect_bd_net [get_bd_pins xlconstant_2/dout] [get_bd_pins swerv_eh2_0/core_id]
  # connect reset vector to zero
  connect_bd_net [get_bd_pins xlconstant_2/dout] [get_bd_pins swerv_eh2_0/rst_vec]
  #
  connect_bd_net [get_bd_pins xlconstant_2/dout] [get_bd_pins swerv_eh2_0/dccm_ext_in_pkt]
  connect_bd_net [get_bd_pins xlconstant_2/dout] [get_bd_pins swerv_eh2_0/iccm_ext_in_pkt]
  connect_bd_net [get_bd_pins xlconstant_2/dout] [get_bd_pins swerv_eh2_0/btb_ext_in_pkt]
  connect_bd_net [get_bd_pins xlconstant_2/dout] [get_bd_pins swerv_eh2_0/ic_data_ext_in_pkt]
  connect_bd_net [get_bd_pins xlconstant_2/dout] [get_bd_pins swerv_eh2_0/ic_tag_ext_in_pkt]
  connect_bd_net [get_bd_pins xlconstant_2/dout] [get_bd_pins swerv_eh2_0/timer_int]
  connect_bd_net [get_bd_pins xlconstant_2/dout] [get_bd_pins swerv_eh2_0/soft_int]
  connect_bd_net [get_bd_pins xlconstant_2/dout] [get_bd_pins swerv_eh2_0/extintsrc_req]

  # experimental
  connect_bd_net [get_bd_pins xlconstant_2/dout] [get_bd_pins swerv_eh2_0/nmi_int]
  connect_bd_net [get_bd_pins xlconstant_2/dout] [get_bd_pins swerv_eh2_0/nmi_vec]
  connect_bd_net [get_bd_pins xlconstant_2/dout] [get_bd_pins swerv_eh2_0/jtag_id]

  # delayed activation of rst_l
  connect_bd_net [get_bd_pins RVController_0/rv_rstn] [get_bd_pins swerv_eh2_0/rst_l]

  # connect mpc run requests to rst_n
  connect_bd_net [get_bd_pins xlconstant_1/dout] [get_bd_pins swerv_eh2_0/mpc_debug_run_req]
  connect_bd_net [get_bd_pins xlconstant_1/dout] [get_bd_pins swerv_eh2_0/mpc_reset_run_req]

  # connect i_cpu requests to zero
  connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins swerv_eh2_0/i_cpu_run_req]
  connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins swerv_eh2_0/i_cpu_halt_req]
  # connect halt request to constant zero
  connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins swerv_eh2_0/mpc_debug_halt_req]
  
  

  # scan mode and mbist mode to zero
  connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins swerv_eh2_0/scan_mode]
  connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins swerv_eh2_0/mbist_mode]

# Add debug module
# if 0 {
#   # Insert JTAG interface port and connect it to the core
#   create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:jtag_rtl:2.0 CoreJTAG
#   connect_bd_intf_net [get_bd_intf_ports CoreJTAG] [get_bd_intf_pins swerv_eh2_0/jtag]

#   create_bd_port -dir I -type rst JTAG_RST
#   set_property CONFIG.POLARITY ACTIVE_LOW [get_bd_ports JTAG_RST]
#   connect_bd_net [get_bd_ports JTAG_RST] [get_bd_pins swerv_eh2_0/jtag_trst_n]
# } else {
#   set tapasco_toolflow $::env(TAPASCO_HOME_TOOLFLOW)
#   set_property ip_repo_paths [concat [get_property ip_repo_paths [current_project]] $tapasco_toolflow/vivado/common/ip/DMI/] [current_project]
#   update_ip_catalog

#   create_bd_intf_port -mode Slave -vlnv esa.informatik.tu-darmstadt.de:user:DMI_rtl:1.0 DMI
#   connect_bd_intf_net [get_bd_intf_ports DMI] [get_bd_intf_pins swerv_eh2_0/DMI]
# }

proc create_specific_addr_segs {} {
  variable lmem
  # Create specific address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces swerv_eh2_0/lsu_axi] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
  create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces swerv_eh2_0/lsu_axi] [get_bd_addr_segs rv_dmem_ctrl/S_AXI/Mem0] SEG_rv_dmem_ctrl_Mem0
  create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces swerv_eh2_0/ifu_axi] [get_bd_addr_segs rv_imem_ctrl/S_AXI/Mem0] SEG_rv_imem_ctrl_Mem0
}

proc get_external_mem_addr_space {} {
  return [get_bd_addr_spaces swerv_eh2_0/lsu_axi]
}


