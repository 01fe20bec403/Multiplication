module MUL_datapath(eqz,lda,ldb,ldp,clrp,decb,data_in);                                                                                                                                                                                                                                                                                                                                                                                                                                                    module muldp(eqz,lda,ldb,ldp,clrp,decb,data_in,clk);
input lda,ldb,ldp,clrp,decb,clk;
input [15:0]data_in;
output eqz;
wire [15:0]x,y,z,bout,bus;

pipo1 a(x,bus,lda,clk);
pipo2 p(y,z,ldp,clrp,clk);
cntr b(bout,bus,ldb,decb,clk);
add ad(z,x,y);
eqz comp(eqz,bout);
endmodule

module pipo1(dout,din,ld,clk);
input [15:0]din;
input ld,clk;
output reg[15:0]dout;
always @(posedge clk)
if(ld)dout <= din;
endmodule

module pipo2(dout,din,ld,clr,clk);
input [15:0]din;
input ld,clr,clk;
output reg[15:0]dout;
always @(posedge clk)
if(clr)dout <= 16'b0;
else if(ld)dout <= din;
endmodule

module eqz(eqz,data);
input [15:0]data;
output eqz;
assign eqz = (data == 0);
endmodule

module add(out,in1,in2);
input [15:0]in1,in2;
output reg [15:0]out;
always @(*)
out=in1+in2;
endmodule


module cntr(dout,din,ld,dec,clk);
input [15:0]din;
input ld,dec,clk;
output reg[15:0]dout;
always @(posedge clk)
 if(ld)dout <= din;
else if(dec) dout <=dout-1;
endmodule

module ctrll(lda,ldb,ldp,clrp,decb,done,start,eqz,clk);
input clk,eqz,start;
output reg lda,ldb,ldp,clrp,decb,done;
reg[2:0]state;
parameter s0=3'b000, s1=3'b001, s2=3'b010,s3=3'b011,s4=3'b100;
alawys @(posedge clk)
begin
case(state)
s0:if(start)state<=s1;
s1:state<=s2;
s2:state<=s3;
s3:#2 if(eqz)state<=s4;
s4:state<=s4;
endmodule

always @(state)
begin
case(state)
s0:begin #1 lda=0;ldb=0;ldp=0;clrp=0;
s1:begin #1 lda=1;end
s2:begin #1 lda=0;ldp=1;clrp=1;end
s3:begin #1 ldb=0;ldp=1;clrp=0;decb=1;
s4:begin #1 done=1;ldb=0;ldp=0;decb=0;
default:begin #1 lda=0;ldb=0;ldp=0;clrp=0;
endcase
end 
endmodule

//TESTBENCH
 
 module multb;
reg [15:0]data_in;
reg clk,start;
wire done;
wire [15:0] x,y,z,bout,bus;
MUL_datapath DP(eqz,lda,ldb,ldp,clr,decb,data_in,clk);
controller con(lda,ldb,ldp,clrp,decb,clk,start);
initial
begin
clk=1'b0;
#3 start=1'b1;
#500 $finish;
end

always #5 clk=~clk;

initial 
begin
#17 data_in=17;
#10 data_in=5;
end

initial 
begin
$monitor ($time,"%d %b",dp.y,done);
$dumpfile("repmul.vcd");
$dumpvars(0,multb);

end
endmodule
