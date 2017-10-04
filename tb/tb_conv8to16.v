`timescale 1ns/1ps


`define expect(_data16, _valid16, _ready8) \
	@(negedge clk) \
	if (_data16 !== data16 || _valid16 !== valid16 || _ready8 !== ready8) begin \
		$display("expectation not meat %m: data16: _data16 %h, valid16 _valid16 %b, ready8 _ready8 %b", data16, valid16, ready8); \
		$finish; \
	end


// https://github.com/makestuff/dvr-connectors/blob/master/conv-8to16/vhdl/tb_unit/stimulus.sim
module tb_conv_8to16();
	reg clk = 0;
	reg reset = 1;
	reg [7:0] data8;
	reg valid8;
	wire ready8;
	wire [15:0] data16;
	wire valid16;
	reg ready16;

	task stimulate(input [7:0] _data8, input _valid8, input _ready16);
		begin
		@(posedge clk) data8 <= _data8; valid8 <= _valid8; ready16 <= _ready16;
		end
	endtask

	always #10 clk = ~clk;

	initial begin
		$dumpfile("tb_conv_8to16.vcd");
		$dumpvars;
		@(posedge clk) reset = 0;

		stimulate(8'h12, 1, 1); // MSB
		`expect(16'hXXXX, 0, 1);
		stimulate(8'h34, 1, 1); // LSB
		`expect(16'h1234, 1, 1);

		// In the MSB state, we just register the incoming data, so ready16 is ignored
		stimulate(8'h56, 0, 0); // MSB
		`expect(16'hXXXX, 0, 1);
		stimulate(8'h56, 1, 0); // MSB
		`expect(16'hXXXX, 0, 1);

		// In the LSB state, both ready16 and valid8 have to be asserted
		stimulate(8'h78, 0, 0); // LSB
		`expect(16'h5678, 0, 0);
		stimulate(8'h78, 0, 1); // LSB
		`expect(16'h5678, 0, 1);
		stimulate(8'h78, 1, 0); // LSB
		`expect(16'h5678, 0, 0);
		stimulate(8'h78, 1, 1); // LSB
		`expect(16'h5678, 1, 1);

		// Should have 50% duty cycle in steady state
		stimulate(8'hAB, 1, 1);
		`expect(16'hXXXX, 0, 1);
		stimulate(8'hBC, 1, 1);
		`expect(16'hABBC, 1, 1);

		stimulate(8'hCD, 1, 1);
		`expect(16'hXXXX, 0, 1);
		stimulate(8'hDE, 1, 1);
		`expect(16'hCDDE, 1, 1);

		stimulate(8'hEF, 1, 1);
		`expect(16'hXXXX, 0, 1);
		stimulate(8'hF0, 1, 1);
		`expect(16'hEFF0, 1, 1);

		stimulate(8'h01, 1, 1);
		`expect(16'hXXXX, 0, 1);
		stimulate(8'h12, 1, 1);
		`expect(16'h0112, 1, 1);
		$finish;
	end

	CONV_8TO16 conv_8to16(
			.clk_in(clk),
			.reset_in(reset),
			.data8_in(data8),
			.valid8_in(valid8),
			.ready8_out(ready8),
			.data16_out(data16),
			.valid16_out(valid16),
			.ready16_in(ready16));

endmodule


