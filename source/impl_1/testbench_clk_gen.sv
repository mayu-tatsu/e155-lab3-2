// testbench_clk_gen.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-10-29
//
// Checks that the clk_gen module produces 100 Hz and 10 kHz clock signals
// with approximately correct timing ratios based on the 48 MHz source clock.
// Measures and verifies both frequencies and duty cycles by counting simulation time.
// Outputs total number of tests and errors to the terminal.

`timescale 1 ns / 1 ps

module testbench_clk_gen();

	logic reset;
	logic clk_100hz, clk_10khz;

	logic [31:0] test_idx, errors;
	time t_rise_100hz_1, t_rise_100hz_2, t_fall_100hz;
	time t_rise_10khz_1, t_rise_10khz_2, t_fall_10khz;
	real period_100hz, period_10khz;
    real t_high_100hz, t_high_10khz;

	clk_gen dut(reset, clk_100hz, clk_10khz);

	initial begin
		test_idx = 0;
		errors = 0;
		reset = 0; #50; reset = 1;
	end

	initial begin
		real ratio;
        real expected_t_high_100hz;
        real expected_t_high_10khz; 

		#100; // wait

		// measuring time
		@(posedge clk_100hz);
		t_rise_100hz_1 = $time;
        @(negedge clk_100hz);
        t_fall_100hz = $time;
		@(posedge clk_100hz);
		t_rise_100hz_2 = $time;
        
		period_100hz = t_rise_100hz_2 - t_rise_100hz_1;
        t_high_100hz = t_fall_100hz - t_rise_100hz_1;
		
        // expected period = 10,000,000 ns = 10 ms
        expected_t_high_100hz = 10_000_000.0 / 2.0; // 50% duty cycle = 5 ms

        // period
		test_idx++;
		if ((period_100hz < 9.9e6) || (period_100hz > 10.1e6)) begin
			$display("Fail: clk_100hz period = %0.2f ns, expected ~10,000,000 ns", period_100hz);
			errors = errors + 1;
		end else begin
			$display("Pass: clk_100hz period = %0.2f ns (within tolerance)", period_100hz);
		end
        
        // 100hz high
        test_idx++;
		if ((t_high_100hz < expected_t_high_100hz * 0.99) || (t_high_100hz > expected_t_high_100hz * 1.01)) begin
			$display("Fail: clk_100hz t_high = %0.2f ns, expected ~%0.0f ns", t_high_100hz, expected_t_high_100hz);
			errors = errors + 1;
		end else begin
			$display("Pass: clk_100hz t_high = %0.2f ns ", t_high_100hz);
		end

		@(posedge clk_10khz);
		t_rise_10khz_1 = $time;
        @(negedge clk_10khz);
        t_fall_10khz = $time;
		@(posedge clk_10khz);
		t_rise_10khz_2 = $time;
        
		period_10khz = t_rise_10khz_2 - t_rise_10khz_1;
        t_high_10khz = t_fall_10khz - t_rise_10khz_1;

        // expected period = 100,000 ns - 0.1 ms
        expected_t_high_10khz = 100_000.0 / 2.0; // 50% duty cycle expected = 50 us

        // period
		test_idx++;
		if ((period_10khz < 9.9e4) || (period_10khz > 1.01e5)) begin
			$display("Fail: clk_10khz period = %0.2f ns, expected ~100,000 ns", period_10khz);
			errors = errors + 1;
		end else begin
			$display("Pass: clk_10khz period = %0.2f ns", period_10khz);
		end

        // 10 kHz high
        test_idx++;
		if ((t_high_10khz < expected_t_high_10khz * 0.99) || (t_high_10khz > expected_t_high_10khz * 1.01)) begin
			$display("Fail: clk_10khz t_high = %0.2f ns, expected ~%0.0f ns", t_high_10khz, expected_t_high_10khz);
			errors = errors + 1;
		end else begin
			$display("Pass: clk_10khz t_high = %0.2f ns", t_high_10khz);
		end

		$display("Completed %d tests with %d errors", test_idx, errors);
		$stop;
	end
endmodule