// keypad_decoder.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-11-05

// Combinational logic that assigns the new input number
// (num) based on the values row and col.

module keypad_decoder(
  input  logic [3:0] rows, col,
  output logic [3:0] num
);
	always_comb
        case(rows)
            4'b0001: 
				case(col)
					4'b0001: num = 4'b0001;
					4'b0010: num = 4'b0010;
					4'b0100: num = 4'b0011;
					4'b1000: num = 4'b1010;
					default: num = 4'b0000;
				 endcase
            4'b0010: 
				case(col)
					4'b0001: num = 4'b0100;
					4'b0010: num = 4'b0101;
					4'b0100: num = 4'b0110;
					4'b1000: num = 4'b1011;
					default: num = 4'b0000;
				endcase
            4'b0100:
				case(col)
					4'b0001: num = 4'b0111;
					4'b0010: num = 4'b1000;
					4'b0100: num = 4'b1001;
					4'b1000: num = 4'b1100;
					default: num = 4'b0000;
				 endcase
            4'b1000:
				case(col)
					4'b0001: num = 4'b1110;
					4'b0010: num = 4'b0000;
					4'b0100: num = 4'b1111;
					4'b1000: num = 4'b1101;
					default: num = 4'b0000;
				endcase
            default: num = 4'b0000;
        endcase
endmodule