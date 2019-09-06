
module DDR3AXI4 (
	afi_half_clk_clk,
	afi_reset_reset_n,
	axi_translator_s0_awid,
	axi_translator_s0_awaddr,
	axi_translator_s0_awlen,
	axi_translator_s0_awsize,
	axi_translator_s0_awburst,
	axi_translator_s0_awlock,
	axi_translator_s0_awcache,
	axi_translator_s0_awprot,
	axi_translator_s0_awqos,
	axi_translator_s0_awvalid,
	axi_translator_s0_awready,
	axi_translator_s0_wdata,
	axi_translator_s0_wstrb,
	axi_translator_s0_wlast,
	axi_translator_s0_wvalid,
	axi_translator_s0_wready,
	axi_translator_s0_bid,
	axi_translator_s0_bresp,
	axi_translator_s0_bvalid,
	axi_translator_s0_bready,
	axi_translator_s0_arid,
	axi_translator_s0_araddr,
	axi_translator_s0_arlen,
	axi_translator_s0_arsize,
	axi_translator_s0_arburst,
	axi_translator_s0_arlock,
	axi_translator_s0_arcache,
	axi_translator_s0_arprot,
	axi_translator_s0_arqos,
	axi_translator_s0_arvalid,
	axi_translator_s0_arready,
	axi_translator_s0_rid,
	axi_translator_s0_rdata,
	axi_translator_s0_rresp,
	axi_translator_s0_rlast,
	axi_translator_s0_rvalid,
	axi_translator_s0_rready,
	clk_clk,
	mem_mem_a,
	mem_mem_ba,
	mem_mem_ck,
	mem_mem_ck_n,
	mem_mem_cke,
	mem_mem_cs_n,
	mem_mem_dm,
	mem_mem_ras_n,
	mem_mem_cas_n,
	mem_mem_we_n,
	mem_mem_reset_n,
	mem_mem_dq,
	mem_mem_dqs,
	mem_mem_dqs_n,
	mem_mem_odt,
	oct_rdn,
	oct_rup,
	pll_sharing_pll_mem_clk,
	pll_sharing_pll_write_clk,
	pll_sharing_pll_locked,
	pll_sharing_pll_write_clk_pre_phy_clk,
	pll_sharing_pll_addr_cmd_clk,
	pll_sharing_pll_avl_clk,
	pll_sharing_pll_config_clk,
	reset_reset_n);	

	output		afi_half_clk_clk;
	output		afi_reset_reset_n;
	input	[3:0]	axi_translator_s0_awid;
	input	[29:0]	axi_translator_s0_awaddr;
	input	[7:0]	axi_translator_s0_awlen;
	input	[2:0]	axi_translator_s0_awsize;
	input	[1:0]	axi_translator_s0_awburst;
	input	[0:0]	axi_translator_s0_awlock;
	input	[3:0]	axi_translator_s0_awcache;
	input	[2:0]	axi_translator_s0_awprot;
	input	[3:0]	axi_translator_s0_awqos;
	input		axi_translator_s0_awvalid;
	output		axi_translator_s0_awready;
	input	[63:0]	axi_translator_s0_wdata;
	input	[7:0]	axi_translator_s0_wstrb;
	input		axi_translator_s0_wlast;
	input		axi_translator_s0_wvalid;
	output		axi_translator_s0_wready;
	output	[3:0]	axi_translator_s0_bid;
	output	[1:0]	axi_translator_s0_bresp;
	output		axi_translator_s0_bvalid;
	input		axi_translator_s0_bready;
	input	[3:0]	axi_translator_s0_arid;
	input	[29:0]	axi_translator_s0_araddr;
	input	[7:0]	axi_translator_s0_arlen;
	input	[2:0]	axi_translator_s0_arsize;
	input	[1:0]	axi_translator_s0_arburst;
	input	[0:0]	axi_translator_s0_arlock;
	input	[3:0]	axi_translator_s0_arcache;
	input	[2:0]	axi_translator_s0_arprot;
	input	[3:0]	axi_translator_s0_arqos;
	input		axi_translator_s0_arvalid;
	output		axi_translator_s0_arready;
	output	[3:0]	axi_translator_s0_rid;
	output	[63:0]	axi_translator_s0_rdata;
	output	[1:0]	axi_translator_s0_rresp;
	output		axi_translator_s0_rlast;
	output		axi_translator_s0_rvalid;
	input		axi_translator_s0_rready;
	input		clk_clk;
	output	[13:0]	mem_mem_a;
	output	[2:0]	mem_mem_ba;
	output	[0:0]	mem_mem_ck;
	output	[0:0]	mem_mem_ck_n;
	output	[0:0]	mem_mem_cke;
	output	[0:0]	mem_mem_cs_n;
	output	[7:0]	mem_mem_dm;
	output	[0:0]	mem_mem_ras_n;
	output	[0:0]	mem_mem_cas_n;
	output	[0:0]	mem_mem_we_n;
	output		mem_mem_reset_n;
	inout	[63:0]	mem_mem_dq;
	inout	[7:0]	mem_mem_dqs;
	inout	[7:0]	mem_mem_dqs_n;
	output	[0:0]	mem_mem_odt;
	input		oct_rdn;
	input		oct_rup;
	output		pll_sharing_pll_mem_clk;
	output		pll_sharing_pll_write_clk;
	output		pll_sharing_pll_locked;
	output		pll_sharing_pll_write_clk_pre_phy_clk;
	output		pll_sharing_pll_addr_cmd_clk;
	output		pll_sharing_pll_avl_clk;
	output		pll_sharing_pll_config_clk;
	input		reset_reset_n;
endmodule
