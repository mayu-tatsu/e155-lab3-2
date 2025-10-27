//============================================================
// 4-State Keypad Decoder FSM
// Scans a 4x4 keypad and outputs:
//   - key_onebit: 1 when any key is pressed
//   - keypad_val: binary code (0–15) of pressed key, or 11111 when none
//   - row[3:0]: drives keypad rows for scanning
//============================================================

module keypad_decoder (
    input  logic       clk,
    input  logic       reset,
    input  logic [3:0] col,          // from keypad columns (after sync)
    output logic [3:0] row,          // to keypad rows
    output logic [4:0] keypad_val,   // 5'b11111 = none
    output logic       key_onebit    // 1 when key is pressed
);

    // --- FSM State Encoding ---
    typedef enum logic [1:0] {
        ROW0 = 2'b00,
        ROW1 = 2'b01,
        ROW2 = 2'b10,
        ROW3 = 2'b11
    } state_t;

    state_t state, next_state;

    // --- Internal variables ---
    logic [3:0] row_drive;
    logic [4:0] key_val_next;
    logic       key_detect;

    //------------------------------------------------------------
    // State Register
    //------------------------------------------------------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= ROW0;
        else
            state <= next_state;
    end

    //------------------------------------------------------------
    // Row Drive Logic (each row active low or high depending on wiring)
    //------------------------------------------------------------
    always_comb begin
        // Default: drive only one row active at a time
        case (state)
            ROW0: row_drive = 4'b0001;
            ROW1: row_drive = 4'b0010;
            ROW2: row_drive = 4'b0100;
            ROW3: row_drive = 4'b1000;
            default: row_drive = 4'b0001;
        endcase
    end

    assign row = row_drive;

    //------------------------------------------------------------
    // Next-State Logic
    // - Keeps cycling through rows
    // - If key detected, stays in current row until release
    //------------------------------------------------------------
    always_comb begin
        next_state = state;  // default stay
        if (!key_detect) begin
            // Move to next row every clock if no key pressed
            case (state)
                ROW0: next_state = ROW1;
                ROW1: next_state = ROW2;
                ROW2: next_state = ROW3;
                ROW3: next_state = ROW0;
            endcase
        end
    end

    //------------------------------------------------------------
    // Key Detection + Encoding
    //------------------------------------------------------------
    always_comb begin
        key_detect   = |col;        // any column high = pressed
        key_val_next = 5'b11111;    // default (no key)

        if (key_detect) begin
            case (state)
                ROW0: case (col)
                    4'b0001: key_val_next = 5'd0;
                    4'b0010: key_val_next = 5'd1;
                    4'b0100: key_val_next = 5'd2;
                    4'b1000: key_val_next = 5'd3;
                endcase
                ROW1: case (col)
                    4'b0001: key_val_next = 5'd4;
                    4'b0010: key_val_next = 5'd5;
                    4'b0100: key_val_next = 5'd6;
                    4'b1000: key_val_next = 5'd7;
                endcase
                ROW2: case (col)
                    4'b0001: key_val_next = 5'd8;
                    4'b0010: key_val_next = 5'd9;
                    4'b0100: key_val_next = 5'd10;
                    4'b1000: key_val_next = 5'd11;
                endcase
                ROW3: case (col)
                    4'b0001: key_val_next = 5'd12;
                    4'b0010: key_val_next = 5'd13;
                    4'b0100: key_val_next = 5'd14;
                    4'b1000: key_val_next = 5'd15;
                endcase
            endcase
        end
    end

    //------------------------------------------------------------
    // Output Registers (1-cycle latency)
    //------------------------------------------------------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            keypad_val <= 5'b11111;
            key_onebit <= 1'b0;
        end else begin
            keypad_val <= key_val_next;
            key_onebit <= key_detect;
        end
    end

endmodule

