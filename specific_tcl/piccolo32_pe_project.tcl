# Create instance: piccolo_0, and set properties
  set piccolo_0 [ create_bd_cell -type ip -vlnv [dict get $cpu_vlnv $project_name] piccolo_0 ]
  set cpu_clk [get_bd_pins piccolo_0/CLK]

  set jtag_version 0
  if {$jtag_version == 1} {
    set cpu_dmem_master master0
    set cpu_imem_master master1
  } else {
    set cpu_dmem_master cpu_dmem_master
    set cpu_imem_master cpu_imem_master
  }

  if 0 {
  set_property -dict [ list \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.MAX_BURST_LENGTH {1} \
 ] [get_bd_intf_pins /piccolo_0/$cpu_dmem_master]
 }

  set_property -dict [ list \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.MAX_BURST_LENGTH {1} \
 ] [get_bd_intf_pins /piccolo_0/$cpu_imem_master]

  # Create interface connections
  connect_bd_intf_net -intf_net piccolo_0_cpu_dmem_master [get_bd_intf_pins axi_mem_intercon_1/S00_AXI] [get_bd_intf_pins piccolo_0/$cpu_dmem_master]
  set iaxi [get_bd_intf_pins piccolo_0/$cpu_imem_master]
  
  # Create port connections
  connect_bd_net -net RVController_0_reqEN [get_bd_pins RVController_0/reqEN] [get_bd_pins piccolo_0/EN_cpu_reset_server_request_put]
  connect_bd_net -net RVController_0_resEN [get_bd_pins RVController_0/resEN] [get_bd_pins piccolo_0/EN_cpu_reset_server_response_get]
  connect_bd_net -net RVController_0_rv_rstn [get_bd_pins RVController_0/rv_rstn] [get_bd_pins piccolo_0/RST_N]
  connect_bd_net -net piccolo_0_RDY_cpu_reset_server_request_put [get_bd_pins RVController_0/reqRDY_req_rdy] [get_bd_pins piccolo_0/RDY_cpu_reset_server_request_put]
  connect_bd_net -net piccolo_0_RDY_cpu_reset_server_response_get [get_bd_pins RVController_0/resRDY_res_rdy] [get_bd_pins piccolo_0/RDY_cpu_reset_server_response_get]

  if {$jtag_version == 1} {
    # Connect JTAG interface to the outside
    create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:jtag_rtl:2.0 JTAG
    connect_bd_intf_net [get_bd_intf_ports JTAG] [get_bd_intf_pins piccolo_0/jtag]

    create_bd_port -dir O -type clk RTCK
    connect_bd_net [get_bd_ports RTCK] [get_bd_pins piccolo_0/CLK_jtag_tclk_out]
  } else {
    # Get IP definition of DMI
    set tapasco_toolflow $::env(TAPASCO_HOME_TOOLFLOW)
    set_property ip_repo_paths [concat [get_property ip_repo_paths [current_project]] $tapasco_toolflow/vivado/common/ip/DMI/] [current_project]
    update_ip_catalog

    # Connect DMI port to the outside
    create_bd_intf_port -mode Slave -vlnv esa.informatik.tu-darmstadt.de:user:DMI_rtl:1.0 DMI
    connect_bd_intf_net [get_bd_intf_ports DMI] [get_bd_intf_pins piccolo_0/DMI]
  }

proc create_specific_addr_segs {} {
  variable lmem
  set jtag_version 0
  if {$jtag_version == 1} {
    set cpu_dmem_master master0
    set cpu_imem_master master1
  } else {
    set cpu_dmem_master cpu_dmem_master
    set cpu_imem_master cpu_imem_master
  }
 
  # Create specific address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces piccolo_0/$cpu_dmem_master] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces piccolo_0/$cpu_dmem_master] [get_bd_addr_segs dmaOffset/S_AXI/reg0] SEG_dmaOffset_reg0
  create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces piccolo_0/$cpu_dmem_master] [get_bd_addr_segs rv_dmem_ctrl/S_AXI/Mem0] SEG_rv_dmem_ctrl_Mem0
  create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces piccolo_0/$cpu_imem_master] [get_bd_addr_segs rv_imem_ctrl/S_AXI/Mem0] SEG_rv_imem_ctrl_Mem0
}
