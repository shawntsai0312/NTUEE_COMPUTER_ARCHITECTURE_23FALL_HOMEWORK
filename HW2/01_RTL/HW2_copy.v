module ALU #(
    parameter DATA_W = 32
)
(
    input                       i_clk,   // clock
    input                       i_rst_n, // reset

    input                       i_valid, // input valid signal
    input [DATA_W - 1 : 0]      i_A,     // input operand A
    input [DATA_W - 1 : 0]      i_B,     // input operand B
    input [         2 : 0]      i_inst,  // instruction

    output [2*DATA_W - 1 : 0]   o_data,  // output value
    output                      o_done   // output valid signal
);
// Do not Modify the above part !!!

// Parameters
    // ======== choose your FSM style ==========
    // 1. FSM based on operation cycles
    parameter S_IDLE           = 2'd0;
    parameter S_ONE_CYCLE_OP   = 2'd1;
    parameter S_MULTI_CYCLE_OP = 2'd2;
    // 2. FSM based on operation modes
    // parameter S_IDLE = 4'd0;
    // parameter S_ADD  = 4'd1;
    // parameter S_SUB  = 4'd2;
    // parameter S_AND  = 4'd3;
    // parameter S_OR   = 4'd4;
    // parameter S_SLT  = 4'd5;
    // parameter S_SRA  = 4'd6;
    // parameter S_MUL  = 4'd7;
    // parameter S_DIV  = 4'd8;
    // parameter S_OUT  = 4'd9;

// Wires & Regs
    // Todo
    // state
    reg  [         1: 0] state, state_nxt; // remember to expand the bit width if you want to add more states!
    // load input
    reg  [  DATA_W-1: 0] operand_a, operand_a_nxt;
    reg  [  DATA_W-1: 0] operand_b, operand_b_nxt;
    reg  [         2: 0] inst, inst_nxt;
    // counter
    reg  [         4: 0] counter, counter_nxt;
    // shift reg
    reg  [2*DATA_W-1: 0] shreg, shreg_nxt;
    // // output
    reg  [2*DATA_W-1: 0] out;
    reg  oDone, oDone_nxt;
    // multicycle temp reg
    reg  [2*DATA_W-1: 0] temp;

// Wire Assignments
    // Todo
    assign o_done = oDone;
    assign o_data = out;

    // The above lines cannot be added !!!
    // We've already handle input in the below always block
    // assign i_A = operand_a;
    // assign i_B = operand_b;
    // assign i_inst = inst;
    
