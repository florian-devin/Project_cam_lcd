onerror {resume}
quietly WaveActivateNextPane {} 0
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
add wave -noupdate /ip_cam_tb/DUT/new_data
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
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7980 ps} 0}
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
WaveRestoreZoom {83223 ps} {206147 ps}
