module alu(
input signed[3:0] src_a, src_b,
input [2:0] opcode,
output reg overflow,
output reg signed[5:0] alu_out,
output reg zero 
);
reg carry_out;

always @(*)
begin
    case(opcode)
    3'b000: begin //AND, no overflow
        {carry_out, alu_out} = {3'b0, src_a} & {3'b0, src_b};  /*I don't need signed-extend here*/
    end
    3'b001: begin//MAX, no overflow
        if(src_a > src_b) begin
            alu_out = src_a;
            carry_out = src_a[3]; /*signed-extend*/
        end
        else begin
            alu_out = src_b;
            carry_out = src_b[3]; /*signed-extend*/
        end
    end 
    
    3'b010: begin//LUT - look up table, no overflow
    
        case(src_a)
            4'b0000: alu_out = 6'b011111;
            4'b0001: alu_out = 6'b111001;
            4'b0010: alu_out = 6'b000000;
            4'b0011: alu_out = 6'b000001;
            4'b0100: alu_out = 6'b000011;
            4'b0101: alu_out = 6'b001010;
            4'b0110: alu_out = 6'b001110;
            4'b0111: alu_out = 6'b010000;
            4'b1000: alu_out = 6'b111110;
            4'b1001: alu_out = 6'b001000;
            4'b1010: alu_out = 6'b010101;
            4'b1011: alu_out = 6'b000111;
            4'b1100: alu_out = 6'b101111;
            4'b1101: alu_out = 6'b001011;
            4'b1110: alu_out = 6'b000010;
            default: alu_out = 6'b001000;
        endcase 
        carry_out = alu_out[5];
    end
    3'b011: begin//MUL, consider overflow
        {carry_out, alu_out} = src_a * src_b;
        if((src_a[3] ^ src_b[3]) && (carry_out ^ alu_out[5])) //result negative
            {carry_out, alu_out} = 7'b0100000;
        else if((src_a[3] ~^ src_b[3]) && (carry_out ^ alu_out[5])) //result positive
            {carry_out, alu_out} = 7'b1011111;
        else //no overflow
            alu_out = alu_out;
    end
    
    3'b100: begin//ADD, no overflow
        {carry_out, alu_out} = src_a + src_b;
    end
    3'b101: begin//SUB, no overflow
        {carry_out, alu_out} = src_a - src_b;
    end
    3'b110: begin//bit permutation, no overflow
        if(src_a[0] == 1'b1)
            {carry_out, alu_out} = {src_a[2], src_a[2], src_b[2], src_a[1], src_b[1], src_a[0], src_b[0]};  /*signed-extend*/
        else
        
            {carry_out, alu_out} = {src_b[2], src_b[2], src_a[2], src_b[1], src_a[1], src_b[0], src_a[0]};  /*signed-extend*/
    end
    default: begin//opcode == 111 : shift left, consider overflow
        if(src_a[3] == 1'b0) begin//positive
            if(src_a >= 4'd4 && src_b > 4'b0010)
                {carry_out, alu_out} = 7'b1011111;
            else if(src_a >= 4'd2 && src_b > 4'b0011)
                {carry_out, alu_out} = 7'b1011111;
            else if(src_a == 4'd1 && src_b > 4'b0100)
                {carry_out, alu_out} = 7'b1011111;
            else
                {carry_out, alu_out} = {3'b000, src_a} << src_b;
        end
        else begin//negative
            {carry_out, alu_out} = {3'b111, src_a} << src_b; /***shift first, then use the result to determine overflow or not***/
            if(src_b > 4'd3)
                {carry_out, alu_out} = 7'b0100000;
            else if((src_b > 4'd2) && (alu_out[5] == 1'b0))
                {carry_out, alu_out} = 7'b0100000;
            else
                {carry_out, alu_out} = {carry_out, alu_out};
        end
    end
    endcase
end

always @(*)//alu_out
    zero = ~|alu_out;
    
always @(*)//carry_out or alu_out
    overflow = (carry_out ^ alu_out[5])?1'b1: 1'b0;
    
endmodule