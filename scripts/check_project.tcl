set root [file normalize [file join [file dirname [info script]] ..]]
set device [string toupper [lindex $::argv 0]]
if {$device eq ""} {set device U280}
switch -- $device {
    U280 {set project [file join $root vivado_2022 relin.xpr]}
    V80 {set project [file join $root vivado_2025 relin.xpr]}
    default {error "Unsupported device '$device'; use U280 or V80"}
}
if {[catch {
    open_project $project
    set missing {}
    foreach f [get_files -all] {
        if {![file exists $f]} {lappend missing $f}
    }
    if {[llength $missing]} {error "Missing project sources: $missing"}
    update_compile_order -fileset sources_1
    report_ip_status
    foreach ip [get_ips] {
        if {[get_property IS_LOCKED $ip]} {error "Locked IP: $ip"}
    }
    puts "PROJECT_OPEN_OK: [get_property NAME [current_project]] in Vivado [version -short]"
    close_project
} message]} {
    puts stderr "PROJECT_OPEN_FAILED: $message"
    exit 1
}
exit 0
