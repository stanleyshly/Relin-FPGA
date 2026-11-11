# Vivado post-route hook. The report includes resources by design hierarchy,
# which lets us compare kernel submodules with the paper's Table 6 breakdown.
set report_path [file join [pwd] hierarchical_utilization_routed.rpt]
report_utilization -hierarchical -file $report_path
puts "RELIN_REPORT: wrote hierarchical utilization to $report_path"