// Always Combination
    // load input
    always @(*) begin
        if (i_valid) begin
            operand_a_nxt = i_A;
            operand_b_nxt = i_B;
            inst_nxt      = i_inst;
        end
        else begin
            operand_a_nxt = operand_a;
            operand_b_nxt = operand_b;
            inst_nxt      = inst;
        end
    end
    // Todo: FSM
    always @(*) begin
        case(state)
            S_IDLE           : begin
                if(i_valid) begin
                    if(i_inst <= 5)     state_nxt = S_ONE_CYCLE_OP;
                    else                state_nxt = S_MULTI_CYCLE_OP;
                end
                else    state_nxt = S_IDLE;
            end
            S_ONE_CYCLE_OP   : state_nxt = S_IDLE;
            S_MULTI_CYCLE_OP : state_nxt = (counter == DATA_W-1)? S_IDLE : S_MULTI_CYCLE_OP;
            default : state_nxt = state;
        endcase
    end
    // Todo: Counter
    always @(*) begin
        if(state == S_MULTI_CYCLE_OP)   counter_nxt = counter + 1;
        else                            counter_nxt = 0;
    end

    // Todo: ALU output
    always @(*) begin 
        case(state)
            S_ONE_CYCLE_OP   : begin
                case(inst)
                    // 0: begin // case A + B (s)
                    //     out[DATA_W-1:0] = operand_a[DATA_W-1:0] + operand_b[DATA_W-1:0];
                    //     if((operand_a[DATA_W-1]^operand_b[DATA_W-1])?
                    //         0:(out[DATA_W-1]^operand_a[DATA_W-1])) begin
                    //         case(out[DATA_W-1])
                    //             0:  out = 32'h80000000;
                    //             1:  out = 32'h7fffffff;
                    //         endcase
                    //     end
                    // end
                    // 1: begin // case A - B (s)
                    //     out[DATA_W-1:0] = operand_a[DATA_W-1:0] - operand_b[DATA_W-1:0];
                    //     if((operand_a[DATA_W-1]==operand_b[DATA_W-1])?
                    //         0:(out[DATA_W-1]^operand_a[DATA_W-1])) begin
                    //         case(out[DATA_W-1])
                    //             0:  out = 32'h80000000;
                    //             1:  out = 32'h7fffffff;
                    //         endcase
                    //     end
                    // end
                    2: begin // case A & B
                        out[DATA_W-1:0] = operand_a[DATA_W-1:0] & operand_b[DATA_W-1:0];
                    end
                    3: begin // case A | B
                        out[DATA_W-1:0] = operand_a[DATA_W-1:0] | operand_b[DATA_W-1:0];
                    end
                    // 4: begin // If A < B then output 1; else output 0.
                    //     if((operand_a[DATA_W-1] == 1) && (operand_b[DATA_W-1] == 0))        out = 1;
                    //     else if((operand_a[DATA_W-1] == 0) && (operand_b[DATA_W-1] == 1))   out = 0;
                    //     else begin
                    //         out[DATA_W-1:0] = operand_a[DATA_W-1:0] - operand_b[DATA_W-1:0]; // no overflow
                    //         if(out[DATA_W-1])   out = 1;
                    //         else                out = 0;
                    //     end
                    // end
                    5: begin // Shift A with B bits right
                        out[DATA_W-1:0] = $signed(operand_a[DATA_W-1:0]) >>> operand_b[DATA_W-1:0];
                    end
                endcase
            end
            // S_MULTI_CYCLE_OP : begin
            //     case(inst)
            //         6: begin // case A * B
            //             // shift then add (avoid overflowing)
            //             if(counter == 0) begin
            //                 // step 1
            //                 shreg_nxt = operand_b >> 1;
            //                 if(operand_b[0]) begin
            //                     temp = operand_a << DATA_W-1;
            //                     shreg_nxt = shreg_nxt + temp;
            //                 end
            //             end
            //             else begin
            //                 // step 2-32
            //                 shreg_nxt = shreg >> 1;
            //                 if(shreg[0]) begin
            //                     temp = operand_a << DATA_W-1;
            //                     shreg_nxt = shreg_nxt + temp;
            //                 end
            //             end
            //             // step final
            //             if(counter == DATA_W-1) out = shreg_nxt;
            //         end
            //         7: begin // case A / B
            //             // temp is the left half of shreg_nxt
            //             if(counter == 0)    shreg_nxt[2*DATA_W-1:0] = operand_a[DATA_W-1:0] << 1;   // init
            //             else                shreg_nxt[2*DATA_W-1:0] = shreg[2*DATA_W-1:0];          // the other cases

            //             // step 1 - 31
            //             if(counter < DATA_W-1) begin
            //                 temp[DATA_W-1:0] = shreg_nxt[2*DATA_W-1:DATA_W];                            // temp = left half
            //                 if(temp[DATA_W-1:0] >= operand_b[DATA_W-1:0]) begin                         // if left half > divisor
            //                     temp[DATA_W-1:0] = temp[DATA_W-1:0] - operand_b[DATA_W-1:0];
            //                     shreg_nxt[2*DATA_W-1:DATA_W] = temp[DATA_W-1:0];
            //                     shreg_nxt[2*DATA_W-1:0] = shreg_nxt[2*DATA_W-1:0] << 1;
            //                     shreg_nxt[0] = 1;
            //                 end
            //                 else begin
            //                     shreg_nxt[2*DATA_W-1:0] = shreg_nxt[2*DATA_W-1:0] << 1;
            //                 end
            //             end

            //             // step 32 & final
            //             if(counter == DATA_W-1) begin
            //                 temp[DATA_W-1:0] = shreg_nxt[DATA_W-1:0];                                   // temp = right half
            //                 out[DATA_W-1:0] = temp[DATA_W-1:0] << 1;          
            //                 temp[DATA_W-1:0] = shreg_nxt[2*DATA_W-1:DATA_W];                            // temp = left half
            //                 if(temp[DATA_W-1:0] >= operand_b[DATA_W-1:0]) begin                         // if left half > divisor
            //                     temp[DATA_W-1:0] = temp[DATA_W-1:0] - operand_b[DATA_W-1:0];
            //                     out[0] = 1;
            //                 end
            //                 out[2*DATA_W-1:DATA_W] = temp[DATA_W-1:0];
            //             end
            //         end
            //         default: out = 0;
            //     endcase
            // end
        endcase
    end
    // Todo: output valid signal
    always @(*) begin
         case(state)
            S_IDLE           : oDone_nxt = 0;
            S_ONE_CYCLE_OP   : oDone_nxt = 1;
            S_MULTI_CYCLE_OP : begin
                if(counter == DATA_W-1)   oDone_nxt = 1;
                else                oDone_nxt = 0;
            end
            default : oDone_nxt = 0;
        endcase
    end
       
    // Todo: Sequential always block
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state       <= S_IDLE;
            operand_a   <= 0;
            operand_b   <= 0;
            inst        <= 0;
            oDone       <= 0;
            shreg       <= 0;
            counter     <= 0;
        end
        else begin
            state       <= state_nxt;
            operand_a   <= operand_a_nxt;
            operand_b   <= operand_b_nxt;
            inst        <= inst_nxt;
            oDone       <= oDone_nxt;
            shreg       <= shreg_nxt;
            counter     <= counter_nxt;
        end
    end

endmodule