/*// keypad.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-09-22

// Keypad module that scans a 4x4 matrix keypad and outputs the raw key press

// col and row are one-hot encoded 4-bit signals representing the columns
// and rows of the keypad.
// keypad_val is a 5-bit output logic representing the key pressed
// (0-15 for keys 0-F, 31 for no key pressed)

module keypad(
    input  logic       clk, reset,
    input  logic [3:0] col,
    output logic [3:0] row,
    output logic [4:0] keypad_val,
    output logic       key_onebit
);

    typedef enum logic [4:0] {
        S0_CHECK_R0, S1_CHECK_R1, S2_CHECK_R2, S3_CHECK_R3,
        S4_PRESSED_1, S5_PRESSED_2, S6_PRESSED_3, S7_PRESSED_A,
        S8_PRESSED_4, S9_PRESSED_5, S10_PRESSED_6, S11_PRESSED_B,
        S12_PRESSED_7, S13_PRESSED_8, S14_PRESSED_9, S15_PRESSED_C,
        S16_PRESSED_E, S17_PRESSED_0, S18_PRESSED_F, S19_PRESSED_D
    } statetype;
    statetype state, nextstate;

    // state register
    always_ff @(posedge clk)
        if   (~reset)  state <= S0_CHECK_R0;
        else           state <= nextstate;

    // next state logic
    always_comb begin
        case (state)
            S0_CHECK_R0: begin
                casez (col)
                    4'b1???: nextstate = S4_PRESSED_1;
                    4'b?1??: nextstate = S5_PRESSED_2;
                    4'b??1?: nextstate = S6_PRESSED_3;
                    4'b???1: nextstate = S7_PRESSED_A;
                    default: nextstate = S1_CHECK_R1;
                endcase
            end
            S1_CHECK_R1: begin
                casez (col)
                    4'b1???: nextstate = S8_PRESSED_4;
                    4'b?1??: nextstate = S9_PRESSED_5;
                    4'b??1?: nextstate = S10_PRESSED_6;
                    4'b???1: nextstate = S11_PRESSED_B;
                    default: nextstate = S2_CHECK_R2;
                endcase
            end
            S2_CHECK_R2: begin
                casez (col)
                    4'b1???: nextstate = S12_PRESSED_7;
                    4'b?1??: nextstate = S13_PRESSED_8;
                    4'b??1?: nextstate = S14_PRESSED_9;
                    4'b???1: nextstate = S15_PRESSED_C;
                    default: nextstate = S3_CHECK_R3;
                endcase
            end
            S3_CHECK_R3: begin
                casez (col)
                    4'b1???: nextstate = S16_PRESSED_E;
                    4'b?1??: nextstate = S17_PRESSED_0;
                    4'b??1?: nextstate = S18_PRESSED_F;
                    4'b???1: nextstate = S19_PRESSED_D;
                    default: nextstate = S0_CHECK_R0;
                endcase 
            end
            S4_PRESSED_1:    nextstate = (col[3] == 1'b0) ? S0_CHECK_R0 : S4_PRESSED_1;
            S5_PRESSED_2:    nextstate = (col[2] == 1'b0) ? S0_CHECK_R0 : S5_PRESSED_2;
            S6_PRESSED_3:    nextstate = (col[1] == 1'b0) ? S0_CHECK_R0 : S6_PRESSED_3;
            S7_PRESSED_A:    nextstate = (col[0] == 1'b0) ? S0_CHECK_R0 : S7_PRESSED_A;
            S8_PRESSED_4:    nextstate = (col[3] == 1'b0) ? S1_CHECK_R1 : S8_PRESSED_4;
            S9_PRESSED_5:    nextstate = (col[2] == 1'b0) ? S1_CHECK_R1 : S9_PRESSED_5;
            S10_PRESSED_6:   nextstate = (col[1] == 1'b0) ? S1_CHECK_R1 : S10_PRESSED_6;
            S11_PRESSED_B:   nextstate = (col[0] == 1'b0) ? S1_CHECK_R1 : S11_PRESSED_B;
            S12_PRESSED_7:   nextstate = (col[3] == 1'b0) ? S2_CHECK_R2 : S12_PRESSED_7;
            S13_PRESSED_8:   nextstate = (col[2] == 1'b0) ? S2_CHECK_R2 : S13_PRESSED_8;
            S14_PRESSED_9:   nextstate = (col[1] == 1'b0) ? S2_CHECK_R2 : S14_PRESSED_9;
            S15_PRESSED_C:   nextstate = (col[0] == 1'b0) ? S2_CHECK_R2 : S15_PRESSED_C;
            S16_PRESSED_E:   nextstate = (col[3] == 1'b0) ? S3_CHECK_R3 : S16_PRESSED_E;
            S17_PRESSED_0:   nextstate = (col[2] == 1'b0) ? S3_CHECK_R3 : S17_PRESSED_0;
            S18_PRESSED_F:   nextstate = (col[1] == 1'b0) ? S3_CHECK_R3 : S18_PRESSED_F;
            S19_PRESSED_D:   nextstate = (col[0] == 1'b0) ? S3_CHECK_R3 : S19_PRESSED_D;
            default: nextstate = S0_CHECK_R0;
        endcase
    end

    // output logic
    always_comb begin
        case (state)
            S0_CHECK_R0:   begin row = 4'b0001; keypad_val = 5'b11111; end
            S1_CHECK_R1:   begin row = 4'b0010; keypad_val = 5'b11111; end
            S2_CHECK_R2:   begin row = 4'b0100; keypad_val = 5'b11111; end
            S3_CHECK_R3:   begin row = 4'b1000; keypad_val = 5'b11111; end
            S4_PRESSED_1:  begin row = 4'b0001; keypad_val = 5'b00001; end
            S5_PRESSED_2:  begin row = 4'b0001; keypad_val = 5'b00010; end
            S6_PRESSED_3:  begin row = 4'b0001; keypad_val = 5'b00011; end
            S7_PRESSED_A:  begin row = 4'b0001; keypad_val = 5'b01010; end
            S8_PRESSED_4:  begin row = 4'b0010; keypad_val = 5'b00100; end
            S9_PRESSED_5:  begin row = 4'b0010; keypad_val = 5'b00101; end
            S10_PRESSED_6: begin row = 4'b0010; keypad_val = 5'b00110; end
            S11_PRESSED_B: begin row = 4'b0010; keypad_val = 5'b01011; end
            S12_PRESSED_7: begin row = 4'b0100; keypad_val = 5'b00111; end
            S13_PRESSED_8: begin row = 4'b0100; keypad_val = 5'b01000; end
            S14_PRESSED_9: begin row = 4'b0100; keypad_val = 5'b01001; end
            S15_PRESSED_C: begin row = 4'b0100; keypad_val = 5'b01100; end
            S16_PRESSED_E: begin row = 4'b1000; keypad_val = 5'b01110; end
            S17_PRESSED_0: begin row = 4'b1000; keypad_val = 5'b00000; end
            S18_PRESSED_F: begin row = 4'b1000; keypad_val = 5'b01111; end
            S19_PRESSED_D: begin row = 4'b1000; keypad_val = 5'b01101; end
            default:       begin row = 4'b0000; keypad_val = 5'b11111; end
        endcase
    end

    // high whenever any key is pressed (anything other than the not-pressed value)
    // used for debouncing
    assign key_onebit = (keypad_val != 5'b11111);
endmodule*/