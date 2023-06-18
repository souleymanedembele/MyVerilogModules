/**
 * File              : BaudRateGenerator.sv
 * Author            : Souleymane Dembele <sdembele@uw.edu>
 * Date              : 06.18.2023
 * Last Modified Date: 06.18.2023
 * Last Modified By  : Souleymane Dembele <sdembele@uw.edu>
 */
`ifndef BAUD_RATE_GENERATOR_H
`define BAUD_RATE_GENERATOR_H
`include "CounterModuloN.sv"
module BaudRateGenerator (
    Clock,
    Enable,
    ClearN,
    ClockTick
);
  input Clock, Enable, ClearN;
  output ClockTick;
  parameter BAUD_RATE = 9600;
  parameter CLOCK_RATE = 50000000;
  parameter SAMPLE_RATE = 16;
  // round up to the nearest integer
  localparam BAUD_RATE_DIVISOR = CLOCK_RATE / (BAUD_RATE * SAMPLE_RATE) + 1;
  localparam NUM_BITS = $clog2(BAUD_RATE_DIVISOR);
  wire [NUM_BITS-1:0] Q;
  // Instantiate the counter module
  CounterModuloN #(
      .N(BAUD_RATE_DIVISOR)
  ) Counter (
      .Enable(Enable),
      .Clock(Clock),
      .ClearN(ClearN),
      .Q(Q)
  );
  assign ClockTick = Q == BAUD_RATE_DIVISOR - 1 ? 1'b1 : 1'b0;
endmodule
`endif

module BaudRateGenerator_tb ();
  reg Enable, Clock, ClearN;
  wire ClockTick;
  localparam BAUD_RATE = 19200;
  localparam CLOCK_RATE = 50000000;
  localparam SAMPLE_RATE = 16;

  BaudRateGenerator #(
      .BAUD_RATE  (BAUD_RATE),
      .CLOCK_RATE (CLOCK_RATE),
      .SAMPLE_RATE(SAMPLE_RATE)
  ) DUT (
      .Enable(Enable),
      .Clock(Clock),
      .ClearN(ClearN),
      .ClockTick(ClockTick)
  );

  always begin
    Clock = 0;
    #10;
    Clock = 1;
    #10;
  end

  initial begin
    Enable = 0;
    ClearN = 0;
    #10;
    Enable = 1;
    #10;
    ClearN = 1;
    #500000;
    $stop;
  end

  initial begin
    $monitor("ClockTick = %b, Q=%d", ClockTick, DUT.Q);
  end
endmodule
