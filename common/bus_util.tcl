# Sets all FIFO sizes of an interconnect buffer. Allowed values for dim_ar, dim_aw, dim_b: 0,1,2,4,8,16,32; dim_r, dim_w also allow 64..4096
# Requires CONFIG.ADVANCED_PROPERTIES to be initialized, e.g. to {}
# Example: set_bus_buffer_fifos [get_bd_cells axi_interconnect_1] M00_Buffer 4 4 4 4 4
proc set_bus_buffer_fifos { cell buffer dim_ar dim_aw dim_b dim_r dim_w } {
  set prop [get_property CONFIG.ADVANCED_PROPERTIES $cell]
  dict set prop __view__ functional $buffer AR_SIZE $dim_ar
  dict set prop __view__ functional $buffer AW_SIZE $dim_aw
  dict set prop __view__ functional $buffer B_SIZE $dim_b
  dict set prop __view__ functional $buffer R_SIZE $dim_r
  dict set prop __view__ functional $buffer W_SIZE $dim_w
  set_property CONFIG.ADVANCED_PROPERTIES $prop $cell
}
