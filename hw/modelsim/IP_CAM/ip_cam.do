onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ip_cam_tb/DUT/Clk
add wave -noupdate /ip_cam_tb/nReset
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_Frame/CAM_reset
add wave -noupdate /ip_cam_tb/CamReset_n
add wave -noupdate /ip_cam_tb/DUT/nReset
add wave -noupdate /ip_cam_tb/CMOS/reset
add wave -noupdate -divider Cam
add wave -noupdate -divider {Avalon slave}
add wave -noupdate /ip_cam_tb/DUT/AS_Address
add wave -noupdate /ip_cam_tb/DUT/AS_Cs_n
add wave -noupdate /ip_cam_tb/DUT/AS_Write_n
add wave -noupdate -radix hexadecimal /ip_cam_tb/DUT/AS_Datawr
add wave -noupdate /ip_cam_tb/DUT/AS_Read_n
add wave -noupdate -radix hexadecimal /ip_cam_tb/DUT/AS_Datard
add wave -noupdate -divider Avalon_Master
add wave -noupdate -radix hexadecimal /ip_cam_tb/DUT/AM_Address
add wave -noupdate -radix hexadecimal /ip_cam_tb/DUT/AM_byteEnable_n
add wave -noupdate /ip_cam_tb/DUT/AM_BurstCount
add wave -noupdate /ip_cam_tb/DUT/AM_Write_n
add wave -noupdate -radix hexadecimal /ip_cam_tb/DUT/AM_Datawr
add wave -noupdate /ip_cam_tb/DUT/AM_WaitRequest
add wave -noupdate -divider Internal
add wave -noupdate /ip_cam_tb/DUT/start_addr
add wave -noupdate /ip_cam_tb/DUT/length
add wave -noupdate /ip_cam_tb/DUT/capture_done
add wave -noupdate /ip_cam_tb/DUT/acquisition
add wave -noupdate /ip_cam_tb/DUT/data
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_AVMaster/state_reg
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_AVMaster/state_next
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_AVMaster/new_frame
add wave -noupdate /ip_cam_tb/DUT/new_frame
add wave -noupdate /ip_cam_tb/DUT/ack
add wave -noupdate /ip_cam_tb/Cam_Mclk
add wave -noupdate /ip_cam_tb/Cam_Pixclk
add wave -noupdate /ip_cam_tb/Cam_Vsync
add wave -noupdate /ip_cam_tb/Cam_Hsync
add wave -noupdate /ip_cam_tb/Cam_data
add wave -noupdate /ip_cam_tb/CamReset_n
add wave -noupdate -divider Frame
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_Frame/clk
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_Frame/state
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_Frame/output_interface
add wave -noupdate -divider {fifo interface}
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_Frame/FIFO_interface/clock
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_Frame/FIFO_interface/data
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_Frame/FIFO_interface/rdreq
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_Frame/FIFO_interface/wrreq
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_Frame/FIFO_interface/empty
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_Frame/FIFO_interface/full
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_Frame/FIFO_interface/q
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_Frame/FIFO_interface/usedw
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_Frame/FIFO_interface/sub_wire0
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_Frame/FIFO_interface/sub_wire1
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_Frame/FIFO_interface/sub_wire2
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_Frame/FIFO_interface/sub_wire3
add wave -noupdate -divider expected
add wave -noupdate /ip_cam_tb/CamAddr_exp
add wave -noupdate /ip_cam_tb/CamLength_exp
add wave -noupdate /ip_cam_tb/CamStatus_exp
add wave -noupdate /ip_cam_tb/CamStart_exp
add wave -noupdate /ip_cam_tb/CamStop_exp
add wave -noupdate /ip_cam_tb/CamSnapshot_exp
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_AVSlave/CamAddr
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_AVSlave/CamLength
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_AVSlave/CamStatus
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_AVSlave/CamStart
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_AVSlave/CamStop
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_AVSlave/CamSnapshot
add wave -noupdate -divider CMOS
add wave -noupdate /ip_cam_tb/CMOS/clk
add wave -noupdate /ip_cam_tb/CMOS/reset
add wave -noupdate /ip_cam_tb/CMOS/reg_state
add wave -noupdate /ip_cam_tb/CMOS/next_reg_state
add wave -noupdate /ip_cam_tb/CMOS/reg_start
add wave -noupdate /ip_cam_tb/CMOS/reg_stop
add wave -noupdate /ip_cam_tb/CMOS/addr
add wave -noupdate /ip_cam_tb/CMOS/read
add wave -noupdate /ip_cam_tb/CMOS/write
add wave -noupdate /ip_cam_tb/CMOS/rddata
add wave -noupdate /ip_cam_tb/CMOS/wrdata
add wave -noupdate /ip_cam_tb/CMOS/frame_valid
add wave -noupdate /ip_cam_tb/CMOS/line_valid
add wave -noupdate -radix unsigned /ip_cam_tb/CMOS/data
add wave -noupdate /ip_cam_tb/CMOS/reg_frame_width_config
add wave -noupdate /ip_cam_tb/CMOS/reg_frame_height_config
add wave -noupdate /ip_cam_tb/CMOS/reg_frame_frame_blank_config
add wave -noupdate /ip_cam_tb/CMOS/reg_frame_line_blank_config
add wave -noupdate /ip_cam_tb/CMOS/reg_line_line_blank_config
add wave -noupdate /ip_cam_tb/CMOS/reg_line_frame_blank_config
add wave -noupdate /ip_cam_tb/CMOS/reg_start
add wave -noupdate /ip_cam_tb/CMOS/reg_stop
add wave -noupdate /ip_cam_tb/CMOS/reg_state
add wave -noupdate /ip_cam_tb/CMOS/next_reg_state
add wave -noupdate /ip_cam_tb/CMOS/reg_frame_width_counter
add wave -noupdate /ip_cam_tb/CMOS/next_reg_frame_width_counter
add wave -noupdate /ip_cam_tb/CMOS/reg_frame_height_counter
add wave -noupdate /ip_cam_tb/CMOS/next_reg_frame_height_counter
add wave -noupdate /ip_cam_tb/CMOS/reg_frame_frame_blank_counter
add wave -noupdate /ip_cam_tb/CMOS/next_reg_frame_frame_blank_counter
add wave -noupdate /ip_cam_tb/CMOS/reg_frame_line_blank_counter
add wave -noupdate /ip_cam_tb/CMOS/next_reg_frame_line_blank_counter
add wave -noupdate /ip_cam_tb/CMOS/reg_line_line_blank_counter
add wave -noupdate /ip_cam_tb/CMOS/next_reg_line_line_blank_counter
add wave -noupdate /ip_cam_tb/CMOS/reg_line_frame_blank_counter
add wave -noupdate /ip_cam_tb/CMOS/next_reg_line_frame_blank_counter
add wave -noupdate /ip_cam_tb/DUT/Clk
add wave -noupdate /ip_cam_tb/DUT/nReset
add wave -noupdate -divider Cam
add wave -noupdate -divider {Avalon slave}
add wave -noupdate /ip_cam_tb/DUT/AS_Address
add wave -noupdate /ip_cam_tb/DUT/AS_Cs_n
add wave -noupdate /ip_cam_tb/DUT/AS_Write_n
add wave -noupdate /ip_cam_tb/DUT/AS_Datawr
add wave -noupdate /ip_cam_tb/DUT/AS_Read_n
add wave -noupdate /ip_cam_tb/DUT/AS_Datard
add wave -noupdate -divider Avalon_Master
add wave -noupdate /ip_cam_tb/DUT/AM_Address
add wave -noupdate /ip_cam_tb/DUT/AM_byteEnable_n
add wave -noupdate /ip_cam_tb/DUT/AM_BurstCount
add wave -noupdate /ip_cam_tb/DUT/AM_Write_n
add wave -noupdate /ip_cam_tb/DUT/AM_Datawr
add wave -noupdate /ip_cam_tb/DUT/AM_WaitRequest
add wave -noupdate -divider Internal
add wave -noupdate /ip_cam_tb/DUT/start_addr
add wave -noupdate /ip_cam_tb/DUT/length
add wave -noupdate /ip_cam_tb/DUT/capture_done
add wave -noupdate /ip_cam_tb/DUT/acquisition
add wave -noupdate /ip_cam_tb/DUT/data
add wave -noupdate /ip_cam_tb/DUT/new_frame
add wave -noupdate /ip_cam_tb/DUT/ack
add wave -noupdate /ip_cam_tb/Cam_Mclk
add wave -noupdate /ip_cam_tb/Cam_Pixclk
add wave -noupdate /ip_cam_tb/Cam_Hsync
add wave -noupdate /ip_cam_tb/Cam_Vsync
add wave -noupdate /ip_cam_tb/Cam_data
add wave -noupdate /ip_cam_tb/CamReset_n
add wave -noupdate -divider expected
add wave -noupdate /ip_cam_tb/CamAddr_exp
add wave -noupdate /ip_cam_tb/CamLength_exp
add wave -noupdate /ip_cam_tb/CamStatus_exp
add wave -noupdate /ip_cam_tb/CamStart_exp
add wave -noupdate /ip_cam_tb/CamStop_exp
add wave -noupdate /ip_cam_tb/CamSnapshot_exp
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_AVSlave/CamAddr
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_AVSlave/CamLength
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_AVSlave/CamStatus
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_AVSlave/CamStart
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_AVSlave/CamStop
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_AVSlave/CamSnapshot
add wave -noupdate -divider CMOS
add wave -noupdate /ip_cam_tb/CMOS/addr
add wave -noupdate /ip_cam_tb/CMOS/read
add wave -noupdate /ip_cam_tb/CMOS/write
add wave -noupdate /ip_cam_tb/CMOS/rddata
add wave -noupdate /ip_cam_tb/CMOS/wrdata
add wave -noupdate /ip_cam_tb/CMOS/frame_valid
add wave -noupdate /ip_cam_tb/CMOS/line_valid
add wave -noupdate /ip_cam_tb/CMOS/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8638 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ps} {69106 ps}
