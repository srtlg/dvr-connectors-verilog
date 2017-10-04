`timescale 1ns/1ps


`define expect(_data24, _valid24, _ready8) \
	@(negedge clk) \
	if (_data24 !== data24 || _valid24 !== valid24 || _ready8 !== ready8) begin \
		$display("expectation not meat %m: data24: _data24 %h, valid24 _valid24 %b, ready8 _ready8 %b", data24, valid24, ready8); \
		$finish; \
	end


// https://github.com/makestuff/dvr-connectors/blob/master/conv-8to24/vhdl/tb_unit/stimulus.sim
module tb_conv_8to24();
	reg clk = 0;
	reg reset = 1;
	reg [7:0] data8;
	reg valid8;
	wire ready8;
	wire [23:0] data24;
	wire valid24;
	reg ready24;

	task stimulate(input [7:0] _data8, input _valid8, input _ready24);
		begin
		@(posedge clk) data8 <= _data8; valid8 <= _valid8; ready24 <= _ready24;
		end
	endtask

	always #10 clk = ~clk;

	initial begin
		$dumpfile("tb_conv_8to24.vcd");
		$dumpvars;
		@(posedge clk) reset = 0;

		stimulate(8'h12, 1, 1); // MSB
		`expect(24'hXXXXXX, 0, 1);
		stimulate(8'h34, 1, 1); // MID
		`expect(24'hXXXXXX, 0, 1);
		stimulate(8'h56, 1, 1); // LSB
		`expect(24'h123456, 1, 1);

		// In the MSB state, we just register the incoming data, so ready24 is ignored
		stimulate(8'h78, 0, 0); // MSB
		`expect(24'hXXXXXX, 0, 1);
		stimulate(8'h78, 1, 0); // MSB
		`expect(24'hXXXXXX, 0, 1);

		// In the MID state, we just register the incoming data, so ready24 is ignored
		stimulate(8'h9A, 0, 0); // MID
		`expect(24'hXXXXXX, 0, 1);
		stimulate(8'h9A, 1, 0); // MID
		`expect(24'hXXXXXX, 0, 1);

		// In the LSB state, both ready24 and valid8 have to be asserted
		stimulate(8'hBC, 0, 0); // LSB
		`expect(24'h789ABC, 0, 0);
		stimulate(8'hBC, 0, 1); // LSB
		`expect(24'h789ABC, 0, 1);
		stimulate(8'hBC, 1, 0); // LSB
		`expect(24'h789ABC, 0, 0);
		stimulate(8'hBC, 1, 1); // LSB
		`expect(24'h789ABC, 1, 1);

		// Should have 1/3 duty cycle in steady state
		stimulate(8'h12, 1, 1);
		`expect(24'hXXXXXX, 0, 1);
		stimulate(8'h34, 1, 1);
		`expect(24'hXXXXXX, 0, 1);
		stimulate(8'h56, 1, 1);
		`expect(24'h123456, 1, 1);

		stimulate(8'h78, 1, 1);
		`expect(24'hXXXXXX, 0, 1);
		stimulate(8'h9A, 1, 1);
		`expect(24'hXXXXXX, 0, 1);
		stimulate(8'hBC, 1, 1);
		`expect(24'h789ABC, 1, 1);

		stimulate(8'hDE, 1, 1);
		`expect(24'hXXXXXX, 0, 1);
		stimulate(8'hF0, 1, 1);
		`expect(24'hXXXXXX, 0, 1);
		stimulate(8'h12, 1, 1);
		`expect(24'hDEF012, 1, 1);

		stimulate(8'h34, 1, 1);
		`expect(24'hXXXXXX, 0, 1);
		stimulate(8'h56, 1, 1);
		`expect(24'hXXXXXX, 0, 1);
		stimulate(8'h78, 1, 1);
		`expect(24'h345678, 1, 1);

		$finish;
	end

	CONV_8TO24 conv_8to24(
			.clk_in(clk),
			.reset_in(reset),
			.data8_in(data8),
			.valid8_in(valid8),
			.ready8_out(ready8),
			.data24_out(data24),
			.valid24_out(valid24),
			.ready24_in(ready24));

endmodule

