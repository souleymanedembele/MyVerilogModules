/**
 * File              : UART.sv
 * Author            : Souleymane Dembele <sdembele@uw.edu>
 * Date              : 06.24.2023
 * Last Modified Date: 06.24.2023
 * Last Modified By  : Souleymane Dembele <sdembele@uw.edu>
 */
`ifndef UART_H
`define UART_H
module UART (
    Clock,  // 50MHz clock
    ResetN,  // Reset
    ReadUart,  // Read UART data from the UART RX FIFO
    WriteUart,  // Write UART data to the UART TX FIFO
    Rx,  // UART RX data
    Tx,  // UART TX data
    WriteData,  // Data to be written to the UART TX FIFO
    ReadData,  // Data read from the UART RX FIFO
    TxFull,  // UART TX FIFO full
    RxEmpty  // UART RX FIFO Empty
);

  parameter DATA_BITS = 8;  // number of data bits
  parameter STOP_BIT_TICKS = 16;  // number of tick cycles for stop bit
  parameter BAUD_RATE = 19200;
  parameter CLOCK_RATE = 50000000;
  parameter SAMPLE_RATE = 16;
  parameter FIFO_WIDTH = 2;  // 2 bits for FIFO width

  input Clock, ResetN;
  input ReadUart, WriteUart, Rx;
  output Tx, TxFull, RxEmpty;
  input [DATA_BITS-1:0] WriteData;
  output [DATA_BITS-1:0] ReadData;

endmodule
`endif
