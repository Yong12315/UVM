module dut (
    input  wire                         clk                         ,
    input  wire                         rst_n                       ,
    input  wire        [   7: 0]        wr_data                     ,
    input  wire                         wr_en                       ,
    output reg         [   7: 0]        rd_data                     ,
    output reg                          rd_valid                    ,
    output wire                         empty                       ,
    output wire                         full                         
);

reg                [   7: 0]        mem[15:0]                   ;
wire               [   3: 0]        wr_addr                     ;
wire               [   3: 0]        rd_addr                     ;
reg                [   4: 0]        wr_addr_a                   ;
reg                [   4: 0]        rd_addr_a                   ;

reg                                 rd_en, rd_en_r0, rd_en_r1   ;

assign rd_addr = rd_addr_a[3:0];
assign wr_addr = wr_addr_a[3:0];

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_addr_a <= 0;
    end
    else begin
    if(rd_en==1 && empty==0) begin
        rd_data <= mem[rd_addr];
        rd_valid <= 1'b1;
        rd_addr_a <= rd_addr_a + 1;
    end
    else begin
        rd_data <= rd_data;
        rd_valid <= 1'b0;
        rd_addr_a <= rd_addr_a;
    end
    end
end

always @ (posedge clk or negedge rst_n)
    begin
    if(!rst_n) begin
        wr_addr_a <= 0;
    end
    else begin
    if(wr_en==1 && full==0) begin
        mem[wr_addr] <= wr_data;
        wr_addr_a <= wr_addr_a + 1;
    end
    else begin
        mem[wr_addr] <= mem[rd_addr];
        wr_addr_a <= wr_addr_a;
    end
    end
end

assign empty = (rd_addr_a==wr_addr_a)?1:0;
assign full = ((rd_addr_a[4]!=wr_addr_a[4])&&(rd_addr_a[3:0]==wr_addr_a[3:0]))?1:0;

always @ (posedge clk) begin
    rd_en_r0 <= wr_en;
    rd_en_r1 <= rd_en_r0;
    rd_en <= rd_en_r1;
end

endmodule

