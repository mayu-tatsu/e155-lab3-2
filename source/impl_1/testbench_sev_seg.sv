// testbench_sev_seg.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-09-09

// Compares outputs of sev_seg module to expected values
// using asserts. Outputs if any errors exist.

// Note: Input and output are active low.

`timescale 1 ns / 1 ps

module testbench_sev_seg();

	logic       clk, reset;
	logic [3:0] s;
	logic [6:0] seg;

	logic [31:0] test_idx, errors;

	sev_seg dut(s, seg);

	// clock generation
	always
		begin
			clk = 1; #5; clk = 0; #5;
		end

	// load vectors and pulse reset
	initial
		begin
			test_idx = 0; errors = 0;
			reset = 1; #22 reset = 0;
		end

	initial
		begin
			s = 4'b1111; #10;
			assert (seg === 7'b1000000) else begin $display("Fail: Output = %b, expected = 1000000. Input: s = 1111.", seg); errors = errors + 1; end
			s = 4'b1110; #10;
			assert (seg === 7'b1111001) else begin $display("Fail: Output = %b, expected = 1111001. Input: s = 1110.", seg); errors = errors + 1; end
			s = 4'b1101; #10;
			assert (seg === 7'b0100100) else begin $display("Fail: Output = %b, expected = 0100100. Input: s = 1101.", seg); errors = errors + 1; end
			s = 4'b1100; #10;
			assert (seg === 7'b0110000) else begin $display("Fail: Output = %b, expected = 0110000. Input: s = 1100.", seg); errors = errors + 1; end
			s = 4'b1011; #10;
			assert (seg === 7'b0011001) else begin $display("Fail: Output = %b, expected = 0011001. Input: s = 1011.", seg); errors = errors + 1; end
			s = 4'b1010; #10;
			assert (seg === 7'b0010010) else begin $display("Fail: Output = %b, expected = 0010010. Input: s = 1010.", seg); errors = errors + 1; end
			s = 4'b1001; #10;
			assert (seg === 7'b0000010) else begin $display("Fail: Output = %b, expected = 0000010. Input: s = 1001.", seg); errors = errors + 1; end
			s = 4'b1000; #10;
			assert (seg === 7'b1111000) else begin $display("Fail: Output = %b, expected = 1111000. Input: s = 1000.", seg); errors = errors + 1; end
			s = 4'b0110; #10;
			assert (seg === 7'b0011000) else begin $display("Fail: Output = %b, expected = 0011000. Input: s = 0110.", seg); errors = errors + 1; end
			s = 4'b0101; #10;
			assert (seg === 7'b0001000) else begin $display("Fail: Output = %b, expected = 0001000. Input: s = 0101.", seg); errors = errors + 1; end
			s = 4'b0100; #10;
			assert (seg === 7'b0000011) else begin $display("Fail: Output = %b, expected = 0000011. Input: s = 0100.", seg); errors = errors + 1; end
			s = 4'b0011; #10;
			assert (seg === 7'b1000110) else begin $display("Fail: Output = %b, expected = 1000110. Input: s = 0011.", seg); errors = errors + 1; end
			s = 4'b0010; #10;
			assert (seg === 7'b0100001) else begin $display("Fail: Output = %b, expected = 0100001. Input: s = 0010.", seg); errors = errors + 1; end
			s = 4'b0001; #10;
			assert (seg === 7'b0000110) else begin $display("Fail: Output = %b, expected = 0000110. Input: s = 0001.", seg); errors = errors + 1; end
			s = 4'b0000; #10;
			assert (seg === 7'b0001110) else begin $display("Fail: Output = %b, expected = 0001110. Input: s = 0000.", seg); errors = errors + 1; end
			
			$display("All tests completed with %d errors", errors);
			$stop;
		end
endmodule