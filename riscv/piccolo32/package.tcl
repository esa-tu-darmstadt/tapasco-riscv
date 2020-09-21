set name "RV64ACIMU"
if {$::argc > 0} {
    set name [string trim [lindex $::argv 0]]
}
puts "package piccolo $name"

set version 0.1
create_project -force $name
add_files [glob Piccolo/builds/${name}_Piccolo_verilator/Verilog_RTL/*.v]
add_files [glob Piccolo/src_bsc_lib_RTL/*.v]
remove_files  Piccolo/src_bsc_lib_RTL/main.v
update_compile_order -fileset sources_1

set_property top mkCore [current_fileset]
update_compile_order -fileset sources_1

remove_files [get_files -filter {IS_AUTO_DISABLED}]

ipx::package_project -root_dir [pwd]/$name -import_files -force
set core [ipx::current_core]
set_property vendor bluespec.com $core
set_property library piccolo $core
set_property name $name $core
set_property display_name $name $core
set_property description $name $core
set_property version $version $core
set_property core_revision 1 $core

# Get IP definition of DMI
set tapasco_toolflow $::env(TAPASCO_HOME_TOOLFLOW)
set_property ip_repo_paths [concat [get_property ip_repo_paths [current_project]] $tapasco_toolflow/vivado/common/ip/DMI/] [current_project]
update_ip_catalog

# Map DMI interface
ipx::add_bus_interface DMI [ipx::current_core]
set_property abstraction_type_vlnv esa.informatik.tu-darmstadt.de:user:DMI_rtl:1.0 [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
set_property bus_type_vlnv esa.informatik.tu-darmstadt.de:user:DMI:1.0 [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
ipx::add_port_map REQ_W_ADDRESS [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
set_property physical_name dm_dmi_write_dm_addr [ipx::get_port_maps REQ_W_ADDRESS -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
ipx::add_port_map REQ_READ [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
set_property physical_name EN_dm_dmi_read_data [ipx::get_port_maps REQ_READ -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
ipx::add_port_map RSP_DATA [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
set_property physical_name dm_dmi_read_data [ipx::get_port_maps RSP_DATA -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
ipx::add_port_map REQ_DATA [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
set_property physical_name dm_dmi_write_dm_word [ipx::get_port_maps REQ_DATA -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
ipx::add_port_map REQ_WRITE [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
set_property physical_name EN_dm_dmi_write [ipx::get_port_maps REQ_WRITE -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
ipx::add_port_map REQ_ADDRESS [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
set_property physical_name dm_dmi_read_addr_dm_addr [ipx::get_port_maps REQ_ADDRESS -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]
ipx::add_port_map REQ_VALID [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]
set_property physical_name EN_dm_dmi_read_addr [ipx::get_port_maps REQ_VALID -of_objects [ipx::get_bus_interfaces DMI -of_objects [ipx::current_core]]]


set_property driver_value 1 [ipx::get_ports cpu_reset_server_request_put -of_objects [ipx::current_core]]

ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core
ipx::check_integrity $core

ipx::archive_core bluespec.com_risc-v_piccolo_$name.zip $core
ipx::unload_core component_1
