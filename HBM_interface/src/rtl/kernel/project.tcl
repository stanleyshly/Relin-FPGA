set kernel_dir          [lindex $::argv 0]
set part                [lindex $::argv 1]
set path_to_tmp_project [lindex $::argv 2]
set path_to_packaged    [lindex $::argv 3]
set for_sim             [lindex $::argv 4]

puts $kernel_dir
puts $path_to_tmp_project
puts $path_to_packaged
puts $for_sim

create_project -force kernel_pack $path_to_tmp_project -part $part

set source_list [regexp -all -inline {\S+} [read [open "${kernel_dir}/sources" "r"]]]
foreach line ${source_list} {
  lappend source_files [file normalize $line]
}
add_files -norecurse $source_files

source -notrace "${kernel_dir}/ip.tcl"

################################################################################

# source -notrace "${kernel_dir}/bd.tcl"
if {$for_sim == yes} {
  source -notrace "${kernel_dir}/tb.tcl"
}

################################################################################

set_property top kernel [get_filesets sources_1]
# set_property top tb_kernel [get_filesets sim_1]

################################################################################

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

################################################################################

if {$for_sim == no} {

  ipx::package_project -root_dir $path_to_packaged -vendor xilinx.com -library RTLKernel -taxonomy /KernelIP -import_files -set_current false
  ipx::unload_core $path_to_packaged/component.xml
  ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory $path_to_packaged $path_to_packaged/component.xml

  set_property core_revision 2 [ipx::current_core]
  foreach up [ipx::get_user_parameters] {
    ipx::remove_user_parameter [get_property NAME $up] [ipx::current_core]
  }

  set_property sdx_kernel true [ipx::current_core]
  set_property sdx_kernel_type rtl [ipx::current_core]
  # set_property ipi_drc {ignore_freq_hz true} [ipx::current_core]
  # set_property vitis_drc {ctrl_protocol ap_ctrl_hs} [ipx::current_core]

  ipx::create_xgui_files [ipx::current_core]
  # ipx::infer_bus_interface ap_clk_2   xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
  # ipx::infer_bus_interface ap_rst_n_2 xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]

  ipx::associate_bus_interfaces -busif m00_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m01_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m02_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m03_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m04_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m05_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m06_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m07_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m08_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m09_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m10_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m11_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m12_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m13_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m14_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m15_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m16_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m17_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m18_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m19_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m20_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m21_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m22_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m23_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m24_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m25_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m26_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m27_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m28_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m29_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m30_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif m31_axi       -clock ap_clk [ipx::current_core]
  ipx::associate_bus_interfaces -busif s_axi_control -clock ap_clk [ipx::current_core]

  set_property xpm_libraries {XPM_CDC XPM_MEMORY XPM_FIFO} [ipx::current_core]
  #set_property supported_families { } [ipx::current_core]
  set_property auto_family_support_level level_2 [ipx::current_core]

  ipx::update_checksums [ipx::current_core]
  ipx::save_core [ipx::current_core]

  close_project -delete
}