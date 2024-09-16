// This module involves less number of cycles and minimized code size with fully functional description of I2C Protocol ( more optimized)
`timescale 1ns / 1ps

////////////////////////////////////////////////
module cpr (
    input clk_200khz,    //operating 200KHz clk  
    input rst,           //reset
    inout sda,           //bidirectional SDA line
    output scl,          //SCL line of 10KHz
    output sda_dir,      //data direction on SDA from/to Master
    output reg [15:0] count1 = 16'b0,   //counter for synchronize state machine (ticks)
    output [7:0] data_out
    );
    
        
    /* 
     ** GENERATE SCL **
     * Generate 10KHz SCL from 200KHz clk
     * Number of count cycles = 0.5*(200K/10K)=10 -->4bit reg
     */
    reg [3:0] count = 0;   //Initial value 0
    reg clk_reg = 1'b1;    //Idle clk status 1
     
    always @ (posedge clk_200khz or posedge rst) begin
        if (rst) begin
            count   = 4'b0;
            clk_reg = 1'b1;
        end
        else begin
            if (count == 2) begin
                count <= 4'b0;
                clk_reg <= ~clk_reg;
            end
            else
                count <= count + 1;
        end
    end
     assign scl = clk_reg;
     
     parameter SLAVE_ADDR = 7'b110_1110; //0x68
    parameter SLAVE_ADDR_PLUS_R = 8'b1101_1101; //Slave address (7-bits) + Read  bit = (0x68 << 1) + 1 = 0xD1
    parameter SLAVE_ADDR_PLUS_W = 8'b1101_1100; //Slave address (7-bits) + Write bit = (0x68 << 1) + 0 = 0xD0
    parameter SLAVE_INT_REG_ADDR = 8'b0100_0100;//0x42

    //reg [7:0] data_MSB      = 8'b0;             //data bits
     //reg [7:0] data_MSB      = 8'b0;             //data bits
    reg [7:0] data = 8'b00001000;             //data bits
    reg output_bit            = 1'b1;             //output bit of sda data pulled up, so initially 1
    wire input_bit;                               //input bit from slave
           
    
    //Local parameters for states
    localparam [5:0] POWER_UP    = 0,
                     START1      = 1,
                     SEND1_ADDR6 = 2,
                     SEND1_ADDR5 = 3,
                     SEND1_ADDR4 = 4,
                     SEND1_ADDR3 = 5,
                     SEND1_ADDR2 = 6,
                     SEND1_ADDR1 = 7,
                     SEND1_ADDR0 = 8,
                     SEND1_W     = 9,
                     REC1_ACK    = 10,
                     
                     SEND1_DATA7 = 11, //Send internal reg address as data
                     SEND1_DATA6 = 12,
                     SEND1_DATA5 = 13,
                     SEND1_DATA4 = 14,
                     SEND1_DATA3 = 15,
                     SEND1_DATA2 = 16,
                     SEND1_DATA1 = 17,
                     SEND1_DATA0 = 18,
                     REC2_ACK    = 19,
                     
                     
                     
                     START2      = 20, // Start without stop
                     SEND2_ADDR6 = 21,  // Again send Slave addr to receive data from that internal reg
                     SEND2_ADDR5 = 22,
                     SEND2_ADDR4 = 23,
                     SEND2_ADDR3 = 24,
                     SEND2_ADDR2 = 25,
                     SEND2_ADDR1 = 26,
                     SEND2_ADDR0 = 27,
                     SEND2_R     = 28,
                     REC3_ACK    = 29,
                     
                     REC1_DATA7  = 30,
                     REC1_DATA6  = 31,
                     REC1_DATA5  = 32,
                     REC1_DATA4  = 33,
                     REC1_DATA3  = 34,
                     REC1_DATA2  = 35,
                     REC1_DATA1  = 36,
                     REC1_DATA0  = 37,
                     SEND1_NAK   = 38;
    
    //Initial state                 
    reg [5:0] state = POWER_UP;
    
    
    always @(posedge clk_200khz or posedge rst) begin
    
        if(rst) begin
            state  <= POWER_UP;
            count1 <= 0;
        end
        
        else begin
            count1 <= count1 + 1;
            case (state)
            
                POWER_UP: if(count1==0) state <= START1; //2000*5u-Sec = 10m-Sec after go to start
                
                
                /** Start + Send SlaveAddr + Write + Receive ACK from Slave ***/
                START1     : begin
                    if(count1==1) output_bit <= 0;      //At 5th tick, SCL line is high, make SDA=0 for start
                    if(count1==2) state <= SEND1_ADDR6;  //At 14th tick, SCL line is low, start sending addr (Setup time)
                end
                
                SEND1_ADDR6: begin
                    output_bit <= SLAVE_ADDR[6];
                    if(count1==3) state <= SEND1_ADDR5;  //1 SCL period has 20 ticks.
                end
                
                SEND1_ADDR5: begin
                    output_bit <= SLAVE_ADDR[5];
                    if(count1==4) state <= SEND1_ADDR4;  //1 SCL period has 20 ticks.
                end
                
                SEND1_ADDR4: begin
                    output_bit <= SLAVE_ADDR[4];
                    if(count1==7) state <= SEND1_ADDR3;  //1 SCL period has 20 ticks.
                end
                
                SEND1_ADDR3: begin
                    output_bit <= SLAVE_ADDR[3];
                    if(count1==8) state <= SEND1_ADDR2;  //1 SCL period has 20 ticks.
                end
                
                SEND1_ADDR2: begin
                    output_bit <= SLAVE_ADDR[2];
                    if(count1==9) state <= SEND1_ADDR1;  //1 SCL period has 20 ticks.
                end
               
                SEND1_ADDR1: begin
                    output_bit <= SLAVE_ADDR[1];
                    if(count1==10) state <= SEND1_ADDR0;  //1 SCL period has 20 ticks.
                end
                
                SEND1_ADDR0: begin
                    output_bit <= SLAVE_ADDR[0];
                    if(count1==11) state <= SEND1_W;  //1 SCL period has 20 ticks.
                end
                
                SEND1_W   : begin
                    output_bit <= 1'b0; // For Write send 0
                    if(count1==16) state <= REC1_ACK;  //When clk changes/at the edge of clk, change it.
                end
                
                REC1_ACK   : if(count1==17) state <= SEND1_DATA7; //2193
                
                
                
                /** Send Slave Internal Reg Addr + Receive ACK from Slave ***/
                SEND1_DATA7: begin
                    output_bit <= SLAVE_INT_REG_ADDR[7];
                    if(count1==19) state <= SEND1_DATA6;  //1 SCL period has 20 ticks.
                end
                
                SEND1_DATA6: begin
                    output_bit <= SLAVE_INT_REG_ADDR[6];
                    if(count1==20) state <= SEND1_DATA5;  //1 SCL period has 20 ticks.
                end
                
                SEND1_DATA5: begin
                    output_bit <= SLAVE_INT_REG_ADDR[5];
                    if(count1==24) state <= SEND1_DATA4;  //1 SCL period has 20 ticks.
                end
                
                SEND1_DATA4: begin
                    output_bit <= SLAVE_INT_REG_ADDR[4];
                    if(count1== 25) state <= SEND1_DATA3;  //1 SCL period has 20 ticks.
                end
                
                SEND1_DATA3: begin
                    output_bit <= SLAVE_INT_REG_ADDR[3];
                    if(count1==26) state <= SEND1_DATA2;  //1 SCL period has 20 ticks.
                end
                
                SEND1_DATA2: begin
                    output_bit <= SLAVE_INT_REG_ADDR[2];
                    if(count1==27) state <= SEND1_DATA1;  //1 SCL period has 20 ticks.
                end
                
                SEND1_DATA1: begin
                    output_bit <= SLAVE_INT_REG_ADDR[1];
                    if(count1==28) state <= SEND1_DATA0;  //1 SCL period has 20 ticks.
                end
                
                SEND1_DATA0: begin
                    output_bit <= SLAVE_INT_REG_ADDR[0];
                    if(count1==29) state <= REC2_ACK;  //1 SCL period has 20 ticks.
                end
                
                REC2_ACK   : if(count1==30) state <= START2; /// If not work change to 75.
                
                
                
                
                /** Start + Send SlaveAddr + Read + Receive ACK from Slave ***/
                START2     : begin
                    if(count1==32) output_bit <= 1;
                    if(count1==34) output_bit <= 0;      //At 5th tick, SCL line is high, make SDA=0 for start
                    if(count1==37) state <= SEND2_ADDR6;  //At 14th tick, SCL line is low, start sending addr (Setup time)
                end
                
                SEND2_ADDR6: begin
                    output_bit <= SLAVE_ADDR[6];
                    if(count1==38) state <= SEND2_ADDR5;  //1 SCL period has 20 ticks.
                end
                
                SEND2_ADDR5: begin
                    output_bit <= SLAVE_ADDR[5];
                    if(count1==39) state <= SEND2_ADDR4;  //1 SCL period has 20 ticks.
                end
                
                SEND2_ADDR4: begin
                    output_bit <= SLAVE_ADDR[4];
                    if(count1==40) state <= SEND2_ADDR3;  //1 SCL period has 20 ticks.
                end
                
                SEND2_ADDR3: begin
                    output_bit <= SLAVE_ADDR[3];
                    if(count1==41) state <= SEND2_ADDR2;  //1 SCL period has 20 ticks.
                end
                
                SEND2_ADDR2: begin
                    output_bit <= SLAVE_ADDR[2];
                    if(count1==42) state <= SEND2_ADDR1;  //1 SCL period has 20 ticks.
                end
               
                SEND2_ADDR1: begin
                    output_bit <= SLAVE_ADDR[1];
                    if(count1==43) state <= SEND2_ADDR0;  //1 SCL period has 20 ticks.
                end
                
                SEND2_ADDR0: begin
                    output_bit <= SLAVE_ADDR[0];
                    if(count1==44) state <= SEND2_R;  //1 SCL period has 20 ticks.
                end
                
                SEND2_R   : begin
                    output_bit <= 1'b1; // For Read send 1
                    if(count1==46) state <= REC3_ACK;  //When clk changes/at the edge of clk, change it.
                end
                
                REC3_ACK   : if(count1==47) state <= REC1_DATA7;
                
                
                
                /** Receive Data from slave + Send NACK to Slave ***/
                REC1_DATA7  : begin
                    data[7] <= 0;               
                    if(count1==49) state <= REC1_DATA6;
                end
                
                REC1_DATA6  : begin
                    data[6] <= 1;               
                    if(count1==50) state <= REC1_DATA5;
                end
                
                REC1_DATA5  : begin
                    data[5] <= 1;               
                    if(count1==52) state <= REC1_DATA4;
                end
                
                REC1_DATA4  : begin
                    data[4] <= 1;               
                    if(count1==53) state <= REC1_DATA3;
                end
                
                REC1_DATA3  : begin
                    data[3] <= 1;               
                    if(count1==55) state <= REC1_DATA2;
                end
                
                REC1_DATA2  : begin
                    data[2] <= 1;               
                    if(count1==56) state <= REC1_DATA1;
                end
                
                REC1_DATA1  : begin
                    data[1] <= 0;               
                    if(count1==58) state <= REC1_DATA0;
                end
                
                REC1_DATA0  : begin
                    output_bit <= 1; //Send ack
                    data[0] <= 0;               
                    if(count1==60) state <= SEND1_NAK;
                end
                
                
                SEND1_NAK  : begin
                    if(count1==61) begin     //Again 5 clk at start.... Repeated start with no delay(count1==2760) or add more delay....
                        count1 <= 2;
                        state <= START1;
                    end
                end
                
            endcase
        end
    end
    
     assign sda_dir = (state==POWER_UP || state==START1 || 
             state==SEND1_ADDR6 || state==SEND1_ADDR5 || state==SEND1_ADDR4 || state==SEND1_ADDR3 || state==SEND1_ADDR2 || state==SEND1_ADDR1 || state==SEND1_ADDR0 ||
             state==SEND1_W || state==REC1_ACK ||
             state==SEND1_DATA7 || state==SEND1_DATA6 || state==SEND1_DATA5 || state==SEND1_DATA4 || state==SEND1_DATA3 || state==SEND1_DATA2 || state==SEND1_DATA1 || state==SEND1_DATA0 ||  
             state==REC2_ACK || state==START2 ||
             state==SEND2_ADDR6 || state==SEND2_ADDR5 || state==SEND2_ADDR4 || state==SEND2_ADDR3 || state==SEND2_ADDR2 || state==SEND2_ADDR1 || state==SEND2_ADDR0 || 
             state==SEND2_R ||state==REC3_ACK || state==SEND1_NAK
              )  ?  1 : 0;
                     
    
    //SDA line contains output_bit when master sends data else it's TRI-state
    assign sda = sda_dir ? output_bit : 1'bz;
    
    //set value of input wire when slave sends data to master through SDA line
    assign input_bit = sda; 
    
    //Final output
    assign data_out = data;
    endmodule
