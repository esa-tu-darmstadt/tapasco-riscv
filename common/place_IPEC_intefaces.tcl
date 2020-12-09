puts "starting to create IPEC requirments"


if { $ipec_ports } {
	
	puts "Starting ipec ports creation"
	
	#interfaces
	set STREAM_input [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 STREAM_input ]
	
	set STREAM_output [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 STREAM_output ]
	
	#increasing number of Masters on axi interface
	set_property -dict [list CONFIG.NUM_MI {6}] [get_bd_cells axi_mem_intercon_1]
	
	# Create instance: axi_mm2s_mapper_input, and set properties
	set axi_mm2s_mapper_input [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_mm2s_mapper:1.1 axi_mm2s_mapper_input ]
	set_property -dict [ list \
		CONFIG.INTERFACES {Both} \
		CONFIG.TDATA_NUM_BYTES {512} \
		CONFIG.ADDR_WIDTH {32} \
		CONFIG.DATA_WIDTH {32} \
	] $axi_mm2s_mapper_input
	 
	
	# Create instance: axi_mm2s_mapper_output, and set properties
	set axi_mm2s_mapper_output [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_mm2s_mapper:1.1 axi_mm2s_mapper_output ]
	set_property -dict [ list \
		CONFIG.INTERFACES {Both} \
		CONFIG.TDATA_NUM_BYTES {512} \
		CONFIG.ADDR_WIDTH {64} \
		CONFIG.DATA_WIDTH {64} \
		CONFIG.ID_WIDTH {6} \
	] $axi_mm2s_mapper_output
	
	
	# Create instance: rv_dmem_fifo, and set properties
	set rv_dmem_ctrl_fifo [ create_bd_cell -type ip -vlnv esa.cs.tu-darmstadt.de:axi:axi_ctrl:0.1 rv_dmem_ctrl_fifo ]
	set_property -dict [ list \
		CONFIG.BYTES_PER_WORD {4} \
		CONFIG.MEM_SIZE {16384} \
	] $rv_dmem_ctrl_fifo
	
	# Create instance: rv_dmem_ctrl2, and set properties
	set rv_dmem_ctrl_fifo2 [ create_bd_cell -type ip -vlnv esa.cs.tu-darmstadt.de:axi:axi_ctrl:0.1 rv_dmem_ctrl_fifo2 ]
	set_property -dict [ list \
		CONFIG.BYTES_PER_WORD {4} \
		CONFIG.MEM_SIZE {16384} \
	] $rv_dmem_ctrl_fifo2
	
	# Create instance: dmem1, and set properties
	set dmem_fifo [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 dmem_fifo ]
		set_property -dict [ list \
		CONFIG.Assume_Synchronous_Clk {true} \
		CONFIG.EN_SAFETY_CKT {false} \
		CONFIG.Enable_B {Use_ENB_Pin} \
		CONFIG.Memory_Type {True_Dual_Port_RAM} \
		CONFIG.Port_B_Clock {100} \
		CONFIG.Port_B_Enable_Rate {100} \
		CONFIG.Port_B_Write_Rate {50} \
		CONFIG.Use_RSTB_Pin {true} \
	] $dmem_fifo

	
	# Create connection
	connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_mem_intercon_1/M04_AXI] [get_bd_intf_pins axi_mm2s_mapper_output/S_AXI]
	connect_bd_intf_net [get_bd_intf_ports STREAM_output] [get_bd_intf_pins axi_mm2s_mapper_output/M_AXIS]
	connect_bd_intf_net [get_bd_intf_ports STREAM_input] [get_bd_intf_pins axi_mm2s_mapper_input/S_AXIS]
	connect_bd_intf_net [get_bd_intf_pins rv_dmem_ctrl_fifo/S_AXI] [get_bd_intf_pins axi_mm2s_mapper_input/M_AXI]
	connect_bd_intf_net [get_bd_intf_pins rv_dmem_ctrl_fifo/bram] [get_bd_intf_pins dmem_fifo/BRAM_PORTA]
	connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_mem_intercon_1/M05_AXI] [get_bd_intf_pins rv_dmem_ctrl_fifo2/S_AXI]
	connect_bd_intf_net [get_bd_intf_pins rv_dmem_ctrl_fifo2/bram] [get_bd_intf_pins dmem_fifo/BRAM_PORTB]
	
	#connecting clk and reset of interconnect
	connect_bd_net [get_bd_ports CLK] [get_bd_pins axi_mem_intercon_1/M04_ACLK]
	connect_bd_net [get_bd_ports CLK] [get_bd_pins axi_mem_intercon_1/M05_ACLK]
	connect_bd_net [get_bd_pins axi_mem_intercon_1/M05_ARESETN] [get_bd_pins rst_CLK_100M/peripheral_aresetn]
	connect_bd_net [get_bd_pins axi_mem_intercon_1/M04_ARESETN] [get_bd_pins rst_CLK_100M/peripheral_aresetn]
	
	# connecting clk and reset of AXI-Streaming output
	connect_bd_net [get_bd_ports CLK] [get_bd_pins axi_mm2s_mapper_output/aclk]
	connect_bd_net [get_bd_pins axi_mm2s_mapper_output/aresetn] [get_bd_pins rst_CLK_100M/peripheral_aresetn]
	
	# connecting clk and reset of BRAM (dmem_fifo)
	connect_bd_net [get_bd_pins rv_dmem_ctrl_fifo2/RST_N] [get_bd_pins rst_CLK_100M/peripheral_aresetn]
	connect_bd_net [get_bd_pins rv_dmem_ctrl_fifo/RST_N] [get_bd_pins rst_CLK_100M/peripheral_aresetn]
	
	connect_bd_net [get_bd_ports CLK] [get_bd_pins axi_mm2s_mapper_input/aclk]
	connect_bd_net [get_bd_pins axi_mm2s_mapper_input/aresetn] [get_bd_pins rst_CLK_100M/peripheral_aresetn]
	
	connect_bd_net [get_bd_ports CLK] [get_bd_pins rv_dmem_ctrl_fifo/CLK]
	connect_bd_net [get_bd_ports CLK] [get_bd_pins rv_dmem_ctrl_fifo2/CLK]
	
	# assigning addresses
	assign_bd_address -range 1M -offset 0x0003000000000000 [get_bd_addr_segs {axi_mm2s_mapper_output/S_AXI/Reg }]
	assign_bd_address -range 16K -offset 0x0000000000008000 [get_bd_addr_segs {rv_dmem_ctrl_fifo2/S_AXI/Mem0 }]
	assign_bd_address -range 16K -offset 0x00000000 [get_bd_addr_segs {rv_dmem_ctrl_fifo/S_AXI/Mem0 }]




	
	
	
} else {
	puts "IPEC port is not enable"
}

