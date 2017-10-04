// File conv_8to24.vhdl translated with vhd2vl v2.5 VHDL to Verilog RTL translator
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
// Copyright (C) 2013 Joel Pérez Izquierdo
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
//	Modified from conv_8to16.vhdl by Chris McClelland
//
`timescale 1ns/1ps

module CONV_8TO24(
input wire clk_in,
input wire reset_in,
input wire [7:0] data8_in,
input wire valid8_in,
output reg ready8_out,
output reg [23:0] data24_out,
output reg valid24_out,
input wire ready24_in
);

// System clock
// 8-bit data coming in
// 24-bit data going out



parameter [1:0]
  S_WAIT_MSB = 0,
  S_WAIT_MID = 1,
  S_WAIT_LSB = 2;

reg [1:0] state = S_WAIT_MSB;
reg [1:0] state_next;
reg [7:0] msb = 0;
reg [7:0] msb_next;
reg [7:0] mid = 0;
reg [7:0] mid_next;

  // Infer registers
  always @(posedge clk_in) begin
    if((reset_in == 1'b 1)) begin
      state <= S_WAIT_MSB;
      msb <= {8{1'b0}};
      mid <= {8{1'b0}};
    end
    else begin
      state <= state_next;
      msb <= msb_next;
      mid <= mid_next;
    end
  end

  // Next state logic
  always @(state or msb or mid or data8_in or valid8_in or ready24_in) begin
    state_next <= state;
    msb_next <= msb;
    mid_next <= mid;
    valid24_out <= 1'b 0;
    case(state)
        // Wait for the LSB to arrive:
    S_WAIT_LSB : begin
      ready8_out <= ready24_in;
      // ready for data from 8-bit side
      data24_out <= {msb,mid,data8_in};
      if((valid8_in == 1'b 1 && ready24_in == 1'b 1)) begin
        valid24_out <= 1'b 1;
        state_next <= S_WAIT_MSB;
      end
      // Wait for the mid byte to arrive:
    end
    S_WAIT_MID : begin
      ready8_out <= 1'b 1;
      // ready for data from 8-bit side
      data24_out <= {24{1'bX}};
      if((valid8_in == 1'b 1)) begin
        mid_next <= data8_in;
        state_next <= S_WAIT_LSB;
      end
      // Wait for the MSB to arrive:
    end
    default : begin
      ready8_out <= 1'b 1;
      // ready for data from 8-bit side
      data24_out <= {24{1'bX}};
      if((valid8_in == 1'b 1)) begin
        msb_next <= data8_in;
        state_next <= S_WAIT_MID;
      end
    end
    endcase
  end


endmodule
