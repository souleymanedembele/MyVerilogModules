/**
 * File              : CounterModuloN.sv
 * Author            : Souleymane Dembele <sdembele@uw.edu>
 * Date              : 06.18.2023
 * Last Modified Date: 06.30.2023
 * Last Modified By  : Souleymane Dembele <sdembele@uw.edu>
 */
// This module implements a counter modulo N
// The counter is incremented by 1 at each clock cycle
// The counter is reset to 0 when ClearN is asserted
// The counter is incremented by 1 when Enable is asserted
`ifndef COUNTERMODULON_H
`define COUNTERMODULON_H
module CounterModuloN (
    Enable,  // Enable input
    Clock,  // Clock input
    ClearN,  // ClearN input
    Q,  // Q output
);
  parameter N = 10;
  localparam NUM_BITS = $clog2(N); // Number of bits required to represent N
  localparam STOP_VALUE = N - 1;
  input Enable, Clock, ClearN;
  output reg [NUM_BITS-1:0] Q;

  always @(posedge Clock) begin
    if (!ClearN) begin
      Q  <= 0;
    end else if (Enable && Q < STOP_VALUE) begin
      Q <= Q + 1;
    end else if (Enable && Q == STOP_VALUE) begin
      Q <= 0;
    end
  end
endmodule

module CounterModuloN_tb;
  reg Enable, Clock, ClearN;
  parameter N = 16;
  localparam NUM_BITS = $clog2(N); // Number of bits required to represent N
  wire [NUM_BITS-1:0] Q;

  CounterModuloN #(.N(N)) CounterModuloN (
      .Enable(Enable),
      .Clock(Clock),
      .ClearN(ClearN),
      .Q(Q)
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
    #400;
    $stop;
  end

  initial $monitor($time,,,,"Enable=%d, ClearN=%d, Q=%d", Enable, ClearN, Q);
endmodule
`endif
