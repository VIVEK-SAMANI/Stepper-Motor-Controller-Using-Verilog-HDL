
//Vivek Samani 22bec105
//Special Assignment FPGA based SD
//Stepper motor controller

module Stepper_Motor_Controller(clk_in, clk_out, reset, signal, led_indicaters, dir, frequency);

// Frequency vector
input [0:5] frequency;

// LED INDICATORS FOR SIGNAL
output [3:0] led_indicaters;

input reset;   // Synchronous reset input (Active Low)
input dir;		// Direction pin
output reg [3:0] signal;  // 4-bit output

	assign led_indicaters[0] = signal[0];
	assign led_indicaters[1] = signal[1];
	assign led_indicaters[2] = signal[2];
	assign led_indicaters[3] = signal[3];

	
// Clock divider

input clk_in;
output reg clk_out;
reg [31:0] counter=0;

parameter sys_clk = 50000000;
integer req_clk = 100;
integer max;

always@(*)
begin
	max = sys_clk/req_clk;
end

// Always block for clock divider

always @(posedge clk_in)
	begin
		if (counter < max)
		  counter <= counter + 1'd1;
		else
		  counter = 4'b0000;
	end

always@(counter)
   begin
		if (counter < (max/2))
		  clk_out = 0;	
		else
		  clk_out = 1;	
	end

// Always block to handle signal logic
always @(posedge clk_out)
begin
		if(dir)
		begin
			if (reset) 
			begin
				// Reset signal to initial state
				signal <= 4'b0001;
			end else 
			begin
				// Shift the high bit to the left
				signal <= {signal[2:0], signal[3]};
			end
		end
		// Else block will change direction of motor
		else 
		begin
			if (reset) 
			begin
				// Reset signal to initial state
				signal <= 4'b1000;
			end else 
			begin
				// Shift the low bit to the right
				signal <= {signal[0], signal[3:1]};
			end
		end
end

// Always block for variable frequency using toggle switches
always@(*)
begin
	case(frequency)
    6'b100000: req_clk = 10;
    6'b110000: req_clk = 20;
    6'b111000: req_clk = 50;
    6'b111100: req_clk = 100;
    6'b111111: req_clk = 200;
    default  req_clk = 100; // default value when none of the conditions are met
	endcase
end

endmodule
