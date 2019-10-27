  # Create instance: flute32_0, and set properties
  set flute32_0 [ create_bd_cell -type ip -vlnv [dict get $cpu_vlnv $project_name] flute32_0 ]
  set cpu_clk [get_bd_pins flute32_0/CLK]
  set_property -dict [ list \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.MAX_BURST_LENGTH {1} \
 ] [get_bd_intf_pins /flute32_0/cpu_dmem_master]

  set_property -dict [ list \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.MAX_BURST_LENGTH {1} \
 ] [get_bd_intf_pins /flute32_0/cpu_imem_master]

  # Create interface connections
  connect_bd_intf_net -intf_net flute32_0_dmem_master [get_bd_intf_pins axi_mem_intercon_1/S00_AXI] [get_bd_intf_pins flute32_0/cpu_dmem_master]
  set iaxi [get_bd_intf_pins flute32_0/cpu_imem_master]

  # Create port connections
  connect_bd_net -net RVController_0_reqEN [get_bd_pins RVController_0/reqEN] [get_bd_pins flute32_0/EN_cpu_reset_server_request_put]
  connect_bd_net -net RVController_0_resEN [get_bd_pins RVController_0/resEN] [get_bd_pins flute32_0/EN_cpu_reset_server_response_get]
  connect_bd_net -net RVController_0_rv_rstn [get_bd_pins RVController_0/rv_rstn] [get_bd_pins flute32_0/RST_N]
  connect_bd_net -net flute32_0_RDY_cpu_reset_server_request_put [get_bd_pins RVController_0/reqRDY_req_rdy] [get_bd_pins flute32_0/RDY_cpu_reset_server_request_put]
  connect_bd_net -net flute32_0_RDY_cpu_reset_server_response_get [get_bd_pins RVController_0/resRDY_res_rdy] [get_bd_pins flute32_0/RDY_cpu_reset_server_response_get]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces flute32_0/cpu_dmem_master] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces flute32_0/cpu_dmem_master] [get_bd_addr_segs dmaOffset/S_AXI/reg0] SEG_dmaOffset_reg0
  create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces flute32_0/cpu_dmem_master] [get_bd_addr_segs rv_dmem_ctrl/S_AXI/Mem0] SEG_rv_dmem_ctrl_Mem0
  create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces flute32_0/cpu_imem_master] [get_bd_addr_segs rv_imem_ctrl/S_AXI/Mem0] SEG_rv_imem_ctrl_Mem0
