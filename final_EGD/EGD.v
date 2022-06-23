module EGD(
	input clk,
	input rst,
	input si_data,
	output reg busy,
	output reg valid,
	output reg [3:0] po_data
);
//FSM
    reg load_prefix, output_offset;
    reg load_p_input, sub_p;
    reg clear_prefix, clear_offset;
    wire load_offset;
    reg output_ans;
//add1
    reg [1:0] EGD_prefix;
//power2
    reg [3:0] power2; 
//sub1
    reg [1:0] prefix_down;
//offset
    reg [2:0] EGD_offset; 
//output
    wire [3:0] answer;

//FSM
    reg [2:0] state_ns, state_cs;
    parameter S0 = 3'b000; //initial state
    parameter S1 = 3'b001; //read prefix
    parameter S2 = 3'b010; //get prefix
    parameter S3 = 3'b011; //get offset
    parameter S4 = 3'b100; //output offset //get answer
    parameter S5 = 3'b101; //get answer
    parameter S6 = 3'b110; //clean
    parameter S7 = 3'b111; //output offset - answer is 0
    
    always @ (posedge clk or posedge rst)  begin
        if(rst) state_cs <= S0;
        else state_cs <= state_ns;
    end

    always @ (*) begin
        case(state_cs)
            S0: begin //initial state
                valid = 0;
                busy = 0;
                load_prefix = 0;
                load_p_input = 0;
                sub_p = 0;
                output_offset = 0;
                output_ans = 0;
                clear_prefix = 0;
                clear_offset = 0;
                
                if(si_data) state_ns = S1;
                else state_ns = S0;
            end
            
            S1: begin //read prefix
                valid = 0;
                busy = 0;
                load_prefix = 1;
                load_p_input = 0;
                sub_p = 0;
                output_offset = 0;
                output_ans = 0;
                clear_prefix = 0;
                clear_offset = 0;
                
                if(si_data) state_ns = S1;
                else state_ns = S2;
            end
        
            S2: begin //get prefix
                valid = 0;
                busy = 1;
                load_prefix = 0;
                load_p_input = 1;
                sub_p = 0;
                output_offset = 0;
                output_ans = 0;
                clear_prefix = 0;
                clear_offset = 0;
                
                state_ns = S3;
            end
        
            S3: begin //get offset
                valid = 0;
                busy = 0;
                load_prefix = 0;
                load_p_input = 0;
                sub_p = 1;
                output_offset = 0;
                output_ans = 0;
                clear_prefix = 0;
                clear_offset = 0;
                
                if(prefix_down) state_ns = S3;
                else state_ns = S4;
            end
        
            S4: begin //output offset
                valid = 0;
                busy = 1;
                load_prefix = 0;
                load_p_input = 0;
                sub_p = 0;
                output_offset = 1;
                output_ans = 0;
                clear_prefix = 0;
                clear_offset = 0;
                
                state_ns = S5;
            end
            
            S5: begin //get answer
                valid = 0;
                busy = 1;
                load_prefix = 0;
                load_p_input = 0;
                sub_p = 0;
                output_offset = 0;
                output_ans = 1;
                clear_prefix = 0;
                clear_offset = 0;
                
                state_ns = S6;
            end
        
            S6: begin //clear
                valid = 1;
                busy = 0;
                load_prefix = 0;
                load_p_input = 0;
                sub_p = 0;
                output_offset = 0;
                output_ans = 0;
                clear_prefix = 1;
                clear_offset = 1;
                
                if(si_data) state_ns = S1;
                else state_ns = S7;
            end
        
            S7: begin //output offset - answer is 0
                valid = 0;
                busy = 1;
                load_prefix = 0;
                load_p_input = 0;
                sub_p = 0;
                output_offset = 1;
                output_ans = 0;
                clear_prefix = 0;
                clear_offset = 0;
                
                state_ns = S5;
            end

		    default: state_ns = state_cs;
        endcase
    end

//add1
    always@(posedge clk or posedge rst) begin
        if(rst) EGD_prefix <= 2'b00;
        else if(clear_prefix) EGD_prefix <= 2'b00;
        else if(load_prefix) EGD_prefix <= EGD_prefix +1; 
    end

//power2
    always@(posedge clk or posedge rst) begin
        if(rst) power2 <= 4'b0001;
        else if(clear_prefix) power2 <= 4'b0001;
        else if(load_prefix) power2 <= power2 << 1; 
    end

//sub1
    always@(posedge clk or posedge rst) begin
        if(rst) prefix_down <= 2'b00;
        else if(load_p_input) prefix_down <= EGD_prefix - 1;
        else if(sub_p) prefix_down <= prefix_down - 1;
    end

//offset
    assign load_offset = load_p_input || sub_p;
    reg [2:0] temp; //a container for offset

    always@(posedge clk or posedge rst) begin
        if(rst) temp <= 3'b000;
        else if(clear_offset) temp <= 3'b000;
        else if(load_offset) temp[prefix_down] <= si_data;
    end
    
    always@(posedge clk or posedge rst) begin
        if(rst) EGD_offset <= 3'b000;
        else if(clear_offset) EGD_offset <= 3'b000;
        else if(output_offset) EGD_offset <= temp;
    end

    assign answer = power2 - 1 + EGD_offset;
//output po_data
    always@(posedge clk or posedge rst) begin
        if(rst) po_data <= 4'b000;
        //else if(clear_offset) po_data <= 4'b000;
        else if(output_ans) po_data <= answer;
    end

endmodule