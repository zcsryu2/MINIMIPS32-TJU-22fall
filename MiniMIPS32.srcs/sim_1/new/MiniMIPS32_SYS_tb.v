`timescale 1ps / 1ps

module MiniMIPS32_SYS_tb();

    // Inputs
	reg sys_clk_200M_p;
	reg sys_clk_200M_n;
	reg sys_rst_n;
	
	MiniMIPS32_SYS SoC (
		.sys_clk_200M_p(sys_clk_200M_p),
		.sys_clk_200M_n(sys_clk_200M_n),
		.sys_rst_n(sys_rst_n)
	);
	
	initial begin
		// Initialize Inputs
		sys_clk_200M_p = 1'b0;
		sys_clk_200M_n = 1'b1;
		sys_rst_n = 0;
		
		sys_rst_n = 1'b0;
		#200_000;
		sys_rst_n = 1'b1;
		
		#50_000_000 $stop;
	end
	
	always #2500 sys_clk_200M_p = ~sys_clk_200M_p;     // 每隔2.5ns，sys_clk_200M_p信号翻转一次，所以一个周期是5ns，对应200MHz
	always #2500 sys_clk_200M_n = ~sys_clk_200M_n;     // 每隔2.5ns，sys_clk_200M_n信号翻转一次，所以一个周期是5ns，对应200MHz

endmodule
// `timescale 1ns / 1ps
// module MiniMIPS32_SYS_tb();
// 	reg clka,ena;
// 	reg [31:0] addra;
// 	wire [31:0] douta;

// 	inst_rom uut(
// 		.clka(clka),
// 		.ena(ena),
// 		.addra(addra[12:2]),
// 		.douta(douta)
// 	);
// 	initial begin
// 		clka = 0; ena = 0; addra = 0;
// 		#100 ena = 1; addra = 4;
// 		#50 addra = 8;
// 		#50 addra = 12;
// 		#50 addra = 16;
// 		#50 $finish;
// 	end

// 	always begin
// 		#10 clka = ~clka;
// 	end
		
	
// endmodule