  # Create instance: orca_0, and set properties
  set orca_0 [ create_bd_cell -type ip -vlnv [dict get $cpu_vlnv $project_name] orca_0 ]
  set orca_timer_0 [ create_bd_cell -type ip -vlnv vectorblox.com:orca:orca_timer orca_timer_0 ]
  set cpu_clk [get_bd_pins orca_0/clk]
  
  # Connect the timer to the processor
  if {[llength [get_bd_intf_pins orca_0/timer]] > 0} {
    connect_bd_intf_net [get_bd_intf_pins orca_timer_0/timer] [get_bd_intf_pins orca_0/timer]
  }
  connect_bd_net [get_bd_pins orca_timer_0/reset] [get_bd_pins RVController_0/rv_reset]
  connect_bd_net [get_bd_ports CLK] [get_bd_pins orca_timer_0/clk]

  # Prepare instruction memory controller
  if { $cache } {
    set_property CONFIG.AXI_PROTOCOL {AXI4} [get_bd_cells rv_imem_ctrl]
  } else {
    set_property CONFIG.AXI_PROTOCOL {AXI4LITE} [get_bd_cells rv_imem_ctrl]
  }

  # Create port connections
  connect_bd_net -net RVController_0_rv_reset [get_bd_pins RVController_0/rv_reset] [get_bd_pins orca_0/reset]

  if { $cache } {
    set_property -dict [ list \
      CONFIG.ENABLE_EXCEPTIONS {0} \
      CONFIG.PIPELINE_STAGES {5} \
      CONFIG.ICACHE_SIZE {32768} \
      CONFIG.DCACHE_SIZE {32768} \
      CONFIG.DCACHE_WRITEBACK {0} \
      CONFIG.UC_MEMORY_REGIONS {0} \
    ] $orca_0
    set iaxi [get_bd_intf_pins orca_0/IC]
    connect_bd_intf_net [get_bd_intf_pins orca_0/DC] -boundary_type upper [get_bd_intf_pins axi_mem_intercon_1/S00_AXI]
  } else {
    set_property -dict [ list \
      CONFIG.ENABLE_EXCEPTIONS {0} \
      CONFIG.PIPELINE_STAGES {5} \
      CONFIG.AUX_MEMORY_REGIONS {0} \
      CONFIG.ICACHE_SIZE {0} \
      CONFIG.INSTRUCTION_REQUEST_REGISTER {1} \
      CONFIG.UC_MEMORY_REGIONS {1} \
    ] $orca_0
    connect_bd_intf_net -intf_net orca_0_DUC [get_bd_intf_pins orca_0/DUC] [get_bd_intf_pins axi_mem_intercon_1/S00_AXI]
    set iaxi [get_bd_intf_pins orca_0/IUC]
  }

proc create_specific_addr_segs {} {
  variable cache
  variable lmem
  # Create address segments
  if { $cache } {
    create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces orca_0/DC] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
    create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces orca_0/DC] [get_bd_addr_segs rv_dmem_ctrl/S_AXI/Mem0] SEG_rv_dmem_ctrl_Mem0
    create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces orca_0/IC] [get_bd_addr_segs rv_imem_ctrl/S_AXI/Mem0] SEG_rv_imem_ctrl_Mem0
  } else {
    create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces orca_0/DUC] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
    create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces orca_0/DUC] [get_bd_addr_segs rv_dmem_ctrl/S_AXI/Mem0] SEG_rv_dmem_ctrl_Mem0
    create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces orca_0/IUC] [get_bd_addr_segs rv_imem_ctrl/S_AXI/Mem0] SEG_rv_imem_ctrl_Mem0
  }
}

proc get_external_mem_addr_space {} {
  variable cache
  if { $cache } {
    return [get_bd_addr_spaces orca_0/DC]
  } else {
    return [get_bd_addr_spaces orca_0/DUC]
  }
}
