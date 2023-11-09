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
    reg  [         1: 0] state, state_nxt;  // remember to expand the bit width if you want to add more states!
    // load input
    reg  [  DATA_W-1: 0] operand_a, operand_a_nxt;
    reg  [  DATA_W-1: 0] operand_b, operand_b_nxt;
    reg  [         2: 0] inst, inst_nxt;
    // counter
    reg  [         4: 0] counter, counter_nxt;
    // output
    reg  [2*DATA_W-1: 0] out, out_nxt;
    reg  oDone, oDone_nxt;
    // temp reg
    reg  [2*DATA_W-1: 0] temp1, temp2;

// Wire Assignments
    // Todo
    assign o_done = oDone;
    assign o_data = out;

    // The above lines cannot be added !!!
    // We've already handled input in the "load input always block"
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
        out_nxt[2*DATA_W-1:0] = 0; // init to avoid latch
        case(state)
            S_ONE_CYCLE_OP   : begin
                case(inst)
                    0: begin // case A + B (s)
                        temp1[DATA_W-1:0] = operand_a[DATA_W-1:0] + operand_b[DATA_W-1:0];
                        if((operand_a[DATA_W-1]^operand_b[DATA_W-1])?
                            0:(temp1[DATA_W-1]^operand_a[DATA_W-1])) begin
                            case(temp1[DATA_W-1])
                                0:  out_nxt[DATA_W-1:0] = 32'h80000000;
                                1:  out_nxt[DATA_W-1:0] = 32'h7fffffff;
                            endcase
                        end
                        else    out_nxt[DATA_W-1:0] = temp1[DATA_W-1:0];
                    end
                    1: begin // case A - B (s)
                        temp1[DATA_W-1:0] = operand_a[DATA_W-1:0] - operand_b[DATA_W-1:0];
                        if((operand_a[DATA_W-1]==operand_b[DATA_W-1])?
                            0:(temp1[DATA_W-1]^operand_a[DATA_W-1])) begin
                            case(temp1[DATA_W-1])
                                0:  out_nxt[DATA_W-1:0] = 32'h80000000;
                                1:  out_nxt[DATA_W-1:0] = 32'h7fffffff;
                            endcase
                        end
                        else    out_nxt[DATA_W-1:0] = temp1[DATA_W-1:0];
                    end
                    2: begin // case A & B
                        out_nxt[DATA_W-1:0] = operand_a[DATA_W-1:0] & operand_b[DATA_W-1:0];
                    end
                    3: begin // case A | B
                        out_nxt[DATA_W-1:0] = operand_a[DATA_W-1:0] | operand_b[DATA_W-1:0];
                    end
                    4: begin // If A < B then output 1; else output 0.
                        if((operand_a[DATA_W-1] == 1) && (operand_b[DATA_W-1] == 0))        out_nxt = 1;
                        else if((operand_a[DATA_W-1] == 0) && (operand_b[DATA_W-1] == 1))   out_nxt = 0;
                        else begin
                            temp1[DATA_W-1:0] = operand_a[DATA_W-1:0] - operand_b[DATA_W-1:0]; // no overflow
                            if(temp1[DATA_W-1])  out_nxt = 1;
                            else                out_nxt = 0;
                        end
                    end
                    5: begin // Shift A with B bits right
                        out_nxt[DATA_W-1:0] = $signed(operand_a[DATA_W-1:0]) >>> operand_b[DATA_W-1:0];
                    end
                    default: begin
                        out_nxt[2*DATA_W-1:0] = 0;
                    end
                endcase
            end
            S_MULTI_CYCLE_OP : begin
                temp1[2*DATA_W-1:0] = 0;
                temp2[2*DATA_W-1:0] = 0;
                case(inst)
                    6: begin // case A * B
                        // Shift and then add (avoid overflowing)
                        if(counter == 0) begin
                            // step 1
                            temp2[2*DATA_W-1:0] = operand_b[DATA_W-1:0] >> 1;
                            if(operand_b[0]) begin
                                temp1[2*DATA_W-1:0] = operand_a[DATA_W-1:0] << DATA_W-1;
                                temp2[2*DATA_W-1:0] = temp2[2*DATA_W-1:0] + temp1[2*DATA_W-1:0];
                            end
                        end
                        else begin
                            // step 2-32
                            temp2[2*DATA_W-1:0] = out[2*DATA_W-1:0] >> 1;
                            if(out[0]) begin
                                temp1[2*DATA_W-1:0] = operand_a[DATA_W-1:0] << DATA_W-1;
                                temp2[2*DATA_W-1:0] = temp2[2*DATA_W-1:0] + temp1[2*DATA_W-1:0];
                            end
                        end
                        out_nxt[2*DATA_W-1:0] = temp2[2*DATA_W-1:0];
                    end
                    7: begin // case A / B
                        // temp2 init
                        if(counter == 0)    temp2[2*DATA_W-1:0] = operand_a[DATA_W-1:0] << 1;       // first step, temp2 = a
                        else                temp2[2*DATA_W-1:0] = out[2*DATA_W-1:0];                // the other cases, temp2 = out 

                        // step 1 - 31
                        if(counter < DATA_W-1) begin
                            temp1[DATA_W-1:0] = temp2[2*DATA_W-1:DATA_W];                           // temp1 = left half
                            if(temp1[DATA_W-1:0] >= operand_b[DATA_W-1:0]) begin                    // if left half > divisor
                                temp1[DATA_W-1:0] = temp1[DATA_W-1:0] - operand_b[DATA_W-1:0];
                                temp2[2*DATA_W-1:DATA_W] = temp1[DATA_W-1:0];
                                temp2[2*DATA_W-1:0] = temp2[2*DATA_W-1:0] << 1;
                                temp2[0] = 1;
                            end
                            else begin
                                temp2[2*DATA_W-1:0] = temp2[2*DATA_W-1:0] << 1;
                            end
                            out_nxt[2*DATA_W-1:0] = temp2[2*DATA_W-1:0];
                        end

                        // step 32 & final
                        if(counter == DATA_W-1) begin
                            temp1[DATA_W-1:0] = temp2[DATA_W-1:0];                                   // temp1 = right half
                            out_nxt[DATA_W-1:0] = temp1[DATA_W-1:0] << 1;          
                            temp1[DATA_W-1:0] = temp2[2*DATA_W-1:DATA_W];                            // temp1 = left half
                            if(temp1[DATA_W-1:0] >= operand_b[DATA_W-1:0]) begin
                                temp1[DATA_W-1:0] = temp1[DATA_W-1:0] - operand_b[DATA_W-1:0];
                                out_nxt[0] = 1;
                            end
                            out_nxt[2*DATA_W-1:DATA_W] = temp1[DATA_W-1:0];
                        end
                    end
                    default: begin
                        out_nxt[2*DATA_W-1:0] = 0;
                    end
                endcase
            end
            default: begin
                out_nxt[2*DATA_W-1:0] = 0;
            end
        endcase
    end
    // Todo: output valid signal
    always @(*) begin
         case(state)
            S_IDLE           : oDone_nxt = 0;
            S_ONE_CYCLE_OP   : oDone_nxt = 1;
            S_MULTI_CYCLE_OP : begin
                if(counter == DATA_W-1)     oDone_nxt = 1;
                else                        oDone_nxt = 0;
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
            counter     <= 0;
            out         <= 0;
        end
        else begin
            state       <= state_nxt;
            operand_a   <= operand_a_nxt;
            operand_b   <= operand_b_nxt;
            inst        <= inst_nxt;
            oDone       <= oDone_nxt;
            counter     <= counter_nxt;
            out         <= out_nxt;
        end
    end

endmodule