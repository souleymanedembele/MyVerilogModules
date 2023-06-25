/**
 * File              : Receiver.sv
 * Author            : Souleymane Dembele <sdembele@uw.edu>
 * Date              : 06.18.2023
 * Last Modified Date: 06.24.2023
 * Last Modified By  : Souleymane Dembele <sdembele@uw.edu>
 */
`ifndef RECEIVER_H
`define RECEIVER_H
// this is the UART RX module
module Receiver (
    Clock, // input clock signal (50MHz)
    ResetN, // input reset signal (active low)
    Rx, // input UART RX signal
    Tick, // input tick signal from the baud rate generator
    RxReady, // output signal indicating that a byte has been received
    RxData, // output byte received
);
parameter DATA_BITS = 8; // number of data bits
parameter STOP_BIT_TICKS = 16; // number of tick cycles for stop bit

input Clock;
input ResetN;
input Rx;
input Tick;
output RxReady;
output [DATA_BITS-1:0] RxData;

reg RxReady;
// internal signals
reg [2:0] CurrentState, NextState;
// number of sampling ticks counter to 7 in start and 15 in data
reg [3:0] TickCounter, NextTickCounter;
// number of data bits received counter
reg [2:0] DataCounter, NextDataCounter;
// retrieved data bits shift register
reg [7:0] DataBits, NextDataBits;
// state machine states
// IDLE: waiting for start bit
// START: start bit detected
// DATA: receiving data bits
// STOP: waiting for stop bit
localparam IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;
// always ff block
always_ff @(posedge Clock)
begin
    if (!ResetN)
    begin
        CurrentState <= IDLE;
        TickCounter <= 0;
        DataCounter <= 0;
        DataBits <= 0;
    end
    else
    begin
        CurrentState <= NextState;
        TickCounter <= NextTickCounter;
        DataCounter <= NextDataCounter;
        DataBits <= NextDataBits;
    end
end
// always comb block
// next state logic
always_comb begin
  NextState = CurrentState;
  RxReady = 1'b0;
  NextTickCounter = TickCounter;
  NextDataCounter = DataCounter;
  NextDataBits = DataBits;
    case (CurrentState)
        IDLE: begin
            if (Rx == 0) begin
                NextState = START;
                NextTickCounter = 0;
            end
        end
        START: begin
          if(Tick) begin
            if (TickCounter == DATA_BITS-1) begin
                NextState = DATA;
                NextTickCounter = 0;
                NextDataCounter = 0;
                end else begin
          NextTickCounter = TickCounter + 1;
          NextState = START;
          end 
        end else begin
          NextState = START;
          end 
        end 
        DATA: begin
          if(Tick) begin
            if (TickCounter == STOP_BIT_TICKS-1) begin
              NextTickCounter = 0;
              NextDataBits = {Rx, DataBits[7:1]};
              if (DataCounter == DATA_BITS-1) begin
                NextState = STOP;
              end else begin
                NextDataCounter = DataCounter + 1;
                NextState = DATA;
              end
                end else begin
            NextTickCounter = TickCounter + 1;
            NextState = DATA;
          end
          end else begin
            NextState = DATA;
          end
        end
        STOP: begin
          if(Tick) begin
            if (TickCounter == STOP_BIT_TICKS-1) begin
              NextState = IDLE;
              RxReady = 1'b1;
            end  else begin
            NextTickCounter = TickCounter + 1;
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
assign RxData = DataBits;
endmodule
`endif

module Receiver_tb;
reg Clock, ResetN, Rx, Tick;
wire RxReady;
wire [7:0] RxData;
Receiver receiver (
    .Clock(Clock),
    .ResetN(ResetN),
    .Rx(Rx),
    .Tick(Tick),
    .RxReady(RxReady),
    .RxData(RxData)
);

always begin
  Clock = 1'b0;
  #10;
  Clock = 1'b1;
  #10;
end

always begin
  Tick = 1'b0;
  #460;
  Tick = 1'b1;
  #20;
end

initial begin
  ResetN = 1'b0;
  Rx = 1'b0;
  #20;
  ResetN = 1'b1;
  #20;
  Rx = 1'b1;  
  wait(RxData == 8'b10000000);
  Rx = 1'b0;
  wait(RxData == 8'b01000000);
  Rx = 1'b1;
  wait(RxData == 8'b10100000);
  Rx = 1'b0;
  wait(RxData == 8'b01010000);
  Rx = 1'b1;
  wait(RxData == 8'b10101000);
  Rx = 1'b0;
  wait(RxData == 8'b01010100);
  Rx = 1'b1;
  wait(RxData == 8'b10101010);
  Rx = 1'b0;
  wait(RxData == 8'b01010101);
  Rx = 1'b1;
  wait(RxReady == 1'b1);
  wait(RxReady == 1'b0);
  Rx = 1'b0;
  wait(RxData == 8'b01010101);
  Rx = 1'b0;
  wait(RxData == 8'b00010101);
  Rx = 1'b1;
  wait(RxData == 8'b10001010);
  Rx = 1'b0;
  wait(RxData == 8'b01000101);
  Rx = 1'b1;
  wait(RxData == 8'b10100010);
  Rx = 1'b0;
  wait(RxData == 8'b01010001);
  Rx = 1'b1;
  wait(RxData == 8'b10101000);
  Rx = 1'b0;
  wait(RxData == 8'b01010100);
  wait(RxReady == 1'b1);
  wait(RxReady == 1'b0);
  $stop;
end

initial begin
  $monitor("RxReady=%b RxData=%b CurrentState=%d TickCounter=%d", RxReady, RxData, receiver.CurrentState, receiver.TickCounter);
end

endmodule
