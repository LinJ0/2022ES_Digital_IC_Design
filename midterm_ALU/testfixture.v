
`define DATA_NUM 509
`define CYCLE 20.0
`define PATTERN "pattern_in.txt"
`define EXPECT "golden.txt"
`timescale 1ns/10ps

module testfixture ;

reg [2:0] opcode;
reg [3:0] src_a ,src_b ; 
reg clk,reset ;
wire [5:0]alu_out ;
wire overflow,zero ;
reg [10:0]pattern_in[0:`DATA_NUM-1] ;
reg [7:0]ans[0:`DATA_NUM-1] ;
reg overflow_exp,zero_exp ;
reg [5:0] alu_out_exp ;

alu u_alu (	.overflow(overflow),
			.alu_out(alu_out),
			.zero(zero),
			.src_a(src_a),
			.src_b(src_b),
			.opcode(opcode)/*,
			.clk(clk),
			.reset(reset)*/
) ;

always begin #(`CYCLE/2) clk=~clk ; end  //clock generation

initial begin
$readmemb(`PATTERN,pattern_in) ;
$readmemb(`EXPECT,ans) ;
end

integer i ,err ,check,check_begin;

initial begin
check_begin =0;
clk=1'b0 ;
reset=0;
err=0 ;
check=0;
@(negedge clk) reset=1'b1 ;
#(`CYCLE*2) reset=1'b0 ;
check_begin =1;
/*
@(negedge clk) ;

  for(i=0;i<`DATA_NUM;i=i+1) begin
    {opcode,src_a,src_b}=pattern_in[i] ;
    {alu_out_exp,overflow_exp,zero_exp}=ans[i] ;
    @(negedge clk) ;
    if(alu_out!=alu_out_exp||overflow!=overflow_exp||zero!=zero_exp) begin
    err=err+1 ;
	$display("Error at %d ns",$time);
    $display("opcode=%b, src_a=%b, src_b=%b",opcode,src_a,src_b) ;
    $display("Expect   : alu_out=%b, overflow=%b, zero=%b",alu_out_exp,overflow_exp,zero_exp) ;
    $display("Your ans : alu_out=%b, overflow=%b, zero=%b\n\n",alu_out,overflow,zero) ;	
	
    end
    else if(alu_out==alu_out_exp&&overflow==overflow_exp&&zero==zero_exp) check=check+1;
  end
  */
end

always@(posedge clk or posedge reset)begin
	if(reset)
		i<=0;
	else if(check_begin)begin
    {opcode,src_a,src_b}<=pattern_in[i] ;
    {alu_out_exp,overflow_exp,zero_exp}<=ans[i] ;
	i<=i+1;
    
  end
		
end

always@(posedge clk)begin
	if(reset)
		err <=0;
	else if(alu_out!==alu_out_exp||overflow!==overflow_exp||zero!==zero_exp & check_begin) begin
		err<=err+1 ;
		$display("Error at %d ns",$time);
		$display("opcode=%b, src_a=%b, src_b=%b",opcode,src_a,src_b) ;
		$display("Expect   : alu_out=%b, overflow=%b, zero=%b",alu_out_exp,overflow_exp,zero_exp) ;
		$display("Your ans : alu_out=%b, overflow=%b, zero=%b\n\n",alu_out,overflow,zero) ;	
		
		end
	else if(alu_out===alu_out_exp&&overflow===overflow_exp&&zero===zero_exp& check_begin) 
		if(check!==`DATA_NUM)
			check<=check+1;
end
/*
initial begin
$fsdbDumpfile("alu.fsdb");
$fsdbDumpvars;
$fsdbDumpMDA;
end
*/
initial begin

wait(i===510)
if((err==0)&&(check==509)) begin
$display("-------------------   ALU check successfully   -------------------");
$display("            $$              ");
$display("           $  $");
$display("           $  $");
$display("          $   $");
$display("         $    $");
$display("$$$$$$$$$     $$$$$$$$");
$display("$$$$$$$              $");
$display("$$$$$$$              $");
$display("$$$$$$$              $");
$display("$$$$$$$              $");
$display("$$$$$$$              $");
$display("$$$$$$$$$$$$         $$");
$display("$$$$$      $$$$$$$$$$");
end
else if((err==0)&&(check!=509)) begin
$display("-----------   Oops! Something wrong with your code!   ------------");
end
else $display("-------------------   There are %d errors   -------------------", err);
$finish ;

end

endmodule


