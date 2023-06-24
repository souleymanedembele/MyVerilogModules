/**
 * File              : ReceiverInterface.sv
 * Author            : Souleymane Dembele <sdembele@uw.edu>
 * Date              : 06.24.2023
 * Last Modified Date: 06.24.2023
 * Last Modified By  : Souleymane Dembele <sdembele@uw.edu>
 */

module ReceiverInterface (
    Clock,  // Clock
    ResetN,
    DataIn,
    DataOut,
    SetFlag,
    ClearFlag,
    Flag
);
  parameter WORD_SIZE = 8;
  input Clock;
  input ResetN;
  input [WORD_SIZE-1:0] DataIn;
  output [WORD_SIZE-1:0] DataOut;
  input SetFlag;
  input ClearFlag;
  output Flag;

  // state machine
  reg [WORD_SIZE-1:0] CurrentBuffer, NextBuffer;
  reg CurrentFlag, NextFlag;

  always_ff @(posedge Clock) begin
    if (!ResetN) begin
      CurrentBuffer <= 0;
      CurrentFlag   <= 0;
    end else begin
      CurrentBuffer <= NextBuffer;
      CurrentFlag   <= NextFlag;
    end
  end

  always_comb begin
    NextBuffer = CurrentBuffer;
    NextFlag   = Flag;
    if (SetFlag) begin
      NextBuffer = DataIn;
      NextFlag   = 1;
    end else if (ClearFlag) begin
      NextFlag = 0;
    end
  end

  assign DataOut = CurrentBuffer;
  assign Flag = CurrentFlag;
endmodule

module ReceiverInterface_tb;
  reg Clock, ResetN, SetFlag, ClearFlag;
  reg [7:0] DataIn;

  wire [7:0] DataOut;
  wire Flag;

  ReceiverInterface ReceiverInterface (
      .Clock(Clock),
      .ResetN(ResetN),
      .DataIn(DataIn),
      .DataOut(DataOut),
      .SetFlag(SetFlag),
      .ClearFlag(ClearFlag),
      .Flag(Flag)
  );

  always begin
    Clock = 0;
    #10;
    Clock = 1;
    #10;
  end
  initial begin
    DataIn = 8'hAA;
    ResetN = 0;
    SetFlag = 0;
    ClearFlag = 0;
    #20;
    ResetN = 1;
    #20;
    SetFlag = 1;
    #20;
    SetFlag = 0;
    #20;
    ClearFlag = 1;
    #20;
    ClearFlag = 0;
    #20;
    $stop;
  end

  initial begin
    $monitor("DataOut = %h, Flag = %b", DataOut, Flag);
  end
endmodule
