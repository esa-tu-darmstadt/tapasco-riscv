# Connections between controller, TaPaSCo, local memory, etc.
connect_bd_intf_net -intf_net AXIGate_0_maxi [get_bd_intf_pins AXIGate_0/maxi] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
connect_bd_intf_net [get_bd_intf_ports M_AXI] [get_bd_intf_pins dmaOffset/M_AXI]
connect_bd_intf_net -intf_net S_AXI_BRAM_1 [get_bd_intf_ports S_AXI_BRAM] [get_bd_intf_pins axi_interconnect_1/S00_AXI]
connect_bd_intf_net -intf_net S_AXI_CTRL_1 [get_bd_intf_ports S_AXI_CTRL] [get_bd_intf_pins AXIGate_0/saxi]
connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins RVController_0/saxi] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
connect_bd_intf_net -intf_net axi_interconnect_1_M00_AXI [get_bd_intf_pins axi_interconnect_1/M00_AXI] [get_bd_intf_pins ps_imem_ctrl/S_AXI]
connect_bd_intf_net -intf_net axi_interconnect_1_M01_AXI [get_bd_intf_pins axi_interconnect_1/M01_AXI] [get_bd_intf_pins ps_dmem_ctrl/S_AXI]

connect_bd_intf_net -intf_net ps_dmem_ctrl_BRAM_PORTA [get_bd_intf_pins dmem/BRAM_PORTB] [get_bd_intf_pins ps_dmem_ctrl/BRAM_PORTA]
connect_bd_intf_net -intf_net ps_imem_ctrl_BRAM_PORTA [get_bd_intf_pins imem/BRAM_PORTB] [get_bd_intf_pins ps_imem_ctrl/BRAM_PORTA]

lappend axi_mem_slaves [get_bd_intf_pins dmaOffset/S_AXI]

if {$maxi_ports == 2} {
	connect_bd_intf_net [get_bd_intf_ports M_AXI2] [get_bd_intf_pins dmaOffset2/M_AXI]
	lappend axi_mem_slaves [get_bd_intf_pins dmaOffset2/S_AXI]
}

if {[info exists axi_io_port]} {
	connect_bd_intf_net $axi_io_port [get_bd_intf_pins axi_interconnect_0/S01_AXI]
} {
	lappend axi_mem_slaves [get_bd_intf_pins axi_interconnect_0/S01_AXI]
}

if {[info exists dbram]} {
	connect_bd_intf_net $dbram [get_bd_intf_pins dmem/BRAM_PORTA]
} {
	lappend axi_mem_slaves [get_bd_intf_pins rv_dmem_ctrl/S_AXI]
	connect_bd_intf_net -intf_net rv_dmem_ctrl_BRAM_PORTA [get_bd_intf_pins dmem/BRAM_PORTA] [get_bd_intf_pins rv_dmem_ctrl/bram]
}
if {[info exists ibram]} {
	connect_bd_intf_net $ibram [get_bd_intf_pins imem/BRAM_PORTA]
} elseif {[info exists iaxi]} {
	connect_bd_intf_net [get_bd_intf_pins imem/BRAM_PORTA] [get_bd_intf_pins rv_imem_ctrl/bram]
	connect_bd_intf_net [get_bd_intf_pins rv_imem_ctrl/S_AXI] $iaxi
} {
	connect_bd_intf_net [get_bd_intf_pins imem/BRAM_PORTA] [get_bd_intf_pins rv_imem_ctrl/bram]
	lappend axi_mem_slaves [get_bd_intf_pins rv_imem_ctrl/S_AXI]
}

# configure and connect axi_mem_intercon_1
if {[llength $axi_mem_slaves] == 1} {
	puts "axi_mem_intercon_1 is unnecessary"
	delete_bd_objs [get_bd_cells axi_mem_intercon_1]
	connect_bd_intf_net $axi_mem_port [lindex $axi_mem_slaves]
} {
	set_property CONFIG.NUM_MI [llength $axi_mem_slaves] [get_bd_cells axi_mem_intercon_1]
	set ic_master_ports [get_bd_intf_pins -filter {VLNV == "xilinx.com:interface:aximm_rtl:1.0" && MODE == "Master"} -of_objects [get_bd_cells axi_mem_intercon_1]]
	for {set i 0} {$i < [llength $axi_mem_slaves]} {incr i} {
		connect_bd_intf_net [lindex $axi_mem_slaves $i] [lindex $ic_master_ports $i]
	}
}

# Configure data bus width (depending on risc-v core)
if {[info exists axi_mem_port]} {
	set cpu_dmem $axi_mem_port
} {
	set cpu_dmem [get_bd_intf_pins -of_objects [get_bd_intf_nets -of_objects [get_bd_intf_pins axi_mem_intercon_1/S00_AXI]] -filter {MODE == Master}]
}
set data_width [get_property CONFIG.DATA_WIDTH $cpu_dmem]
set addr_width [get_property CONFIG.ADDR_WIDTH $cpu_dmem]
puts "Configure data path to ${addr_width}-bit address width and ${data_width}-bit data width."
set_property CONFIG.BYTES_PER_WORD [expr $data_width / 8] [get_bd_cells dmaOffset]
set_property CONFIG.DATA_WIDTH $data_width [get_bd_intf_ports M_AXI]
set_property CONFIG.ADDRESS_WIDTH $addr_width [get_bd_cells dmaOffset]
set_property CONFIG.ADDR_WIDTH $addr_width [get_bd_intf_ports M_AXI]
if {$maxi_ports == 2} {
	set_property CONFIG.BYTES_PER_WORD [expr $data_width / 8] [get_bd_cells dmaOffset2]
	set_property CONFIG.DATA_WIDTH $data_width [get_bd_intf_ports M_AXI2]
	set_property CONFIG.ADDRESS_WIDTH $addr_width [get_bd_cells dmaOffset2]
	set_property CONFIG.ADDR_WIDTH $addr_width [get_bd_intf_ports M_AXI2]
}
set_property CONFIG.BYTES_PER_WORD [expr $data_width / 8] [get_bd_cells rv_dmem_ctrl]
set_property CONFIG.BYTES_PER_WORD [expr $data_width / 8] [get_bd_cells rv_imem_ctrl]
# keep second BRAM port in sync, otherwise problems with larger sizes
set_property CONFIG.DATA_WIDTH $data_width [get_bd_cells ps_dmem_ctrl]
set_property CONFIG.DATA_WIDTH $data_width [get_bd_cells ps_imem_ctrl]
