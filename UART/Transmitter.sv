/**
 * File              : Transmitter.sv
 * Author            : Souleymane Dembele <sdembele@uw.edu>
 * Date              : 06.24.2023
 * Last Modified Date: 06.24.2023
 * Last Modified By  : Souleymane Dembele <sdembele@uw.edu>
 */
`ifndef TRANSMITTER_H
`define TRANSMITTER_H
module Transmitter (
    Clock,  // input clock signal (50MHz)
    ResetN,  // input reset signal (active low)
    Tick,  // input tick signal from the baud rate generator
    TxStart,  // input start transmission signal
    DataIn,  // input data byte
    Tx,  // output UART TX signal
    TxReady  // output ready signal
);
  parameter DATA_BITS = 8;  // number of data bits
  parameter STOP_BIT_TICKS = 16;  // number of tick cycles for stop bit

  input Clock;
  input ResetN;
  input Tick;
  input TxStart;
  input [DATA_BITS-1:0] DataIn;
  output Tx;
  output reg TxReady;

  // state machine states
  localparam IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;
  reg [1:0] CurrentState, NextState;
  reg [3:0] TickCount, NextTickCount;
  reg [2:0] DataCount, NextDataCount;
  reg [DATA_BITS-1:0] Data, NextData;
  reg CurrentTx, NextTx;

  // state machine
  always_ff @(posedge Clock, negedge ResetN) begin
    if (!ResetN) begin
      CurrentState <= IDLE;
      TickCount <= 0;
      DataCount <= 0;
      Data <= 0;
      CurrentTx <= 1;
    end else begin
      CurrentState <= NextState;
      TickCount <= NextTickCount;
      DataCount <= NextDataCount;
      Data <= NextData;
      CurrentTx <= NextTx;
    end
  end

  // next state logic
  always_comb begin
    NextState = CurrentState;
    NextTickCount = TickCount;
    NextDataCount = DataCount;
    NextData = Data;
    NextTx = CurrentTx;
    TxReady = 0;
    // case statement for state machine
    case (CurrentState)
      IDLE: begin
        NextTx = 1;
        if (TxStart) begin
          NextState = START;
          NextTickCount = 0;
          NextData = DataIn;
        end
      end
      START: begin
        NextTx = 0;
        if (Tick) begin
          if (TickCount == STOP_BIT_TICKS - 1) begin
            NextState = DATA;
            NextTickCount = 0;
            NextDataCount = 0;
          end else begin
            NextTickCount = TickCount + 1;
            NextState = START;
          end
        end else begin
          NextState = START;
        end
      end
      DATA: begin
        NextTx = Data[0];
        if (Tick) begin
          if (TickCount == STOP_BIT_TICKS - 1) begin
            NextTickCount = 0;
            NextData = Data >> 1;
            if (DataCount == DATA_BITS - 1) begin
              NextState = STOP;
            end else begin
              NextDataCount = DataCount + 1;
            end
          end else begin
            NextTickCount = TickCount + 1;
            NextState = DATA;
          end
        end else begin
          NextState = DATA;
        end
      end
      STOP: begin
        NextTx = 1;
        if (Tick) begin
          if (TickCount == STOP_BIT_TICKS - 1) begin
            NextState = IDLE;
            TxReady   = 1;
          end else begin
            NextTickCount = TickCount + 1;
            NextState = STOP;
          end
        end else begin
          NextState = STOP;
        end
      end
      default: begin
        NextState = IDLE;
      end
    endcase
  end

  assign Tx = CurrentTx;

endmodule
`endif

module Transmitter_tb ();
  reg Clock, ResetN, Tick, TxStart;
  reg [7:0] DataIn;
  wire Tx, TxReady;

  Transmitter UUT (
      .Clock(Clock),
      .ResetN(ResetN),
      .Tick(Tick),
      .TxStart(TxStart),
      .DataIn(DataIn),
      .Tx(Tx),
      .TxReady(TxReady)
  );

  always begin
    Clock = 0;
    #10;
    Clock = 1;
    #10;
  end

  always begin
    Tick = 0;
    #460;
    Tick = 1;
    #20;
  end

  initial begin
    ResetN  = 0;
    TxStart = 0;
    DataIn  = 8'hAA;
    #20;
    TxStart = 1;
    ResetN  = 1;
    wait (Tx == 1);
    wait (Tx == 0);
    wait (Tx == 1);
    wait (Tx == 0);

    wait (Tx == 1);
    wait (Tx == 0);
    wait (Tx == 1);
    wait (Tx == 0);

    wait (TxReady == 1);
    wait (TxReady == 0);

    TxStart = 0;
    #10;
    TxStart = 1;
    DataIn  = 8'hff;
    wait (Tx == 1);
    wait (Tx == 1);
    wait (Tx == 1);
    wait (Tx == 1);

    wait (Tx == 1);
    wait (Tx == 1);
    wait (Tx == 1);
    wait (Tx == 1);

    wait (TxReady == 1);
    wait (TxReady == 0);
    #20 $stop;
  end

  initial begin
    $monitor("DataIn=%b, Tx=%b, TxReady=%b", DataIn, Tx, TxReady);
  end
endmodule
