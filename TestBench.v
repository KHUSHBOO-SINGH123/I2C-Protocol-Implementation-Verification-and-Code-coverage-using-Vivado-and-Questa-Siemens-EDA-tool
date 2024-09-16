
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module cprtb ();
    reg clk_200khz;
    reg rst;
    wire sda;
    wire scl;
    wire sda_dir;
    wire [15:0] count1;
    //wire [15:0] temperature;
    wire [7:0] data_out;
    

    cpr uut (
    .clk_200khz(clk_200khz),    //operating 200KHz clk  
    .rst(rst),           //reset
    .sda(sda),           //bidirectional SDA line
    . scl(scl),          //SCL line of 10KHz
    . sda_dir(sda_dir),      //data direction on SDA from/to Master
    . count1(count1),
    . data_out(data_out)
    );
    
    always #5 clk_200khz=~clk_200khz;
    
    initial begin
        rst=1;
        clk_200khz=0; #3 rst=0;
        #20000 $stop;
    end
endmodule
