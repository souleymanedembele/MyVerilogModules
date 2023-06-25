/**
 * File              : UART.sv
 * Author            : Souleymane Dembele <sdembele@uw.edu>
 * Date              : 06.24.2023
 * Last Modified Date: 06.24.2023
 * Last Modified By  : Souleymane Dembele <sdembele@uw.edu>
 */
`ifndef UART_H
`define UART_H
`include "Fifo.sv"
`include "BaudRateGenerator.sv"
`include "Receiver.sv"
`include "Transmitter.sv"
`include "ReceiverInterface.sv"
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

  input wire Clock, ResetN;
  input wire ReadUart, WriteUart, Rx;
  output wire Tx, TxFull, RxEmpty;
  input wire [DATA_BITS-1:0] WriteData;
  output wire [DATA_BITS-1:0] ReadData;

  // Instantiate the baud rate generator
  wire ClockTick, RxReady, TxReady, TxEmpty, TxFifoNotEmpty;
  wire [DATA_BITS-1:0] RxData, TxData;

  BaudRateGenerator #(
      .BAUD_RATE  (BAUD_RATE),
      .CLOCK_RATE (CLOCK_RATE),
      .SAMPLE_RATE(SAMPLE_RATE)
  ) BRG (
      .Enable(1'b1),
      .Clock(Clock),
      .ClearN(ResetN),
      .ClockTick(ClockTick)
  );

  // Instantiate the receiver
  Receiver #(
      .DATA_BITS(DATA_BITS),
      .STOP_BIT_TICKS(STOP_BIT_TICKS)
  ) RX (
      .Clock(Clock),
      .ResetN(ResetN),
      .Rx(Rx),
      .Tick(ClockTick),
      .RxReady(RxReady),
      .RxData(RxData)
  );
  // Instantiate the fifo for receiver
  Fifo #(
      .WIDTH(DATA_BITS),
      .DEPTH(FIFO_WIDTH)
  ) FIFO_RX (
      .Clock(Clock),
      .ResetN(ResetN),
      .Read(ReadUart),
      .Write(RxReady),
      .ReadData(ReadData),
      .WriteData(RxData),
      .Empty(RxEmpty),
      .Full()
  );
  // Instantiate the fifo for transmitter
  Fifo #(
      .WIDTH(DATA_BITS),
      .DEPTH(FIFO_WIDTH)
  ) FIFO_TX (
      .Clock(Clock),
      .ResetN(ResetN),
      .Read(TxReady),
      .Write(WriteUart),
      .ReadData(TxData),
      .WriteData(WriteData),
      .Empty(TxEmpty),
      .Full(TxFull)
  );
  // Instantiate the transmitter
  Transmitter #(
      .DATA_BITS(DATA_BITS),
      .STOP_BIT_TICKS(STOP_BIT_TICKS)
  ) TX (
      .Clock(Clock),
      .ResetN(ResetN),
      .Tick(ClockTick),
      .TxStart(TxFifoNotEmpty),
      .DataIn(TxData),
      .Tx(Tx),
      .TxReady(TxReady)
  );

  assign TxFifoNotEmpty = ~TxEmpty;
endmodule
`endif

