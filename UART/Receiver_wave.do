onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Receiver_tb/Clock
add wave -noupdate /Receiver_tb/ResetN
add wave -noupdate /Receiver_tb/Rx
add wave -noupdate /Receiver_tb/Tick
add wave -noupdate /Receiver_tb/RxReady
add wave -noupdate /Receiver_tb/RxData
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0            
configure wave -namecolwidth 150        
configure wave -valuecolwidth 100       
configure wave -justifyvalue left       
configure wave -signalnamewidth 0       
configure wave -snapdistance 10         
configure wave -datasetprefix 0         
configure wave -rowmargin 4             
configure wave -childrowmargin 2        
configure wave -gridoffset 0            
configure wave -gridperiod 1            
configure wave -griddelta 40            
configure wave -timeline 0              
configure wave -timelineunits ps        
update                                  
WaveRestoreZoom {0 ps} {1 ns}          
