/**
 * File              : TestUART.sv
 * Author            : Souleymane Dembele <sdembele@uw.edu>
 * Date              : 06.30.2023
 * Last Modified Date: 07.01.2023
 * Last Modified By  : Souleymane Dembele <sdembele@uw.edu>
 */

module TestUART (
    SW,
    LEDR,
    LEDG,
    CLOCK_50,
    KEY,
    HEX0,
    HEX1,
    HEX2,
    HEX3,
    GPIO,
);
  input [17:0] SW;
  input CLOCK_50;
  inout [1:0] GPIO;
  input [3:1]KEY;
  output [0:6] HEX0;
  output [0:6] HEX1;
  output [0:6] HEX2;
  output [0:6] HEX3;

  output [17:0] LEDR;
  output [4:0] LEDG;

  assign LEDR = SW;
  assign LEDG[3:1] = ~KEY[3:1];

  parameter DATA_BITS = 8;  // number of data bits
  parameter STOP_BIT_TICKS = 16;  // number of tick cycles for stop bit
  parameter BAUD_RATE = 19200;
  parameter CLOCK_RATE = 50000000;
  parameter SAMPLE_RATE = 16;
  parameter FIFO_WIDTH = 2;  // 2 bits for FIFO width

  wire ButtonOut, FilterOut, Strobe;
  wire [3:0] M0, M1, M2, M3;
  wire ReadUart, WriteUart, Rx;
  wire  [DATA_BITS-1:0] WriteData;
  wire [DATA_BITS-1:0] ReadData;
  wire Tx, TxFull, RxEmpty;

  // assign Rx = Tx;
  assign Rx = GPIO[1];
  assign GPIO[0] = Tx;

  assign WriteData = SW[7:0];

  assign M0 = WriteData[3:0];
  assign M1 = WriteData[7:4];

  assign M2 = ReadData[3:0];
  assign M3 = ReadData[7:4];

  assign LEDG[0] = TxFull;
  assign LEDG[4] = RxEmpty;

  // ButtonSyncReg: BS
  ButtonSyncReg BS (
      CLOCK_50,
      ~KEY[2],
      ButtonOut
  );
  // KeyFilter:Filter
  KeyFilter Filter (
      .Clock(CLOCK_50),
      .In(ButtonOut),
      .Out(FilterOut),
      .Strobe(Strobe)
  );
  assign ReadUart = FilterOut;
  assign WriteUart = FilterOut;

  Decoder Decoder0 (
      .C  (M0),
      .Hex(HEX0)
  );
  Decoder Decoder1 (
      .C  (M1),
      .Hex(HEX1)
  );
  Decoder Decoder2 (
      .C  (M2),
      .Hex(HEX2)
  );
  Decoder Decoder3 (
      .C  (M3),
      .Hex(HEX3)
  );

  UART #(
      .DATA_BITS(DATA_BITS),
      .STOP_BIT_TICKS(STOP_BIT_TICKS),
      .BAUD_RATE(BAUD_RATE),
      .CLOCK_RATE(CLOCK_RATE),
      .SAMPLE_RATE(SAMPLE_RATE),
      .FIFO_WIDTH(FIFO_WIDTH)
  ) DUT (
      .Clock(CLOCK_50),
      .ResetN(KEY[1]),
      .ReadUart(ReadUart),
      .WriteUart(WriteUart),
      .Rx(Rx),
      .Tx(Tx),
      .WriteData(WriteData),
      .ReadData(ReadData),
      .TxFull(TxFull),
      .RxEmpty(RxEmpty)
  );
endmodule
