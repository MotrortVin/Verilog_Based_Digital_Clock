`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:05:25 04/29/2018 
// Design Name: 
// Module Name:    clock 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module clock(
  input clk,//the signal for the clock of basys2
  input clr,//the Button to clear
  input hour_minute_opt,//for set the alarm, we can turn it to change the choice
  input increase_time,//add the time
  input am_pm_change, //24hour or 12hour 
  input set_alarm,//set alarm clock
  input [6:0]sw,//we need these button to set alarm clock
  output hour_strike, //tell you a whole hour
  output alarm,//alarm light
  output pm, //pm light
  output [4:0]hour_show,//the led that means the hour 
  output [3:0]an,//the number you need to choose
  output reg[6:0]a_to_g//the number
	 );
	 
  reg [29:0] clk_cnt;//the clock 
  reg [3:0] NUM; //the number
  reg [17:0] switch ; //we will use it to reflash the light
  reg pm_flag ; //pm part
  wire [7:0] second_h; //8 binary count for second
  wire [7:0] second; //second
  reg [7:0] minute; //minute
  reg [4:0] hour; //hour
  reg [4:0] hour_alarm; //hour alarm
  reg [7:0] minute_alarm; //minute alarm
  reg flag_increase_time; //time increase
  
/*************************************************************************************/
/*                           To rekindle the light of number                         */
/*************************************************************************************/
  always @(*)
    case(NUM)
      0:a_to_g=7'b0000001;
      1:a_to_g=7'b1001111;
      2:a_to_g=7'b0010010;
      3:a_to_g=7'b0000110;
      4:a_to_g=7'b1001100;
      5:a_to_g=7'b0100100;
      6:a_to_g=7'b0100000;
      7:a_to_g=7'b0001111;
      8:a_to_g=7'b0000000;
      9:a_to_g=7'b0000100;
      default: a_to_g=7'b0000001;
    endcase
	 
/*************************************************************************************/
/*                         To thansform second into BCD code                         */
/*************************************************************************************/
  reg [3:0] c ;
  reg [7:0] q ;
  assign second = {c,q[3:0]};
  always @(*)
    begin
      c = second_h[7:0]/16 ;
      q = (second_h[7:0]%16) + (second_h[7:0]/16)*6 ;
      if(q/16)
        begin
          c = c + q/16 ;
          q = q%16 + (q/16)*6 ;
        end
      if(q/16)
        begin
          c = c + q/16 ;
          q = q%16 + (q/16)*6 ;
        end
      if(q/16)
        begin
          c = c + q/16 ;
          q = q%16 + (q/16)*6 ;
        end
      else if(q>=10)
              begin
                c = c + 1 ;
                q = q -10 ;
              end
    end

/*************************************************************************************/
/*                           To clear the time and count                             */
/*************************************************************************************/
  always@(posedge clk or posedge clr)
    begin
      if(clr)
        begin
          clk_cnt = 0;
          minute = 0;
          hour = 0;
          hour_alarm = 8'b11111111;//clear the alarm
          minute_alarm = 8'b11111111;//clear the alarm
        end
      else
        begin
          clk_cnt = clk_cnt + 1;
			 
/*************************************************************************************/
/*                                   To make the clock                               */
/*************************************************************************************/
            if(clk_cnt[28:21]>59)
              begin
                clk_cnt = 0;
                minute = minute + 1;
              end
            if(minute[3:0]>9) 
              begin
                minute = minute + 6;
              end
            if(minute[7:4]>5) 
              begin
                minute = 0;
                hour = hour + 1;
              end
            if(hour>23) 
              begin
                hour = 0;
              end
/*************************************************************************************/
/*                     We use to increase the hour and minute                        */
/*************************************************************************************/

            if(increase_time && hour_minute_opt && !flag_increase_time)
              begin
                hour = hour + sw;
              end
            if(increase_time && !hour_minute_opt && !flag_increase_time)
              begin
                minute = minute + sw;
              end
            flag_increase_time = increase_time;//to decide that adjust once
				
/*************************************************************************************/
/*                           To set the alarm clock                                  */
/*************************************************************************************/				
            if(set_alarm && hour_minute_opt)
              begin
                hour_alarm = 0;
                hour_alarm = hour_alarm + sw[4:0];
              end
            if(set_alarm && !hour_minute_opt)
              begin
                minute_alarm = 0;
                minute_alarm = minute_alarm + sw;
              end
        end
    end

/*************************************************************************************/
/*                     To set 24hours or 12hours, etc.                               */
/*************************************************************************************/	 
  always@(posedge am_pm_change) 
    pm_flag = ~ pm_flag ; 
	 
  assign second_h = clk_cnt[28:21]; 
  assign an[0] = switch[15]||switch[16] ;
  assign an[1] = (~switch[15])||switch[16] ;
  assign an[2] = switch[15]||(~switch[16]) ;
  assign an[3] = (~switch[15])||(~switch[16]) ; 
  assign hour_strike = (minute == 0) && second[0] && (second < 17);
  assign hour_show = hour - 12*(pm_flag && (hour>12)) ;
  assign alarm = (hour == hour_alarm) && (minute == minute_alarm) && second[0] && (second <33) ;
  assign pm = pm_flag && (hour > 12) ;
  always @(posedge clk ) 
    begin
      if(clk)
      begin
        switch = switch + 1 ;
        if(switch[17])
          switch = 0 ;
      end
    end
	 
/*************************************************************************************/
/*                       To show the hour and minute in line                         */
/*************************************************************************************/
  always @(*) 
    case(switch[16:15])
      1:NUM = second[7:4];
      0:NUM = second[3:0];
      2:NUM = minute[3:0];
      3:NUM = minute[7:4];
    endcase
	 
endmodule