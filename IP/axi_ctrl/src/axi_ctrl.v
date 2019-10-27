/*
 * AXI BRAM controller. Assumes single cycle BRAM. Latency optimized.
 *
 * Author: Carsten Heinz <heinz@esa.tu-darmstadt.de>
 * Copyright (c) 2019 Embedded Systems and Applications Group, TU Darmstadt
 */

`default_nettype none

module axi_ctrl #(
    parameter BYTES_PER_WORD = 4,
    parameter ADDRESS_WIDTH = 32,
    parameter MEM_SIZE = 65536,
    parameter ID_WIDTH = 6,
    parameter READ_ONLY = 0,
    parameter AXI_PROTOCOL = "AXI4"
) (
    input wire CLK,
    input wire RST_N,

    output reg [7:0] status,

    input  wire [ADDRESS_WIDTH-1:0]     S_AXI_araddr,
    input  wire [7:0]                   S_AXI_arlen,
    input  wire [2:0]                   S_AXI_arprot,
    input  wire [2:0]                   S_AXI_arsize,
    input  wire [1:0]                   S_AXI_arburst,
    input  wire                         S_AXI_arlock,
    input  wire [3:0]                   S_AXI_arcache,
    input  wire [3:0]                   S_AXI_arqos,
    input  wire [3:0]                   S_AXI_arregion,
    input  wire                         S_AXI_aruser,
    input  wire [ID_WIDTH-1:0]          S_AXI_arid,
    output wire                         S_AXI_arready,
    input  wire                         S_AXI_arvalid,
    input  wire [ADDRESS_WIDTH-1:0]     S_AXI_awaddr,
    input  wire [7:0]                   S_AXI_awlen,
    input  wire [2:0]                   S_AXI_awprot,
    input  wire [2:0]                   S_AXI_awsize,
    input  wire [1:0]                   S_AXI_awburst,
    input  wire                         S_AXI_awlock,
    input  wire [3:0]                   S_AXI_awcache,
    input  wire [3:0]                   S_AXI_awqos,
    input  wire [3:0]                   S_AXI_awregion,
    input  wire                         S_AXI_awuser,
    input  wire [ID_WIDTH-1:0]          S_AXI_awid,
    output wire                         S_AXI_awready,
    input  wire                         S_AXI_awvalid,
    input  wire                         S_AXI_bready,
    output wire                         S_AXI_bvalid,
    output wire [ID_WIDTH-1:0]          S_AXI_bid,
    output wire [1:0]                   S_AXI_bresp,
    output wire                         S_AXI_buser,
    output wire [BYTES_PER_WORD*8-1:0]  S_AXI_rdata,
    output wire                         S_AXI_rlast,
    input  wire                         S_AXI_rready,
    output wire                         S_AXI_rvalid,
    output wire [ID_WIDTH-1:0]          S_AXI_rid,
    output wire [1:0]                   S_AXI_rresp,
    output wire                         S_AXI_ruser,
    input  wire [BYTES_PER_WORD*8-1:0]  S_AXI_wdata,
    input  wire [BYTES_PER_WORD-1:0]    S_AXI_wstrb,
    input  wire                         S_AXI_wlast,
    output wire                         S_AXI_wready,
    input  wire                         S_AXI_wvalid,

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 bram CLK" *)
    output wire        bram_clk,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 bram RST" *)
    output wire        bram_rst,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 bram ADDR" *)
    output wire [ADDRESS_WIDTH-1:0] bram_addr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 bram EN" *)
    output wire        bram_en,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 bram WE" *)
    output wire [BYTES_PER_WORD-1:0]   bram_we,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 bram DIN" *)
    output wire [BYTES_PER_WORD*8-1:0] bram_din,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 bram DOUT" *)
    input  wire [BYTES_PER_WORD*8-1:0] bram_dout
);

assign S_AXI_buser = 0;
assign S_AXI_rresp = 0;
assign S_AXI_ruser = 0;

generate
if (AXI_PROTOCOL == "AXI4LITE") begin
    reg arvalid_reg;
    
    assign bram_clk = CLK;
    assign bram_rst = !RST_N;
    assign S_AXI_arready = 1;
    assign S_AXI_rvalid = arvalid_reg;
    assign S_AXI_rdata = bram_dout;
    
    always @(posedge CLK) begin
        if (!RST_N) begin
            arvalid_reg <= 0;
        end else begin
            arvalid_reg <= S_AXI_arvalid;
        end
    end

    always @(posedge CLK) begin
        if (!RST_N) begin
            status[0] <= 0;
        end else begin
            if (S_AXI_rvalid && !S_AXI_rready) begin
                status[0] <= 1;
                $display("AXI lite master should accept data within one cycle.");
                $finish;
            end
        end
    end

    if(READ_ONLY == 1) begin
        assign bram_addr = S_AXI_araddr;
        assign bram_en = S_AXI_arvalid;
        assign bram_we = 0;
        assign bram_din = 0;
        assign S_AXI_awready = 0;
        assign S_AXI_wready = 0;
        assign S_AXI_bid = 0;
        assign S_AXI_bresp = 0;
        assign S_AXI_bvalid = 0;
    end else begin
        reg wvalid_reg;
        assign bram_addr = (S_AXI_awvalid) ? S_AXI_awaddr : S_AXI_araddr;
        assign bram_en = S_AXI_arvalid | S_AXI_wvalid;
        assign bram_din = S_AXI_wdata;
        assign bram_we = (S_AXI_wvalid) ? S_AXI_wstrb : 0;
        assign S_AXI_awready = 1;
        assign S_AXI_wready = 1;
        assign S_AXI_bresp = 0;
        assign S_AXI_bvalid = wvalid_reg;

        always @(posedge CLK) begin
            if (!RST_N) begin
                wvalid_reg <= 0;
            end else begin
                wvalid_reg <= S_AXI_wvalid;
            end
        end
        
        reg [ADDRESS_WIDTH-1:0] awaddr;

        always @(posedge CLK) begin
            if (!RST_N) begin
                status[1] <= 0;
                status[2] <= 0;
                status[7:3] <= 0;
            end else begin
                if (S_AXI_awvalid)
                    awaddr <= S_AXI_awaddr;
                if (S_AXI_wvalid && !S_AXI_awvalid && awaddr != S_AXI_awaddr) begin
                    status[1] <= 1;
                    // Write: address and data not in same beat, but should still use same address
                    $display("Address stays not constant for write");
                    $finish;
                end
                if (S_AXI_arvalid && S_AXI_awvalid) begin
                    status[2] <= 1;
                    // This is a simplification
                    $display("AXI lite master never read and write in same cycle.");
                    $finish;
                end
            end
        end
    end
end else begin // AXI4 FULL

    reg[8:0] arlen_reg;
    reg [ADDRESS_WIDTH-1:0] araddr_reg, awaddr_reg;
    reg [ID_WIDTH-1:0] rid, wid;
    
    assign bram_clk = CLK;
    assign bram_rst = !RST_N;
    assign S_AXI_arready = 1;
    assign S_AXI_rvalid = (arlen_reg > 0);
    assign S_AXI_rdata = bram_dout;
    assign S_AXI_rlast = (arlen_reg == 1);
    assign S_AXI_rid = rid;
    
    always @(posedge CLK) begin
        if (!RST_N) begin
            arlen_reg <= 0;
            araddr_reg <= 0;
            rid <= 0;
        end else begin
            rid <= S_AXI_arvalid ? S_AXI_arid : rid;
            arlen_reg <= S_AXI_arvalid ? (S_AXI_arlen + 1) : 
                            ((arlen_reg > 0) ? arlen_reg - 1 : 0);
            araddr_reg <= S_AXI_arvalid ? (S_AXI_araddr + BYTES_PER_WORD) : (araddr_reg + BYTES_PER_WORD);
        end
    end

    always @(posedge CLK) begin
        if (!RST_N) begin
            status[0] <= 0;
        end else begin
            if (S_AXI_rvalid && !S_AXI_rready) begin
                status[0] <= 1;
                $display("AXI master should accept data within one cycle.");
                $finish;
            end
        end
    end

    if(READ_ONLY == 1) begin
        assign bram_addr = S_AXI_arvalid ? S_AXI_araddr : araddr_reg;
        assign bram_en = S_AXI_arvalid | (arlen_reg > 1);
        assign bram_we = 0;
        assign bram_din = 0;
        assign S_AXI_awready = 0;
        assign S_AXI_wready = 0;
        assign S_AXI_bid = 0;
        assign S_AXI_bresp = 0;
        assign S_AXI_bvalid = 0;
    end else begin
        reg wlast_reg;
        reg [1:0] wen_reg;
        reg [BYTES_PER_WORD*8-1:0] wdata_reg;
        assign bram_addr = (S_AXI_wvalid) ? (S_AXI_awvalid ? S_AXI_awaddr : awaddr_reg) : 
                                (S_AXI_arvalid ? S_AXI_araddr : araddr_reg);
        assign bram_en = S_AXI_arvalid | S_AXI_wvalid;
        assign bram_din = S_AXI_wvalid ? S_AXI_wdata : wdata_reg;
        assign bram_we = ((S_AXI_awvalid && S_AXI_wvalid) || (wen_reg[0] && S_AXI_wvalid) || (wen_reg[1] && S_AXI_awvalid)) ? S_AXI_wstrb : 0;
        assign S_AXI_awready = 1;
        assign S_AXI_wready = 1;
        assign S_AXI_bresp = 0;
        assign S_AXI_bvalid = wlast_reg;
        assign S_AXI_bid = wid;

        always @(posedge CLK) begin
            if (!RST_N) begin
                wlast_reg <= 0;
                wid = 0;
                wdata_reg <= 0;
                wen_reg <= 0;
            end else begin
                wlast_reg <= (wlast_reg && !S_AXI_bready) ? 1 : S_AXI_wlast && S_AXI_wvalid;
                wid <= S_AXI_awvalid ? S_AXI_awid : wid;
                awaddr_reg <= S_AXI_awvalid ? S_AXI_awaddr : awaddr_reg;
                wdata_reg <= S_AXI_wvalid ? S_AXI_wdata : wdata_reg;
                if (S_AXI_wvalid && !S_AXI_awvalid) begin
                    // data before address
                    wen_reg[1] <= 1;
                end else if (wen_reg[1] && S_AXI_awvalid) begin
                    wen_reg[1] <= 0;
                end
                if (S_AXI_awvalid && !S_AXI_wvalid) begin
                    // addr before address
                    wen_reg[0] <= 1;
                end else if (wen_reg[0] && S_AXI_wvalid) begin
                    wen_reg[0] <= 0;
                end
            end
        end

        reg write_addr_set;

        always @(posedge CLK) begin
            if (!RST_N) begin
                status[1] <= 0;
                status[2] <= 0;
                status[3] <= 0;
                status[7:4] <= 0;
                write_addr_set <= 0;
            end else begin
                if (S_AXI_arvalid && S_AXI_awvalid) begin
                    status[1] <= 1;
                    // This is a simplification
                    $display("AXI full master never read and write in same cycle.");
                    $finish;
                end
                if (S_AXI_awvalid && S_AXI_awlen != 0) begin
                    status[2] <= 1;
                    // This is a simplification
                    $display("We currently do not support write bursts.");
                    $finish;
                end
                if (S_AXI_awvalid && arlen_reg != 0) begin
                    status[3] <= 1;
                    // This is a simplification
                    $display("Read was interrupted by write.");
                    $finish;
                end
                if (!write_addr_set && !S_AXI_awvalid && S_AXI_wvalid) begin
                    status[4] <= 1;
                    $display("write data should not be there before address.");
                    $finish;
                end
                if (write_addr_set && S_AXI_awvalid) begin
                    status[5] <= 1;
                    $display("No overlapping writes are supported");
                    $finish;
                end else if (S_AXI_awvalid && !S_AXI_wvalid) begin
                    write_addr_set <= 1;
                end else if (write_addr_set && S_AXI_wvalid) begin
                    write_addr_set <= 0;
                end
                if (S_AXI_wlast && S_AXI_wvalid && wlast_reg) begin
                    status[6] <= 1;
                    $display("no overlapping writes are supported, bresp");
                    $finish;
                end
            end
        end
    end
end
endgenerate

always @(posedge CLK) begin
    if(RST_N && status != 0) begin
        $display("Status is %h", status);
        $finish;
    end
end

endmodule

`default_nettype wire
