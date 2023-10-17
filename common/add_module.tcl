source common/module_info.tcl
# read component.xml
set component $moddir/component.xml
set rc [open $component r]
set fi [read $rc]
close $rc
set vendorList [lsearch -inline $fi "*spirit:vendor*"]
set libraryList [lsearch -inline $fi "*spirit:library*"]
set nameList [lsearch -inline $fi "*spirit:name*"]
set versionList [lsearch -inline $fi "*spirit:version*"]

set List {$vendorList $libraryList $nameList $versionList}
set xL {vendor library name version}
set i 0
foreach elem $List {
lassign [lindex [split [lindex [split [subst $elem] "<"] 1] ">"] 1] [lindex $xL $i]
incr i
}

set rv_cell [get_bd_cells -filter "VLNV==$current_core"]
delete_bd_objs [get_bd_intf_nets axi_mem_intercon_1_M00_AXI]

#create modules
set $name [ create_bd_cell -type ip -vlnv $vendor:$library:$name:$version $name ]
if {$project_name == "swerv_pe"} {
	set project_obj swerv_0
}
if {$project_name == "orca_pe"} {
        set project_obj orca_0
}
set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
if {${if_type} == "AXI_APB"} {
	set axi_apb_bridge_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_apb_bridge:3.0 axi_apb_bridge_0]
	set_property -dict [list CONFIG.C_M_APB_PROTOCOL {apb4}] [get_bd_cells axi_apb_bridge_0]
	set_property -dict [list CONFIG.C_APB_NUM_SLAVES {1}] [get_bd_cells axi_apb_bridge_0]
}
set_property -dict [list CONFIG.NUM_SI {2}] [get_bd_cells smartconnect_0]
set_property -dict [list CONFIG.NUM_MI {2}] [get_bd_cells axi_interconnect_0]

#connect intf
connect_bd_intf_net [get_bd_intf_pins -filter {MODE==Master} -of [get_bd_cells $name]] [get_bd_intf_pins smartconnect_0/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins dmaOffset/S_AXI]
if {${if_type} == "AXI_APB"} {
	connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_apb_bridge_0/APB_M] [get_bd_intf_pins -filter {MODE==Slave} -of [get_bd_cells $name]]
	connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins axi_apb_bridge_0/AXI4_LITE]
} 
if {${if_type} == "AXI4_LITE"} {
	connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins -filter {MODE==Slave} -of [get_bd_cells $name]]
}

make_bd_intf_pins_external  [get_bd_intf_pins axi_offset_0/M_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_mem_intercon_1/M00_AXI] [get_bd_intf_pins smartconnect_0/S01_AXI]

#connect ports

#CLK
connect_bd_net [get_bd_ports CLK] [get_bd_pins -filter {TYPE=="clk"} -of [get_bd_cells $name]] [get_bd_pins smartconnect_0/aclk] [get_bd_pins axi_interconnect_0/M01_ACLK]
if {${if_type} == "AXI_APB"} {
	connect_bd_net [get_bd_ports CLK] [get_bd_pins axi_apb_bridge_0/s_axi_aclk]
}

#RST
connect_bd_net [get_bd_pins rst_CLK_100M/peripheral_aresetn] [get_bd_pins -filter {TYPE=="rst"} -of [get_bd_cells $name]] [get_bd_pins axi_interconnect_0/M01_ARESETN]
if {${if_type} == "AXI_APB"} {
	connect_bd_net [get_bd_pins rst_CLK_100M/peripheral_aresetn] [get_bd_pins axi_apb_bridge_0/s_axi_aresetn]
}
connect_bd_net [get_bd_pins smartconnect_0/aresetn] [get_bd_pins rst_CLK_100M/interconnect_aresetn]

#INTR
if {${module_has_intr} == "true"} {
	if {$project_name == "swerv_pe"} {
		connect_bd_net [get_bd_pins -filter {TYPE=="intr"} -of [get_bd_cells $name]] [get_bd_pins -filter {TYPE=="intr"} -of [get_bd_cells $project_obj]]
	}
	if {$project_name == "orca_pe"} {
		startgroup
		set_property -dict [list CONFIG.ENABLE_EXCEPTIONS {1} CONFIG.ENABLE_EXT_INTERRUPTS {1}] [get_bd_cells $project_obj]
                endgroup
		connect_bd_net [get_bd_pins -filter {TYPE=="intr"} -of [get_bd_cells $name]] [get_bd_pins -filter {TYPE=="intr"} -of [get_bd_cells $project_obj]]
        }

}
