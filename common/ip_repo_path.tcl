set_property "ip_repo_paths" "\
	[file normalize "$origin_dir/IP/Controller"] \
	[file normalize "$origin_dir/IP/AXIGate"] \
	[file normalize "$origin_dir/IP/axi_offset"] \
	[file normalize "$origin_dir/IP/axi_ctrl"] \
	[file normalize "$origin_dir/IP/riscv"] \
	[file normalize ${moddir}] \
	" $obj
