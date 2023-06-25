onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /UART_tb/Clock
add wave -noupdate /UART_tb/DUT.ClockTick
add wave -noupdate /UART_tb/ResetN
add wave -noupdate /UART_tb/ReadUart
add wave -noupdate /UART_tb/WriteUart
add wave -noupdate /UART_tb/Rx
add wave -noupdate /UART_tb/Tx
add wave -noupdate /UART_tb/WriteData
add wave -noupdate /UART_tb/ReadData
add wave -noupdate /UART_tb/TxFull
add wave -noupdate /UART_tb/RxEmpty
add wave -noupdate /UART_tb/DUT.RxReady
add wave -noupdate /UART_tb/DUT.TxReady
add wave -noupdate /UART_tb/DUT.RxData
add wave -noupdate /UART_tb/DUT.TxData
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
