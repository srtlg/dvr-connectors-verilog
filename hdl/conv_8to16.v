// File conv_8to16.vhdl translated with vhd2vl v2.5 VHDL to Verilog RTL translator
// vhd2vl settings:
//  * Verilog Module Declaration Style: 2001

// vhd2vl is Free (libre) Software:
//   Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd
//     http://www.ocean-logic.com
//   Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//   Modifications (C) 2010 Shankar Giri
//   Modifications Copyright (C) 2002, 2005, 2008-2010, 2015 Larry Doolittle - LBNL
//     http://doolittle.icarus.com/~larry/vhd2vl/
//
//   vhd2vl comes with ABSOLUTELY NO WARRANTY.  Always check the resulting
//   Verilog for correctness, ideally with a formal verification tool.
//
//   You are welcome to redistribute vhd2vl under certain conditions.
//   See the license (GPLv2) file included with the source for details.

// The result of translation follows.  Its copyright status should be
// considered unchanged from the original VHDL.

//
// Copyright (C) 2012 Chris McClelland
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
`timescale 1ns/1ps

module CONV_8TO16(
// System clock
input wire clk_in,
input wire reset_in,
// 8-bit data coming in
input wire [7:0] data8_in,
input wire valid8_in,
output reg ready8_out,
// 16-bit data going out
output reg [15:0] data16_out,
output reg valid16_out,
input wire ready16_in
);

parameter [0:0]
  S_WAIT_MSB = 0,
  S_WAIT_LSB = 1;

reg state = S_WAIT_MSB;
reg state_next;
reg [7:0] msb = 0;
reg [7:0] msb_next;

  // Infer registers
  always @(posedge clk_in) begin
    if((reset_in == 1'b 1)) begin
      state <= S_WAIT_MSB;
      msb <= 8'b00;
    end
    else begin
      state <= state_next;
      msb <= msb_next;
    end
  end

  // Next state logic
  //process(state, msb, data8_in, valid8_in)
  always @(state or msb or data8_in or valid8_in or ready16_in) begin
    state_next <= state;
    msb_next <= msb;
    valid16_out <= 1'b 0;
    case(state)
        // Wait for the LSB to arrive:
    S_WAIT_LSB : begin
      ready8_out <= ready16_in;
      // ready for data from 8-bit side
      data16_out <= {msb,data8_in};
      if((valid8_in == 1'b 1 && ready16_in == 1'b 1)) begin
        valid16_out <= 1'b 1;
        state_next <= S_WAIT_MSB;
      end
      // Wait for the MSB to arrive:
    end
    default : begin
      ready8_out <= 1'b 1;
      // ready for data from 8-bit side
      data16_out <= {16{1'bX}};
      if((valid8_in == 1'b 1)) begin
        msb_next <= data8_in;
        state_next <= S_WAIT_LSB;
      end
    end
    endcase
  end


endmodule
