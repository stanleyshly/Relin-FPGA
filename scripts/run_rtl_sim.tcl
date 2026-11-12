# Run the existing V80 behavioral simulation with the checked-in FIFO model.
set root [file normalize [file join [file dirname [info script]] ..]]
open_project [file join $root vivado_2025 relin.xpr]
if {[get_property PART [current_project]] ne "xcv80-lsva4737-2MHP-e-S"} {
    error "Relin simulation requires the V80 device part xcv80-lsva4737-2MHP-e-S"
}
set fifo [file join $root HBM_interface src rtl kernel fifo_sync_v80.sv]
if {[llength [get_files -quiet $fifo]] == 0} {
    add_files -fileset sim_hbm -norecurse $fifo
}
current_fileset -simset [get_filesets sim_hbm]
set options {-testplusarg RELIN_PROFILE}
if {[info exists ::env(RELIN_TIMING_ONLY)] && $::env(RELIN_TIMING_ONLY) eq "1"} {
    lappend options -testplusarg RELIN_TIMING_ONLY
}
if {[info exists ::env(RELIN_VECTOR_DIR)]} {
    lappend options -testplusarg "RELIN_VECTOR_DIR=$::env(RELIN_VECTOR_DIR)"
}
# Do not run the default 1000 ns here: execute exactly once with run all.
set_property xsim.simulate.runtime 0ns [get_filesets sim_hbm]
set_property -dict [list xsim.simulate.xsim.more_options $options] [get_filesets sim_hbm]
launch_simulation -simset sim_hbm -mode behavioral
run all
close_sim
close_project
