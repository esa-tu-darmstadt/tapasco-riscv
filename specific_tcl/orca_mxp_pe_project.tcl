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

# enable vector coprocessor port
set_property -dict [ list \
  CONFIG.VCP_ENABLE {2} \
] $orca_0

# add VectorBlox MXP vector processor to vcp port
set mxp [ create_bd_cell -type ip -vlnv vectorblox.com:ip:vectorblox_mxp mxp ]

set mxp_vl     [lindex $mxp_config 0]
set mxp_ml     [lindex $mxp_config 1]
set scratchpad [lindex $mxp_config 2]
puts "MXP is configured for $mxp_vl vector lanes, $mxp_ml memory lanes and $scratchpad KB scratchpad memory."
set_property -dict [list \
  CONFIG.C_INSTR_PORT_TYPE {3} \
  CONFIG.FIXED_POINT_SUPPORT {0} \
  CONFIG.VECTOR_LANES $mxp_vl \
  CONFIG.MEMORY_WIDTH_LANES $mxp_ml \
  CONFIG.SCRATCHPAD_KB $scratchpad \
] $mxp

connect_bd_intf_net $orca_0/vcp $mxp/vcp
lappend axi_mem_slaves [get_bd_intf_pins $mxp/S_AXI]
make_bd_intf_pins_external [get_bd_intf_pins $mxp/M_AXI]

lappend cpu_clk [get_bd_pins $mxp/core_clk]
create_bd_port -dir I clk_2x
connect_bd_net [get_bd_pins $mxp/core_clk_2x] [get_bd_ports clk_2x]
connect_bd_net [get_bd_pins RVController_0/rv_rstn] [get_bd_pins $mxp/aresetn]

proc create_specific_addr_segs {} {
  variable cache
  variable lmem
  # Create address segments
  if { $cache } {
    create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces orca_0/DC] [get_bd_addr_segs dmaOffset/S_AXI/reg0] SEG_dmaOffset_reg0
    create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces orca_0/DC] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
    create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces orca_0/DC] [get_bd_addr_segs rv_dmem_ctrl/S_AXI/Mem0] SEG_rv_dmem_ctrl_Mem0
    create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces orca_0/IC] [get_bd_addr_segs rv_imem_ctrl/S_AXI/Mem0] SEG_rv_imem_ctrl_Mem0
    create_bd_addr_seg -range 0x00010000 -offset 0x70000000 [get_bd_addr_spaces orca_0/DC] [get_bd_addr_segs mxp/S_AXI/SCRATCHPAD] SEG_mxp_SP
  } else {
    create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces orca_0/DUC] [get_bd_addr_segs dmaOffset/S_AXI/reg0] SEG_dmaOffset_reg0
    create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces orca_0/DUC] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
    create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces orca_0/DUC] [get_bd_addr_segs rv_dmem_ctrl/S_AXI/Mem0] SEG_rv_dmem_ctrl_Mem0
    create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces orca_0/IUC] [get_bd_addr_segs rv_imem_ctrl/S_AXI/Mem0] SEG_rv_imem_ctrl_Mem0
    create_bd_addr_seg -range 0x00010000 -offset 0x70000000 [get_bd_addr_spaces orca_0/DUC] [get_bd_addr_segs mxp/S_AXI/SCRATCHPAD] SEG_mxp_SP
  }
}
