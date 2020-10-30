  # Create instance: VexRiscvAxi4_0, and set properties
  set picorv32_0 [ create_bd_cell -type ip -vlnv [dict get $cpu_vlnv $project_name] picorv32_0 ]
  set cpu_clk [get_bd_pins picorv32_0/clk]
  set_property -dict [list CONFIG.BARREL_SHIFTER {1} CONFIG.ENABLE_FAST_MUL {1} CONFIG.ENABLE_DIV {1} CONFIG.PROGADDR_IRQ {0x00100000} CONFIG.STACKADDR [expr {$lmem * 2}]] [get_bd_cells picorv32_0]

  set_property -dict [ list \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.MAX_BURST_LENGTH {1} \
 ] [get_bd_intf_pins /picorv32_0/mem_axi]

  # PicoRV32 only has one AXI master port, attach both memories to axi_mem_intercon_1
  connect_bd_intf_net [get_bd_intf_pins picorv32_0/mem_axi] [get_bd_intf_pins axi_mem_intercon_1/S00_AXI]

  # Create port connections
  connect_bd_net -net RVController_0_rv_rstn [get_bd_pins RVController_0/rv_rstn] [get_bd_pins picorv32_0/resetn]

  save_bd_design

proc create_specific_addr_segs {} {
  variable lmem
  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces picorv32_0/mem_axi] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
  create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces picorv32_0/mem_axi] [get_bd_addr_segs rv_dmem_ctrl/S_AXI/Mem0] SEG_rv_dmem_ctrl_Mem0
  create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces picorv32_0/mem_axi] [get_bd_addr_segs rv_imem_ctrl/S_AXI/Mem0] SEG_rv_imem_ctrl_Mem0
}

proc get_external_mem_addr_space {} {
  return [get_bd_addr_spaces picorv32_0/mem_axi]
}
