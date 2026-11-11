# IP configuration recreated with the installed Vivado IP catalog.
create_ip -name axi_vip -vendor xilinx.com -library ip -version 1.1 -module_name axi_vip_0
set_property -dict [list CONFIG.INTERFACE_MODE {SLAVE} CONFIG.ADDR_WIDTH {64} CONFIG.DATA_WIDTH {256}] [get_ips axi_vip_0]
set_property generate_synth_checkpoint false [get_files axi_vip_0.xci]
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name fifo_sync
set_property -dict [list CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} CONFIG.Performance_Options {First_Word_Fall_Through} CONFIG.Input_Data_Width {256} CONFIG.Input_Depth {2048} CONFIG.Output_Data_Width {256} CONFIG.Output_Depth {2048} CONFIG.Use_Extra_Logic {true} CONFIG.Data_Count {true} CONFIG.Data_Count_Width {12} CONFIG.Write_Data_Count_Width {12} CONFIG.Read_Data_Count_Width {12} CONFIG.Full_Threshold_Assert_Value {2047} CONFIG.Full_Threshold_Negate_Value {2046} CONFIG.Empty_Threshold_Assert_Value {4} CONFIG.Empty_Threshold_Negate_Value {5}] [get_ips fifo_sync]
set_property generate_synth_checkpoint false [get_files fifo_sync.xci]
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name fifo_sync2
set_property -dict [list CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} CONFIG.Performance_Options {First_Word_Fall_Through} CONFIG.Input_Data_Width {256} CONFIG.Input_Depth {64} CONFIG.Output_Data_Width {256} CONFIG.Output_Depth {64} CONFIG.Use_Extra_Logic {true} CONFIG.Data_Count_Width {7} CONFIG.Write_Data_Count_Width {7} CONFIG.Read_Data_Count_Width {7} CONFIG.Full_Threshold_Assert_Value {63} CONFIG.Full_Threshold_Negate_Value {62} CONFIG.Empty_Threshold_Assert_Value {4} CONFIG.Empty_Threshold_Negate_Value {5}] [get_ips fifo_sync2]
set_property generate_synth_checkpoint false [get_files fifo_sync2.xci]
