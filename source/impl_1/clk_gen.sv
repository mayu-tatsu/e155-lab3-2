// clk_gen.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-09-22

// Generates a 48 MHz clock using the iCE40UP's onboard
// high-speed oscillator, then divides it to 100Hz and 10kHz.
// The module, HSCOSC, takes in a CLKHF_DIV to specify
// frequency and outputs the new clk from the port CLKHF.

module clk_gen(
	input  logic reset,
	output logic clk_100hz, clk_10khz
);
	logic clk_48mhz;
	HSOSC #(.CLKHF_DIV("0b00")) hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk_48mhz));

	// 100 Hz clock divider
	// 48,000,000 / 100 = 480,000 / 2 = 240,000 counter

	logic [31:0] counter_100hz;
	logic        clk_divided_100hz;

	always_ff @(posedge clk_48mhz) begin
		if (~reset) begin
			counter_100hz <= 32'b0;
			clk_divided_100hz <= 1'b0;
		end
		else if (counter_100hz < 32'd240000) counter_100hz <= counter_100hz + 1;
		else begin
			counter_100hz     <= 32'b0;
			clk_divided_100hz <= ~clk_divided_100hz;
		end
	end
	
	// 10 kHz clock divider
	// 48,000,000 / 10,000 = 4,800 / 2 = 2,400 counter

	logic [31:0] counter_10khz;
	logic        clk_divided_10khz;

	always_ff @(posedge clk_48mhz) begin
		if (~reset) begin
			counter_10khz <= 32'b0;
			clk_divided_10khz <= 1'b0;
		end
		else if (counter_10khz < 32'd2400) counter_10khz <= counter_10khz + 1;
		else begin
			counter_10khz     <= 32'b0;
			clk_divided_10khz <= ~clk_divided_10khz;
		end
	end

	assign clk_100hz = clk_divided_100hz;
	assign clk_10khz = clk_divided_10khz;
endmodule