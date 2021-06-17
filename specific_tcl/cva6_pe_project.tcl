  # constants
  global DMEM_BASE
  global DMEM_LENGTH
  global IMEM_BASE
  global IMEM_LENGTH
  global CLINT_BASE
  global CLINT_LENGTH
  global DEBUG_BASE
  global DEBUG_LENGTH

  set CLINT_BASE 0x13000000
  set CLINT_LENGTH 0x00000000000C0000
  set DEBUG_BASE 0x12000000
  set DEBUG_LENGTH 0x0000000000001000
  set IMEM_BASE	0x0000000000000000
  set IMEM_LENGTH	$lmem
  set DMEM_BASE	$IMEM_LENGTH
  set DMEM_LENGTH	$lmem
  # TODO
  # set DRAM_BASE 0xdeadbeef
  # set DRAM_LENGTH 0xdeadbeef

  # Create instance: cva6_0, and set properties
  set cva6_0 [ create_bd_cell -type ip -vlnv [dict get $cpu_vlnv $project_name] cva6_0 ]
  set cva6_timer_0 [ create_bd_cell -type ip -vlnv openhwgroup:cva6:cva6_timer:0.1 cva6_timer_0 ]
  set cva6_dm_0 [ create_bd_cell -type ip -vlnv openhwgroup:cva6:cva6_dm:0.1 cva6_dm_0 ]
  set cpu_clk [get_bd_pins cva6_0/clk_i]

  # TODO add to config & adjust ariane_top.sv
  # CONFIG.DRAM_BASE	{$DRAM_BASE}
  # CONFIG.DRAM_LENGTH {$DRAM_LENGTH}
  set_property -dict [list \
    CONFIG.CLINT_BASE	$CLINT_BASE \
    CONFIG.CLINT_LENGTH	$CLINT_LENGTH \
    CONFIG.DEBUG_BASE	$DEBUG_BASE \
    CONFIG.DEBUG_LENGTH	$DEBUG_LENGTH \
    CONFIG.DMEM_BASE	$DMEM_BASE \
    CONFIG.DMEM_LENGTH $DMEM_LENGTH \
    CONFIG.IMEM_BASE	$IMEM_BASE \
    CONFIG.IMEM_LENGTH	$IMEM_LENGTH \
  ] [get_bd_cells cva6_0]

  # Create interface connections
  #TODO this core has a single axi interface for both memories and peripherals
  set cva6_mem_splitter [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 cva6_mem_splitter ]
  set_property CONFIG.NUM_MI 3 [get_bd_cells /cva6_mem_splitter]
  set_property CONFIG.NUM_SI 2 [get_bd_cells /cva6_mem_splitter]

  # Axi masters
  connect_bd_intf_net [get_bd_intf_pins cva6_0/io_axi_mem] -boundary_type upper [get_bd_intf_pins cva6_mem_splitter/S00_AXI]
  connect_bd_intf_net [get_bd_intf_pins cva6_dm_0/axi_dm] -boundary_type upper [get_bd_intf_pins cva6_mem_splitter/S01_AXI]

  # Axi slaves
  connect_bd_intf_net -boundary_type upper [get_bd_intf_pins cva6_mem_splitter/M00_AXI] [get_bd_intf_pins cva6_timer_0/axi_timer]
  connect_bd_intf_net -boundary_type upper [get_bd_intf_pins cva6_mem_splitter/M01_AXI] [get_bd_intf_pins axi_mem_intercon_1/S00_AXI]
  #connect_bd_intf_net -boundary_type upper [get_bd_intf_pins cva6_mem_splitter/M02_AXI] [get_bd_intf_pins rv_imem_ctrl/S_AXI]
  # Connect clocks
  connect_bd_net [get_bd_ports CLK] [get_bd_pins cva6_mem_splitter/ACLK] [get_bd_pins cva6_mem_splitter/S00_ACLK] [get_bd_pins cva6_mem_splitter/M00_ACLK] [get_bd_pins cva6_mem_splitter/M01_ACLK] [get_bd_pins cva6_mem_splitter/M02_ACLK] [get_bd_pins cva6_mem_splitter/S01_ACLK]
  connect_bd_net [get_bd_pins rst_CLK_100M/interconnect_aresetn] [get_bd_pins cva6_mem_splitter/ARESETN]
  connect_bd_net [get_bd_pins rst_CLK_100M/peripheral_aresetn] [get_bd_pins cva6_mem_splitter/S00_ARESETN] [get_bd_pins cva6_mem_splitter/M00_ARESETN] [get_bd_pins cva6_mem_splitter/M01_ARESETN] [get_bd_pins cva6_mem_splitter/M02_ARESETN] [get_bd_pins cva6_mem_splitter/S01_ARESETN]

  # imem connection is done via the iaxi variable
  set iaxi [get_bd_intf_pins cva6_mem_splitter/M02_AXI]
  # This port is used to determine the address and data widths
  set axi_mem_port [get_bd_intf_pins cva6_0/io_axi_mem]

  # Create port connections
  connect_bd_net [get_bd_pins RVController_0/rv_rstn] [get_bd_pins cva6_0/rst_ni]

  set boot_addr_constant [create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 boot_addr_constant]
  set mhartid_constant [create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 mhartid_constant]

  set_property -dict [list CONFIG.CONST_WIDTH {64}] [get_bd_cells boot_addr_constant]
  set_property -dict [list CONFIG.CONST_VAL $IMEM_BASE] [get_bd_cells boot_addr_constant]

  set_property -dict [list CONFIG.CONST_WIDTH {64}] [get_bd_cells mhartid_constant]
  set_property -dict [list CONFIG.CONST_VAL {0x000000000000108B}] [get_bd_cells mhartid_constant]

  connect_bd_net [get_bd_pins boot_addr_constant/dout] [get_bd_pins cva6_0/boot_addr_i]
  connect_bd_net [get_bd_pins mhartid_constant/dout] [get_bd_pins cva6_0/hart_id_i]

  # Connect Timer
  connect_bd_net [get_bd_pins RVController_0/rv_rstn] [get_bd_pins cva6_timer_0/rst_ni]
  connect_bd_net [get_bd_ports CLK] [get_bd_pins cva6_timer_0/clk_i]
  connect_bd_net [get_bd_pins cva6_timer_0/ipi_o] [get_bd_pins cva6_0/ipi_i]
  connect_bd_net [get_bd_pins cva6_timer_0/timer_irq_o] [get_bd_pins cva6_0/time_irq_i]
  set test_mode_constant [create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 test_mode_constant]
  set_property -dict [list CONFIG.CONST_WIDTH {1}] [get_bd_cells test_mode_constant]
  set_property -dict [list CONFIG.CONST_VAL {0}] [get_bd_cells test_mode_constant]
  connect_bd_net [get_bd_pins test_mode_constant/dout] [get_bd_pins cva6_timer_0/testmode_i]

  # Connect Debug Module
  connect_bd_net [get_bd_pins RVController_0/rv_rstn] [get_bd_pins cva6_dm_0/rst_ni]
  connect_bd_net [get_bd_ports CLK] [get_bd_pins cva6_dm_0/clk_i]
  connect_bd_net [get_bd_pins cva6_dm_0/debug_req_core_o] [get_bd_pins cva6_0/debug_req_i]

