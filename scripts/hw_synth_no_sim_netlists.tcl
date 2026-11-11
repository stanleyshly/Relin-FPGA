# Hardware-only PRE hook for ulp_kernel_1_0_synth_1 (Vivado 2022.1).
# Keep checkpoints and synthesis stubs; omit BOTH functional simulation exports.
# This run must not publish an incomplete entry to the shared IP cache.
# Platform IP runs retain their normal caching and export behavior.
foreach command {write_verilog write_vhdl} {
    rename ::$command ::relin_original_$command
    proc ::$command {args} [string map [list @COMMAND@ $command] {
        set mode_index [lsearch -exact $args -mode]
        if {$mode_index >= 0 && [lindex $args [expr {$mode_index + 1}]] eq "funcsim"} {
            puts "RELIN_HW: skipping @COMMAND@ functional simulation netlist"
            return
        }
        return [uplevel 1 [list ::relin_original_@COMMAND@ {*}$args]]
    }]
}
rename ::config_ip_cache ::relin_original_config_ip_cache
proc ::config_ip_cache {args} {
    if {[lsearch -exact $args -export] >= 0 || [lsearch -exact $args -add] >= 0} {
        puts "RELIN_HW: kernel cache lookup/publication disabled for hardware synthesis"
        return
    }
    return [uplevel 1 [list ::relin_original_config_ip_cache {*}$args]]
}

# The renamed checkpoint is solely for cache publication. The normal checkpoint
# written later is retained for implementation.
rename ::write_checkpoint ::relin_original_write_checkpoint
proc ::write_checkpoint {args} {
    if {[lsearch -exact $args -rename_prefix] >= 0} {
        puts "RELIN_HW: skipping cache-only renamed checkpoint"
        return
    }
    return [uplevel 1 [list ::relin_original_write_checkpoint {*}$args]]
}
