`include "defines.v"

module if_stage (
    input 	wire 					cpu_clk_50M,
    input 	wire 					cpu_rst_n,
    input   wire [`STALL_BUS    ]   stall,

    //延迟槽
    input  wire [`INST_ADDR_BUS]    jump_addr_1,
    input  wire [`INST_ADDR_BUS]    jump_addr_2,
    input  wire [`INST_ADDR_BUS]    jump_addr_3,
    input  wire [`JTSEL_BUS]        jtsel,

    //pc+4
    output  wire [`INST_ADDR_BUS]   pc_plus_4,
    output  wire                     ice,
    output 	reg  [`INST_ADDR_BUS] 	pc,
    output 	wire [`INST_ADDR_BUS]	iaddr
    );
    
    assign pc_plus_4 = (cpu_rst_n == `RST_ENABLE) ? `PC_INIT : pc + 4;
    wire [`INST_ADDR_BUS] pc_next;
    
    assign pc_next = (jtsel == 2'b00) ? pc_plus_4 : 
                     (jtsel == 2'b01) ? jump_addr_1 :           
                     (jtsel == 2'b10) ? jump_addr_3 :        
                     jump_addr_2 ;                // 计算下一条指令的地址
    reg ce;
    always @(posedge cpu_clk_50M) begin
		if (cpu_rst_n == `RST_ENABLE) begin
			ce <= `CHIP_DISABLE;		      // 复位的时候指令存储器禁用  
		end else begin
			ce <= `CHIP_ENABLE; 		      // 复位结束后，指令存储器使能
		end
	end

    assign ice = (stall[1] == `TRUE_V) ? 0 : ce;

    always @(posedge cpu_clk_50M) begin
        if (ce == `CHIP_DISABLE)
            pc <= `PC_INIT;                   // 指令存储器禁用的时候，PC保持初始值（MiniMIPS32中设置为0xBFC00000）
        else if(stall[0] == `NOSTOP) begin
            pc <= pc_next;                    // 指令存储器使能后，PC值每时钟周期加4 	
        end
    end
    
    // TODO：指令存储器的访问地址没有根据其所处范围进行进行固定地址映射，需要修改!!!
    wire [`INST_ADDR_BUS] tmp= (ice == `CHIP_DISABLE) ? `PC_INIT : pc;    // 获得访问指令存储器的地址
    assign iaddr = tmp&32'h1FFFFFFF;
endmodule
