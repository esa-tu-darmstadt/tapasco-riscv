puts "package OpenHW Group cva5"

set name cva5
set version 0.1
create_project -in_memory

#~ add_files [glob cva5/debug_module/*.sv]
add_files [glob cva5/l2_arbiter/*.sv]
#~ add_files [glob cva5/local_memory/*.sv]
add_files [glob cva5/local_memory/local_memory_interface.sv]
add_files [glob cva5/core/lutrams/*.sv]
add_files [glob cva5/core/*{.sv,.v}]

remove_files cva5/core/binary_occupancy.sv
remove_files cva5/core/placer_randomizer.sv

update_compile_order -fileset sources_1
set_property top cva5_wrapper_verilog [current_fileset]
update_compile_order -fileset sources_1

ipx::package_project -root_dir [pwd]/cva5 -import_files -force -force_update_compile_order
set core [ipx::current_core]
set_property vendor openhwgroup $core
set_property library $name $core
set_property name $name $core
set_property display_name $name $core
set_property description $name $core
set_property version $version $core
set_property core_revision 1 $core

ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core
ipx::check_integrity $core

ipx::archive_core openhwgroup_risc-v_$name.zip $core
ipx::unload_core component_1

