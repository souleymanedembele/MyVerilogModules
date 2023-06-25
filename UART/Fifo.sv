/**
 * File              : Fifo.sv
 * Author            : Souleymane Dembele <sdembele@uw.edu>
 * Date              : 06.24.2023
 * Last Modified Date: 06.24.2023
 * Last Modified By  : Souleymane Dembele <sdembele@uw.edu>
 */
`ifndef FIFO_H
`define FIFO_H
module Fifo (
    Clock,
    ResetN,
    Read,
    Write,
    ReadData,
    WriteData,
    Empty,
    Full
);
  parameter WIDTH = 8;  // number of data bits in the FIFO
  parameter DEPTH = 4;  // number of address bits in the FIFO
  input Clock, ResetN, Read, Write;
  input [WIDTH-1:0] WriteData;
  output [WIDTH-1:0] ReadData;
  output Empty, Full;
  // signal declarations
  reg [WIDTH-1:0] arrayReg[2**DEPTH-1:0];  // register array (memory)
  reg [DEPTH-1:0] writePtr, nextWritePtr, writePtrSuccess;  // read and write pointers
  reg [DEPTH-1:0] readPtr, nextReadPtr, readPtrSuccess;  // next read and write pointers
  reg fullReg, emptyReg, nextFullReg, nextEmptyReg;  // full and empty flags

  wire writeEnable;  // write and read enable signals

  // register file write logic
  always_ff @(posedge Clock) begin
    if (writeEnable) begin
      arrayReg[writePtr] <= WriteData;
    end
  end
  // register file read logic
  assign ReadData = arrayReg[readPtr];
  // write enable logic
  assign writeEnable = Write & ~fullReg;
  // sequential logic
  always_ff @(posedge Clock) begin
    if (!ResetN) begin
      readPtr  <= 0;
      writePtr <= 0;
      fullReg  <= 0;
      emptyReg <= 1;
    end else begin
      readPtr  <= nextReadPtr;
      writePtr <= nextWritePtr;
      fullReg  <= nextFullReg;
      emptyReg <= nextEmptyReg;
    end
  end
  // combinational logic
  localparam READ = 2'b01, WRITE = 2'b10, READWRITE = 2'b11;
  always_comb begin
    writePtrSuccess = writePtr + 1;
    readPtrSuccess = readPtr + 1;
    // default assignments
    nextReadPtr = readPtr;
    nextWritePtr = writePtr;
    nextFullReg = fullReg;
    nextEmptyReg = emptyReg;
    case ({
      Write, Read
    })
      READ: begin
        if (!emptyReg) begin
          nextReadPtr = readPtrSuccess;
          nextFullReg = 0;
          if (readPtrSuccess == writePtr) begin
            nextEmptyReg = 1;
          end
        end
      end
      WRITE: begin
        if (!fullReg) begin
          nextWritePtr = writePtrSuccess;
          nextEmptyReg = 0;
          if (writePtrSuccess == readPtr) begin
            nextFullReg = 1;
          end
        end
      end
      READWRITE: begin
        nextReadPtr  = readPtrSuccess;
        nextWritePtr = writePtrSuccess;
      end
      default: begin
        nextReadPtr  = readPtr;
        nextWritePtr = writePtr;
        nextFullReg  = fullReg;
        nextEmptyReg = emptyReg;
      end
    endcase
  end
  assign Full  = fullReg;
  assign Empty = emptyReg;
endmodule
`endif

module Fifo_tb;
  reg Clock, ResetN, Read, Write;
  wire Empty, Full;
  parameter WIDTH = 8;
  parameter DEPTH = 2;
  reg  [WIDTH-1:0] WriteData;
  wire [WIDTH-1:0] ReadData;

  Fifo #(
      .WIDTH(WIDTH),
      .DEPTH(DEPTH)
  ) UUT (
      .Clock(Clock),
      .ResetN(ResetN),
      .Read(Read),
      .Write(Write),
      .ReadData(ReadData),
      .WriteData(WriteData),
      .Empty(Empty),
      .Full(Full)
  );

  always begin
    Clock = 0;
    #10;
    Clock = 1;
    #10;
  end

  initial begin
    ResetN = 0;
    WriteData = 8'h00;
    #20;
    ResetN = 1;
    #20;
    {Write, Read} = 2'b10;
    WriteData = 8'h01;
    #20;
    WriteData = 8'h02;
    #20;
    WriteData = 8'h03;
    #20;
    WriteData = 8'h04;
    #20;
    {Write, Read} = 2'b10;
    #40;
    $stop;
  end

  initial begin
    $monitor("WriteData=%h, ReadData=%h, Empty=%b, Full=%b, writePtrSuccess=%b, ", WriteData,
             ReadData, Empty, Full, UUT.writePtrSuccess);
  end

endmodule
