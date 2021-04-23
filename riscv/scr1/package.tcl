puts "package Syntacore's SCR1"

set name scr1
set version 0.1
create_project -in_memory

add_files [exec cat core.files axi_top.files]
#add_files [glob includes/*.{v,sv,h,svh}]
#set_property file_type {Verilog Header} [get_files *.svh]
set_property include_dirs {includes} [current_fileset]

# optionally remove unneeded files

update_compile_order -fileset sources_1
set_property top scr1_top_axi [current_fileset]
update_compile_order -fileset sources_1

#ipx::package_project -root_dir [pwd]/scr1 -import_files -force
ipx::package_project -root_dir [pwd] -import_files -force
set core [ipx::current_core]
set_property vendor syntacore $core
set_property library scr1 $core
set_property name $name $core
set_property display_name $name $core
set_property description $name $core
set_property version $version $core
set_property core_revision 1 $core

# Get IP definition of DMI
set tapasco_toolflow $::env(TAPASCO_HOME_TOOLFLOW)
set_property ip_repo_paths [concat [get_property ip_repo_paths [current_project]] $tapasco_toolflow/vivado/common/ip/DMI/] [current_project]
update_ip_catalog

#if 0 {
#    # Group core JTAG wires as interface port
#    ipx::infer_bus_interfaces xilinx.com:interface:jtag_rtl:2.0 [ipx::current_core]
#    ipx::infer_bus_interface jtag_trst_n xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]
#} else {
#    # Add DMI interface port:
#    ipx::add_bus_interface DMI [ipx::current_core]
#    set_property abstraction_type_vlnv esa.informatik.tu-darmstadt.de:user:DMI_rtl:1.0 [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#    set_property bus_type_vlnv esa.informatik.tu-darmstadt.de:user:DMI:1.0 [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#    ipx::add_port_map RSP_DATA [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#    set_property physical_name dmi_reg_rdata [ipx::get_port_maps RSP_DATA -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
#    ipx::add_port_map REQ_DATA [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#    set_property physical_name dmi_reg_wdata [ipx::get_port_maps REQ_DATA -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
#    ipx::add_port_map REQ_ADDRESS [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#    set_property physical_name dmi_reg_addr [ipx::get_port_maps REQ_ADDRESS -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
#    ipx::add_port_map REQ_WRITE [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#    set_property physical_name dmi_reg_wr_en [ipx::get_port_maps REQ_WRITE -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
#    ipx::add_port_map REQ_ACCESS [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
#    set_property physical_name dmi_reg_en [ipx::get_port_maps REQ_ACCESS -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
#}

ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core
ipx::check_integrity $core

ipx::archive_core risc-v_$name.zip $core
ipx::unload_core component_1
