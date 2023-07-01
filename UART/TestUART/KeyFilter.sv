/**
 * File              : KeyFilter.sv
 * Author            : Souleymane Dembele <sdembele@uw.edu>
 * Date              : 06.01.2023
 * Last Modified Date: 06.01.2023
 * Last Modified By  : Souleymane Dembele <sdembele@uw.edu>
 */
// KeyFilter follows a button synchronizer
// to deal with pushbutton debouncing
module KeyFilter (
    Clock,
    In,
    Out,
    Strobe
);
  input Clock;  // system clock
  input In;  // input signal
  output reg Out;  // a filtered version of In (one cycle on)
  output reg Strobe;  // true when inputs being read
  localparam DUR = 5_000_000 - 1;
  reg [32:0] Countdown = 0;
  always @(posedge Clock) begin
    Out <= 0;
    Strobe <= 0;
    if (Countdown == 0) begin
      Strobe <= 1;
      if (In) begin
        Out <= 1;
        Countdown <= DUR;
      end
    end else begin  // ignore inputs
      Countdown <= Countdown - 1;
    end
  end
endmodule