#TODO handle unconnected pins:
# irq_i[1:0]
# ipi_i

# Add debug module
if 0 {
  # Insert JTAG interface port and connect it to the core
  create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:jtag_rtl:2.0 CoreJTAG
  connect_bd_intf_net [get_bd_intf_ports CoreJTAG] [get_bd_intf_pins cva6_0/jtag]

  create_bd_port -dir I -type rst JTAG_RST
  set_property CONFIG.POLARITY ACTIVE_LOW [get_bd_ports JTAG_RST]
  connect_bd_net [get_bd_ports JTAG_RST] [get_bd_pins cva6_0/jtag_trst_n]
} else {
  set tapasco_toolflow $::env(TAPASCO_HOME_TOOLFLOW)
  set_property ip_repo_paths [concat [get_property ip_repo_paths [current_project]] $tapasco_toolflow/vivado/common/ip/DMI/] [current_project]
  update_ip_catalog

  create_bd_intf_port -mode Slave -vlnv esa.informatik.tu-darmstadt.de:user:DMI_rtl:1.0 DMI
  connect_bd_intf_net [get_bd_intf_ports DMI] [get_bd_intf_pins cva6_dm_0/DMI]
}

proc create_specific_addr_segs {} {
  variable lmem
  variable DMEM_BASE
  variable DMEM_LENGTH
  variable IMEM_BASE
  variable IMEM_LENGTH
  variable CLINT_BASE
  variable CLINT_LENGTH
  variable DEBUG_BASE
  variable DEBUG_LENGTH
  

  # Create specific address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces cva6_0/io_axi_mem] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
  create_bd_addr_seg -range $DMEM_LENGTH -offset $DMEM_BASE [get_bd_addr_spaces cva6_0/io_axi_mem] [get_bd_addr_segs rv_dmem_ctrl/S_AXI/Mem0] SEG_rv_dmem_ctrl_Mem0
  create_bd_addr_seg -range $IMEM_LENGTH -offset $IMEM_BASE [get_bd_addr_spaces cva6_0/io_axi_mem] [get_bd_addr_segs rv_imem_ctrl/S_AXI/Mem0] SEG_rv_imem_ctrl_Mem0

  # Additional address sections for DM and timer
  # Timer
  create_bd_addr_seg -range $CLINT_LENGTH -offset $CLINT_BASE [get_bd_addr_spaces cva6_0/io_axi_mem] [get_bd_addr_segs cva6_timer_0/axi_timer/reg0] SEG_cva6_clint
  # DM
  create_bd_addr_seg -range $DEBUG_LENGTH -offset $DEBUG_BASE [get_bd_addr_spaces cva6_0/io_axi_mem] [get_bd_addr_segs cva6_dm_0/axi_dm/reg0] SEG_cva6_dm
}

proc get_external_mem_addr_space {} {
  return [get_bd_addr_spaces cva6_0/io_axi_mem]
}
