# V80 project simulation IP. AXI VIP is supported for Versal devices.
# The U280 FIFO Generator IPs are not used by the RTL source set and are not
# supported for the V80 part, so they are intentionally not added here.
create_ip -name axi_vip -vendor xilinx.com -library ip -version 1.1 -module_name axi_vip_0
set_property -dict [list CONFIG.INTERFACE_MODE {SLAVE} CONFIG.ADDR_WIDTH {64} CONFIG.DATA_WIDTH {256}] [get_ips axi_vip_0]
set_property generate_synth_checkpoint false [get_files axi_vip_0.xci]
