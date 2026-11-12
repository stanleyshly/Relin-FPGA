# Recreate a portable simulation project with the installed Vivado release.
set root [file normalize [file join [file dirname [info script]] ..]]
set device [string toupper [lindex $::argv 0]]
if {$device eq ""} {set device U280}
switch -- $device {
    U280 {
        set project_dir [file join $root vivado_2022]
        set part xcu280-fsvh2892-2L-e
    }
    V80 {
        set project_dir [file join $root vivado_2025]
        set part xcv80-lsva4737-2MHP-e-S
    }
    default {error "Unsupported device '$device'; use U280 or V80"}
}
create_project -force relin $project_dir -part $part
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set_property source_mgmt_mode All [current_project]
set manifest [open [file join $root HBM_interface src rtl kernel sources] r]
set sources [regexp -all -inline {\S+} [read $manifest]]
close $manifest
set include_dirs {}
set source_paths {}
foreach source $sources {
    set path [file normalize [file join $root HBM_interface $source]]
    if {![file exists $path]} {
        puts "WARNING: Skipping missing RTL source: $path (restore it from the repository checkout)"
        continue
    }
    lappend source_paths $path
    if {[file extension $path] in {.vh .svh}} {
        lappend include_dirs [file dirname $path]
    }
}
add_files -norecurse $source_paths
set_property include_dirs [lsort -unique $include_dirs] [get_filesets sources_1]
if {$device eq "V80"} {
    source [file join $root scripts project_ip_v80.tcl]
} else {
    source [file join $root scripts project_ip.tcl]
}
set_property top kernel [get_filesets sources_1]
foreach {fileset top files} {
    sim_hbm kernel_tb {kernel_tb.v axi_hbm.sv axi_ram.sv}
    sim_relin relin_tb {relin_tb.sv}
    sim_hadamard hadamard_tb {hadamard_tb.sv}
    sim_accumulator accumulator_tb {accumulator_tb.sv}
    sim_final_op final_op_tb {final_op_tb.sv}
} {
    create_fileset -simset $fileset
    foreach file $files {
        add_files -fileset $fileset -norecurse [file join $root src tb $file]
    }
    set_property top $top [get_filesets $fileset]
    set_property include_dirs [lsort -unique $include_dirs] [get_filesets $fileset]
}
current_fileset -simset [get_filesets sim_hbm]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_hbm
report_ip_status
puts "PROJECT_CREATED_OK: $project_dir/relin.xpr with Vivado [version -short]"
close_project
