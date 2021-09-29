# Create interface ports
  set M_AXI [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.PROTOCOL {AXI4} \
   ] $M_AXI

if {$maxi_ports == 2} {
    set M_AXI2 [create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI2]
    set_property -dict [ list \
      CONFIG.ADDR_WIDTH {32} \
      CONFIG.DATA_WIDTH {32} \
      CONFIG.PROTOCOL {AXI4} \
    ] $M_AXI2
}

for { set i 0 } { $i < $stream_ports } { incr i } {
	set data_width [get_property CONFIG.DATA_WIDTH $cpu_dmem]
	set idx [format "%02d" $i]
    set S_AXIS [create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S${idx}_AXIS]
	set_property -dict [ list \
      CONFIG.TDATA_NUM_BYTES [expr $data_width / 8] \
    ] $S_AXIS
    set M_AXIS [create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M${idx}_AXIS]
	set_property -dict [ list \
      CONFIG.TDATA_NUM_BYTES [expr $data_width / 8] \
    ] $M_AXIS
}

  set S_AXI_BRAM [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_BRAM ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH [expr log10($lmem*2)/log10(2)] \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S_AXI_BRAM
  set S_AXI_CTRL [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_CTRL ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {16} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {1} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S_AXI_CTRL

  # Create ports
  set ARESET_N [ create_bd_port -dir I -type rst ARESET_N ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $ARESET_N
  set CLK [ create_bd_port -dir I -type clk CLK ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S_AXI_BRAM:S_AXI_CTRL:M_AXI} \
 ] $CLK
  set interrupt [ create_bd_port -dir O -type intr interrupt ]

  # Create instance: AXIGate_0, and set properties
  set AXIGate_0 [ create_bd_cell -type ip -vlnv esa.informatik.tu-darmstadt.de:tapasco:AXIGate:1.0 AXIGate_0 ]
  set_property -dict [ list \
   CONFIG.threshold {0x00004000} \
 ] $AXIGate_0

  set_property -dict [ list \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.MAX_BURST_LENGTH {1} \
 ] [get_bd_intf_pins /AXIGate_0/maxi]

  set_property -dict [ list \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.MAX_BURST_LENGTH {1} \
 ] [get_bd_intf_pins /AXIGate_0/saxi]

  # Create instance: RVController_0, and set properties
  set RVController_0 [ create_bd_cell -type ip -vlnv esa.informatik.tu-darmstadt.de:user:RVController RVController_0 ]

  set_property -dict [ list \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.MAX_BURST_LENGTH {1} \
 ] [get_bd_intf_pins /RVController_0/saxi]

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI [expr 1 + $stream_ports] \
   CONFIG.NUM_SI {2} \
 ] $axi_interconnect_0

# Create instances: AXIMMStreamAdapter
for { set i 0 } { $i < $stream_ports } { incr i } {
	create_bd_cell -type ip -vlnv esa.informatik.tu-darmstadt.de:tapasco:AXIMMStreamAdapter:1.0 axi_mm_stream_adapter_$i
}
 
 # Create instance: dmaOffset, and set properties
  set dmaOffset [ create_bd_cell -type ip -vlnv esa.cs.tu-darmstadt.de:axi:axi_offset dmaOffset ]
  set_property CONFIG.HIGHEST_ADDR_BIT 0 $dmaOffset

  set_property -dict [ list \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.MAX_BURST_LENGTH {256} \
 ] [get_bd_intf_pins /dmaOffset/M_AXI]

  set_property -dict [ list \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.MAX_BURST_LENGTH {256} \
 ] [get_bd_intf_pins /dmaOffset/S_AXI]

if {$maxi_ports == 2} {
    set dmaOffset2 [create_bd_cell -type ip -vlnv esa.cs.tu-darmstadt.de:axi:axi_offset dmaOffset2]
    set_property CONFIG.HIGHEST_ADDR_BIT 0 $dmaOffset
}
