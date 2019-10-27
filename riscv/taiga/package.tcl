puts "package sfu-rcl taiga"

set name taiga
set version 0.1
create_project -in_memory

add_files [glob Taiga/l2_arbiter/*.sv]
add_files [glob Taiga/local_memory/local_memory_interface.sv]
add_files [glob Taiga/core/div_algorithms/*.sv]
add_files [glob Taiga/core/*{.sv,.v}]

remove_files Taiga/core/div_unit_core_wrapper.sv
remove_files Taiga/core/binary_occupancy.sv
remove_files Taiga/core/msb.sv
remove_files Taiga/core/mstatus_priv_reg.sv
remove_files Taiga/core/placer_randomizer.sv

update_compile_order -fileset sources_1
set_property top taiga_wrapper_verilog [current_fileset]
update_compile_order -fileset sources_1

ipx::package_project -root_dir [pwd]/taiga -import_files -force
set core [ipx::current_core]
set_property vendor sfu-rcl $core
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

ipx::archive_core sfu-rcl_risc-v_$name.zip $core
ipx::unload_core component_1
