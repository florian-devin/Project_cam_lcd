onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ip_cam_tb/DUT/Clk
add wave -noupdate /ip_cam_tb/nReset
add wave -noupdate /ip_cam_tb/CamReset_n
add wave -noupdate -divider Avalon_Master
add wave -noupdate -radix hexadecimal /ip_cam_tb/DUT/AM_Address
add wave -noupdate -radix hexadecimal /ip_cam_tb/addr_exp
add wave -noupdate -radix hexadecimal /ip_cam_tb/DUT/AM_byteEnable_n
add wave -noupdate /ip_cam_tb/DUT/AM_BurstCount
add wave -noupdate /ip_cam_tb/DUT/AM_Write_n
add wave -noupdate -radix hexadecimal /ip_cam_tb/DUT/AM_Datawr
add wave -noupdate /ip_cam_tb/DUT/AM_WaitRequest
add wave -noupdate -radix hexadecimal /ip_cam_tb/data_exp
add wave -noupdate /ip_cam_tb/DUT/IP_CAM_AVMaster/state_reg
add wave -noupdate -divider expected_reg
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
add wave -noupdate -radix binary /ip_cam_tb/CMOS/data
add wave -noupdate -radix hexadecimal /ip_cam_tb/CMOS/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3078473113 ps} 0} {{Cursor 2} {15225865000 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 210
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
WaveRestoreZoom {0 ps} {28492801945 ps}