module UART_tb ();
  parameter DATA_BITS = 8;  // number of data bits
  parameter STOP_BIT_TICKS = 16;  // number of tick cycles for stop bit
  parameter BAUD_RATE = 19200;
  parameter CLOCK_RATE = 50000000;
  parameter SAMPLE_RATE = 16;
  parameter FIFO_WIDTH = 2;  // 2 bits for FIFO width
  reg Clock, ResetN, ReadUart, WriteUart, Rx;
  reg  [DATA_BITS-1:0] WriteData;
  wire [DATA_BITS-1:0] ReadData;
  wire Tx, TxFull, RxEmpty;

  UART #(
      .DATA_BITS(DATA_BITS),
      .STOP_BIT_TICKS(STOP_BIT_TICKS),
      .BAUD_RATE(BAUD_RATE),
      .CLOCK_RATE(CLOCK_RATE),
      .SAMPLE_RATE(SAMPLE_RATE),
      .FIFO_WIDTH(FIFO_WIDTH)
  ) DUT (
      .Clock(Clock),
      .ResetN(ResetN),
      .ReadUart(ReadUart),
      .WriteUart(WriteUart),
      .Rx(Rx),
      .Tx(Tx),
      .WriteData(WriteData),
      .ReadData(ReadData),
      .TxFull(TxFull),
      .RxEmpty(RxEmpty)
  );

  always begin
    Clock = 1'b0;
    #10;
    Clock = 1'b1;
    #10;
  end

  always @(Tx) begin
    Rx = Tx;
  end

  initial begin
    ResetN = 1'b0;
    #20;
    ResetN = 1'b1;
    WriteUart = 1'b0;
    ReadUart = 1'b0;
    #20;
    wait (TxFull == 0);
    WriteData = 8'hAA;
    WriteUart = 1'b1;
    ReadUart  = 1'b0;
    wait (DUT.TxData == 8'hAA);
    WriteUart = 1'b0;
    ReadUart  = 1'b1;
    // wait (DUT.TxReady == 1);
    // wait (DUT.TxReady == 0);
    wait (TxFull == 0);
    WriteData = 8'hFF;
    WriteUart = 1'b1;
    ReadUart  = 1'b0;
    // wait (DUT.TxReady == 1);
    // wait (DUT.TxReady == 0);
    wait (TxFull == 1);
    WriteUart = 1'b0;
    ReadUart  = 1'b1;
    // wait (DUT.TxReady == 1);
    // wait (DUT.TxReady == 0);
    wait (TxFull == 0);

    WriteData = 8'h00;
    WriteUart = 1'b1;
    ReadUart  = 1'b0;
    // wait (DUT.TxReady == 1);
    // wait (DUT.TxReady == 0);
    wait (TxFull == 1);
    WriteUart = 1'b0;
    ReadUart  = 1'b1;
    // wait (DUT.TxReady == 1);
    // wait (DUT.TxReady == 0);
    wait (TxFull == 0);

    WriteData = 8'h55;
    WriteUart = 1'b1;
    ReadUart  = 1'b0;
    // wait (DUT.TxReady == 1);
    // wait (DUT.TxReady == 0);
    wait (TxFull == 1);
    WriteUart = 1'b0;
    ReadUart  = 1'b1;
    // wait (DUT.TxReady == 1);
    // wait (DUT.TxReady == 0);
    wait (TxFull == 0);

    WriteData = 8'h2A;
    WriteUart = 1'b1;
    ReadUart  = 1'b0;
    // wait (DUT.TxReady == 1);
    // wait (DUT.TxReady == 0);
    wait (TxFull == 1);
    WriteUart = 1'b0;
    ReadUart  = 1'b1;
    // wait (DUT.TxReady == 1);
    // wait (DUT.TxReady == 0);
    wait (TxFull == 0);

    WriteData = 8'h4A;
    WriteUart = 1'b1;
    ReadUart  = 1'b0;
    // wait (DUT.TxReady == 1);
    // wait (DUT.TxReady == 0);
    wait (TxFull == 1);
    WriteUart = 1'b0;
    ReadUart  = 1'b1;
    // wait (DUT.TxReady == 1);
    // wait (DUT.TxReady == 0);
    wait (TxFull == 0);

    WriteData = 8'hBB;
    WriteUart = 1'b1;
    ReadUart  = 1'b0;
    // wait (DUT.TxReady == 1);
    // wait (DUT.TxReady == 0);
    wait (TxFull == 1);
    WriteUart = 1'b0;
    ReadUart  = 1'b1;
    // wait (DUT.TxReady == 1);
    // wait (DUT.TxReady == 0);
    wait (TxFull == 0);
    #200;
    $stop;
  end

  initial begin
    $monitor(
        $time,,,,
        "TxFull=%b, TxReady=%b, RxData=%b, RxReady=%b, TxData=%b, TxFifoNotEmpty=%b, WriteData=%b, ReadData=%b, Tx=%b, RxEmpty=%b",
        TxFull, DUT.TxReady, DUT.RxData, DUT.RxReady, DUT.TxData, DUT.TxFifoNotEmpty, WriteData,
        ReadData, Tx, RxEmpty);
  end

endmodule
