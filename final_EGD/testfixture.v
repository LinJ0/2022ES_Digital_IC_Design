
`define DATA_NUM 2858
`define CYCLE 20.0
`define PATTERN "bit_stream.txt"
`define EXPECT "golden.txt"
`timescale 1ns/10ps

module testfixture ;

reg si_data ; 
reg clk,rst ;
wire [3:0]po_data ;
wire valid ;
wire busy;
reg [15:0] out_cnt, in_cnt, in_cnt_d1;
reg [0:`DATA_NUM-1] pattern_in [0:0];
reg [3:0]ans[0:`DATA_NUM-1] ;
wire [7:0]po_exp ;
 
EGD u_EGD(.clk(clk),
			.rst(rst),
			.valid(valid),
			.si_data(si_data),
			.po_data(po_data),
			.busy(busy)
);

always begin #(`CYCLE/2) clk=~clk ; end  //clock generator

initial begin
$readmemb(`PATTERN,pattern_in) ;
$readmemb(`EXPECT,ans) ;
end

integer i ,err ,check, err_2 ;

initial begin
	clk=1'b0 ;
	err=0 ;
	check=0;
	@(negedge clk) rst=1'b1 ;
	#(`CYCLE*1.75) rst=1'b0 ;
end

always@(posedge clk or posedge rst)
	if(rst)
		in_cnt <= 0;
	else if(~busy)
		in_cnt <= in_cnt + 1;

always@(posedge clk)
	if(~busy)
		in_cnt_d1 <= in_cnt;

always@(posedge clk or posedge rst)
	if(rst)
		si_data <= 'bz;
	else if(~busy)
		si_data <= pattern_in[0][in_cnt];
	else if(busy)
		si_data <= pattern_in[0][in_cnt_d1];

assign po_exp = ans[out_cnt] ;

always@(posedge clk)begin
	if(valid)begin
		if(po_data!=po_exp) begin
			err <= err+1 ;
			$display($time,"Error  output:%d, po_data=%h",out_cnt,po_data) ;
			$display($time,"Expect output:%d, po_data=%h",out_cnt,po_exp) ;
		end
		else if(po_data==po_exp) check <= check+1;
    end
end

always@(posedge clk or posedge rst)
	if(rst)
		out_cnt <= 0;
	else if(valid)
		out_cnt <= out_cnt + 1;
		

always@(posedge clk)begin
	if(out_cnt == 512)begin
		#(`CYCLE)
		if((err==0)&&(check==512)) begin
			$display("-------------------   EGD check successfully   -------------------");
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
			$finish ;
		end
		else if((err==0)&&(check!=512)) begin
			$display("-----------   Oops! Something wrong with your code!   ------------");
			$finish ;
		end
		else 
			$display("-------------------   There are %d errors   -------------------", err);
		$finish ;
	end
end

initial begin
	#(`CYCLE*100000)
	err_2 = err+512-check;
	$display("-----------   Oops! There is something wrong with your code! It can't stop.   ------------");
	$display("-------------------   There are %d errors   -------------------", err_2);
	$finish ;
end

endmodule


