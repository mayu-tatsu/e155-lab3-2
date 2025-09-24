// testbench_sev_seg_sel.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-09-09

// Checks that seg1en, seg2en oscillate at the correct frequency, and that the
// output sw changes with it, depending on which enable is on. Outputs total
// number of tests and errors to the termina;.

// Note: Input onboard_sw and bboard_sw and output sw are all active low.

`timescale 1 ns / 1 ps

module testbench_sev_seg_sel();

	logic       clk, reset;
	logic [3:0] onboard_sw, bboard_sw;
	logic       seg1en, seg2en;
	logic [4:0] sw, sw_expected;
	
	logic [31:0] test_idx, errors;
	
	sev_seg_sel dut(clk, reset, onboard_sw, bboard_sw, seg1en, seg2en, sw);
	
	// generate a 100 Hz clk
	always
		begin
			clk = 1; #5; clk = 0; #5;
		end
		
	// reset
	initial
		begin
			test_idx = 0; errors = 0;
			reset = 0; #22; reset = 1;
		end
		
	initial begin
		// initialization
		#150000; onboard_sw = 4'b1111; bboard_sw = 4'b1111;
		
		for (int i = 0; i < 16; i++) begin
			
			// take the opposite of the last 4 digits
			onboard_sw = ~(i % 10000);
			
			for (int j = 0; j < 16; j++) begin
				
				bboard_sw = ~(j % 10000);
				#10; 
				if (seg2en) begin
					if (bboard_sw === 4'b1111) sw_expected = 4'b1111;
					else if (bboard_sw === 4'b1110) sw_expected = 4'b1110;
					else if (bboard_sw === 4'b1101) sw_expected = 4'b1101;
					else if (bboard_sw === 4'b1100) sw_expected = 4'b1100;
					else if (bboard_sw === 4'b1011) sw_expected = 4'b1011;
					else if (bboard_sw === 4'b1010) sw_expected = 4'b1010;
					else if (bboard_sw === 4'b1001) sw_expected = 4'b1001;
					else if (bboard_sw === 4'b1000) sw_expected = 4'b1000;
					else if (bboard_sw === 4'b0111) sw_expected = 4'b0111;
					else if (bboard_sw === 4'b0110) sw_expected = 4'b0110;
					else if (bboard_sw === 4'b0101) sw_expected = 4'b0101;
					else if (bboard_sw === 4'b0100) sw_expected = 4'b0100;
					else if (bboard_sw === 4'b0011) sw_expected = 4'b0011;
					else if (bboard_sw === 4'b0010) sw_expected = 4'b0010;
					else if (bboard_sw === 4'b0001) sw_expected = 4'b0001;
					else if (bboard_sw === 4'b0000) sw_expected = 4'b0000;
				end else begin
					if (onboard_sw === 4'b1111) sw_expected = 4'b1111;
					else if (onboard_sw === 4'b1110) sw_expected = 4'b1110;
					else if (onboard_sw === 4'b1101) sw_expected = 4'b1101;
					else if (onboard_sw === 4'b1100) sw_expected = 4'b1100;
					else if (onboard_sw === 4'b1011) sw_expected = 4'b1011;
					else if (onboard_sw === 4'b1010) sw_expected = 4'b1010;
					else if (onboard_sw === 4'b1001) sw_expected = 4'b1001;
					else if (onboard_sw === 4'b1000) sw_expected = 4'b1000;
					else if (onboard_sw === 4'b0111) sw_expected = 4'b0111;
					else if (onboard_sw === 4'b0110) sw_expected = 4'b0110;
					else if (onboard_sw === 4'b0101) sw_expected = 4'b0101;
					else if (onboard_sw === 4'b0100) sw_expected = 4'b0100;
					else if (onboard_sw === 4'b0011) sw_expected = 4'b0011;
					else if (onboard_sw === 4'b0010) sw_expected = 4'b0010;
					else if (onboard_sw === 4'b0001) sw_expected = 4'b0001;
					else if (onboard_sw === 4'b0000) sw_expected = 4'b0000;
				end
				
				assert(seg1en === 1'b0) else begin $display("Fail: seg1en = ON, expected: OFF. Inputs: onb: %b, bb: %b", onboard_sw, bboard_sw); errors = errors + 1; end
				assert(seg2en === 1'b1) else begin $display("Fail: seg2en = OFF, expected: ON. Inputs: onb: %b, bb: %b", onboard_sw, bboard_sw); errors = errors + 1; end
				assert(sw === sw_expected) else begin $display("Fail: sw = %b, expected = %b. Inputs: onb: %b, bb: %b", sw, sw_expected, onboard_sw, bboard_sw); errors = errors + 1; end
				
				#300000;
				if (seg1en) begin
					if (onboard_sw === 4'b1111) sw_expected = 4'b1111;
					else if (onboard_sw === 4'b1110) sw_expected = 4'b1110;
					else if (onboard_sw === 4'b1101) sw_expected = 4'b1101;
					else if (onboard_sw === 4'b1100) sw_expected = 4'b1100;
					else if (onboard_sw === 4'b1011) sw_expected = 4'b1011;
					else if (onboard_sw === 4'b1010) sw_expected = 4'b1010;
					else if (onboard_sw === 4'b1001) sw_expected = 4'b1001;
					else if (onboard_sw === 4'b1000) sw_expected = 4'b1000;
					else if (onboard_sw === 4'b0111) sw_expected = 4'b0111;
					else if (onboard_sw === 4'b0110) sw_expected = 4'b0110;
					else if (onboard_sw === 4'b0101) sw_expected = 4'b0101;
					else if (onboard_sw === 4'b0100) sw_expected = 4'b0100;
					else if (onboard_sw === 4'b0011) sw_expected = 4'b0011;
					else if (onboard_sw === 4'b0010) sw_expected = 4'b0010;
					else if (onboard_sw === 4'b0001) sw_expected = 4'b0001;
					else if (onboard_sw === 4'b0000) sw_expected = 4'b0000;
				end else begin
					if (bboard_sw === 4'b1111) sw_expected = 4'b1111;
					else if (bboard_sw === 4'b1110) sw_expected = 4'b1110;
					else if (bboard_sw === 4'b1101) sw_expected = 4'b1101;
					else if (bboard_sw === 4'b1100) sw_expected = 4'b1100;
					else if (bboard_sw === 4'b1011) sw_expected = 4'b1011;
					else if (bboard_sw === 4'b1010) sw_expected = 4'b1010;
					else if (bboard_sw === 4'b1001) sw_expected = 4'b1001;
					else if (bboard_sw === 4'b1000) sw_expected = 4'b1000;
					else if (bboard_sw === 4'b0111) sw_expected = 4'b0111;
					else if (bboard_sw === 4'b0110) sw_expected = 4'b0110;
					else if (bboard_sw === 4'b0101) sw_expected = 4'b0101;
					else if (bboard_sw === 4'b0100) sw_expected = 4'b0100;
					else if (bboard_sw === 4'b0011) sw_expected = 4'b0011;
					else if (bboard_sw === 4'b0010) sw_expected = 4'b0010;
					else if (bboard_sw === 4'b0001) sw_expected = 4'b0001;
					else if (bboard_sw === 4'b0000) sw_expected = 4'b0000;
				end
				
				assert(seg1en === 1'b1) else begin $display("Fail: seg1en = OFF, expected: ON. Inputs: onb = %b, bb = %b", onboard_sw, bboard_sw); errors = errors + 1; end
				assert(seg2en === 1'b0) else begin $display("Fail: seg2en = ON, expected: OFF. Inputs: onb = %b, bb = %b", onboard_sw, bboard_sw); errors = errors + 1; end
				assert(sw === sw_expected) else begin $display("Fail: sw = %b, expected = %b. Inputs: onb: %b, bb: %b", sw, sw_expected, onboard_sw, bboard_sw); errors = errors + 1; end
						
				#300000; test_idx++;
			end
		end
		
		$display("Completed %d tests with %d errors", test_idx, errors);
		$stop;
	end	
endmodule