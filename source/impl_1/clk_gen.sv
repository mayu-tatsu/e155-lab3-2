// clk_gen.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-09-22

// Generates a 48 MHz clock using the iCE40UP's onboard
// high-speed oscillator, then divides it to 100Hz.
// The module, HSCOSC, takes in a CLKHF_DIV to specify
// frequency and outputs the new clk from the port CLKHF.

module clk_gen(
	input  logic reset,
	output logic clk
);
	logic clk_48mhz;
	HSOSC #(.CLKHF_DIV("0b00")) hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk_48mhz));

	// 100 Hz clock divider
	// 48,000,000 / 100 = 480,000 / 2 = 240,000 counter

	logic [31:0] counter;
	logic        clk_divided;

	always_ff @(posedge clk_48mhz) begin
		if (~reset) begin
			counter <= 1'b0;
			clk_divided <= 1'b0;
		end
		else if (counter < 32'd2400000) counter <= counter + 1;
		else begin
			counter     <= 32'b0;
			clk_divided <= ~clk_divided;
		end
	end

	assign clk = clk_divided;
endmodule