	component DDR3AXI4 is
		port (
			afi_clk_clk                           : out   std_logic;                                        -- clk
			afi_reset_reset_n                     : out   std_logic;                                        -- reset_n
			axi_translator_s0_awid                : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- awid
			axi_translator_s0_awaddr              : in    std_logic_vector(29 downto 0) := (others => 'X'); -- awaddr
			axi_translator_s0_awlen               : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- awlen
			axi_translator_s0_awsize              : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- awsize
			axi_translator_s0_awburst             : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- awburst
			axi_translator_s0_awlock              : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- awlock
			axi_translator_s0_awcache             : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- awcache
			axi_translator_s0_awprot              : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- awprot
			axi_translator_s0_awqos               : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- awqos
			axi_translator_s0_awvalid             : in    std_logic                     := 'X';             -- awvalid
			axi_translator_s0_awready             : out   std_logic;                                        -- awready
			axi_translator_s0_wdata               : in    std_logic_vector(63 downto 0) := (others => 'X'); -- wdata
			axi_translator_s0_wstrb               : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- wstrb
			axi_translator_s0_wlast               : in    std_logic                     := 'X';             -- wlast
			axi_translator_s0_wvalid              : in    std_logic                     := 'X';             -- wvalid
			axi_translator_s0_wready              : out   std_logic;                                        -- wready
			axi_translator_s0_bid                 : out   std_logic_vector(3 downto 0);                     -- bid
			axi_translator_s0_bresp               : out   std_logic_vector(1 downto 0);                     -- bresp
			axi_translator_s0_bvalid              : out   std_logic;                                        -- bvalid
			axi_translator_s0_bready              : in    std_logic                     := 'X';             -- bready
			axi_translator_s0_arid                : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- arid
			axi_translator_s0_araddr              : in    std_logic_vector(29 downto 0) := (others => 'X'); -- araddr
			axi_translator_s0_arlen               : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- arlen
			axi_translator_s0_arsize              : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- arsize
			axi_translator_s0_arburst             : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- arburst
			axi_translator_s0_arlock              : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- arlock
			axi_translator_s0_arcache             : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- arcache
			axi_translator_s0_arprot              : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- arprot
			axi_translator_s0_arqos               : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- arqos
			axi_translator_s0_arvalid             : in    std_logic                     := 'X';             -- arvalid
			axi_translator_s0_arready             : out   std_logic;                                        -- arready
			axi_translator_s0_rid                 : out   std_logic_vector(3 downto 0);                     -- rid
			axi_translator_s0_rdata               : out   std_logic_vector(63 downto 0);                    -- rdata
			axi_translator_s0_rresp               : out   std_logic_vector(1 downto 0);                     -- rresp
			axi_translator_s0_rlast               : out   std_logic;                                        -- rlast
			axi_translator_s0_rvalid              : out   std_logic;                                        -- rvalid
			axi_translator_s0_rready              : in    std_logic                     := 'X';             -- rready
			clk_clk                               : in    std_logic                     := 'X';             -- clk
			mem_mem_a                             : out   std_logic_vector(14 downto 0);                    -- mem_a
			mem_mem_ba                            : out   std_logic_vector(2 downto 0);                     -- mem_ba
			mem_mem_ck                            : out   std_logic_vector(0 downto 0);                     -- mem_ck
			mem_mem_ck_n                          : out   std_logic_vector(0 downto 0);                     -- mem_ck_n
			mem_mem_cke                           : out   std_logic_vector(0 downto 0);                     -- mem_cke
			mem_mem_cs_n                          : out   std_logic_vector(0 downto 0);                     -- mem_cs_n
			mem_mem_dm                            : out   std_logic_vector(3 downto 0);                     -- mem_dm
			mem_mem_ras_n                         : out   std_logic_vector(0 downto 0);                     -- mem_ras_n
			mem_mem_cas_n                         : out   std_logic_vector(0 downto 0);                     -- mem_cas_n
			mem_mem_we_n                          : out   std_logic_vector(0 downto 0);                     -- mem_we_n
			mem_mem_reset_n                       : out   std_logic;                                        -- mem_reset_n
			mem_mem_dq                            : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
			mem_mem_dqs                           : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs
			mem_mem_dqs_n                         : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_n
			mem_mem_odt                           : out   std_logic_vector(0 downto 0);                     -- mem_odt
			oct_rzqin                             : in    std_logic                     := 'X';             -- rzqin
			pll_sharing_pll_mem_clk               : out   std_logic;                                        -- pll_mem_clk
			pll_sharing_pll_write_clk             : out   std_logic;                                        -- pll_write_clk
			pll_sharing_pll_locked                : out   std_logic;                                        -- pll_locked
			pll_sharing_pll_write_clk_pre_phy_clk : out   std_logic;                                        -- pll_write_clk_pre_phy_clk
			pll_sharing_pll_addr_cmd_clk          : out   std_logic;                                        -- pll_addr_cmd_clk
			pll_sharing_pll_avl_clk               : out   std_logic;                                        -- pll_avl_clk
			pll_sharing_pll_config_clk            : out   std_logic;                                        -- pll_config_clk
			pll_sharing_pll_mem_phy_clk           : out   std_logic;                                        -- pll_mem_phy_clk
			pll_sharing_afi_phy_clk               : out   std_logic;                                        -- afi_phy_clk
			pll_sharing_pll_avl_phy_clk           : out   std_logic;                                        -- pll_avl_phy_clk
			reset_reset_n                         : in    std_logic                     := 'X'              -- reset_n
		);
	end component DDR3AXI4;

	u0 : component DDR3AXI4
		port map (
			afi_clk_clk                           => CONNECTED_TO_afi_clk_clk,                           --           afi_clk.clk
			afi_reset_reset_n                     => CONNECTED_TO_afi_reset_reset_n,                     --         afi_reset.reset_n
			axi_translator_s0_awid                => CONNECTED_TO_axi_translator_s0_awid,                -- axi_translator_s0.awid
			axi_translator_s0_awaddr              => CONNECTED_TO_axi_translator_s0_awaddr,              --                  .awaddr
			axi_translator_s0_awlen               => CONNECTED_TO_axi_translator_s0_awlen,               --                  .awlen
			axi_translator_s0_awsize              => CONNECTED_TO_axi_translator_s0_awsize,              --                  .awsize
			axi_translator_s0_awburst             => CONNECTED_TO_axi_translator_s0_awburst,             --                  .awburst
			axi_translator_s0_awlock              => CONNECTED_TO_axi_translator_s0_awlock,              --                  .awlock
			axi_translator_s0_awcache             => CONNECTED_TO_axi_translator_s0_awcache,             --                  .awcache
			axi_translator_s0_awprot              => CONNECTED_TO_axi_translator_s0_awprot,              --                  .awprot
			axi_translator_s0_awqos               => CONNECTED_TO_axi_translator_s0_awqos,               --                  .awqos
			axi_translator_s0_awvalid             => CONNECTED_TO_axi_translator_s0_awvalid,             --                  .awvalid
			axi_translator_s0_awready             => CONNECTED_TO_axi_translator_s0_awready,             --                  .awready
			axi_translator_s0_wdata               => CONNECTED_TO_axi_translator_s0_wdata,               --                  .wdata
			axi_translator_s0_wstrb               => CONNECTED_TO_axi_translator_s0_wstrb,               --                  .wstrb
			axi_translator_s0_wlast               => CONNECTED_TO_axi_translator_s0_wlast,               --                  .wlast
			axi_translator_s0_wvalid              => CONNECTED_TO_axi_translator_s0_wvalid,              --                  .wvalid
			axi_translator_s0_wready              => CONNECTED_TO_axi_translator_s0_wready,              --                  .wready
			axi_translator_s0_bid                 => CONNECTED_TO_axi_translator_s0_bid,                 --                  .bid
			axi_translator_s0_bresp               => CONNECTED_TO_axi_translator_s0_bresp,               --                  .bresp
			axi_translator_s0_bvalid              => CONNECTED_TO_axi_translator_s0_bvalid,              --                  .bvalid
			axi_translator_s0_bready              => CONNECTED_TO_axi_translator_s0_bready,              --                  .bready
			axi_translator_s0_arid                => CONNECTED_TO_axi_translator_s0_arid,                --                  .arid
			axi_translator_s0_araddr              => CONNECTED_TO_axi_translator_s0_araddr,              --                  .araddr
			axi_translator_s0_arlen               => CONNECTED_TO_axi_translator_s0_arlen,               --                  .arlen
			axi_translator_s0_arsize              => CONNECTED_TO_axi_translator_s0_arsize,              --                  .arsize
			axi_translator_s0_arburst             => CONNECTED_TO_axi_translator_s0_arburst,             --                  .arburst
			axi_translator_s0_arlock              => CONNECTED_TO_axi_translator_s0_arlock,              --                  .arlock
			axi_translator_s0_arcache             => CONNECTED_TO_axi_translator_s0_arcache,             --                  .arcache
			axi_translator_s0_arprot              => CONNECTED_TO_axi_translator_s0_arprot,              --                  .arprot
			axi_translator_s0_arqos               => CONNECTED_TO_axi_translator_s0_arqos,               --                  .arqos
			axi_translator_s0_arvalid             => CONNECTED_TO_axi_translator_s0_arvalid,             --                  .arvalid
			axi_translator_s0_arready             => CONNECTED_TO_axi_translator_s0_arready,             --                  .arready
			axi_translator_s0_rid                 => CONNECTED_TO_axi_translator_s0_rid,                 --                  .rid
			axi_translator_s0_rdata               => CONNECTED_TO_axi_translator_s0_rdata,               --                  .rdata
			axi_translator_s0_rresp               => CONNECTED_TO_axi_translator_s0_rresp,               --                  .rresp
			axi_translator_s0_rlast               => CONNECTED_TO_axi_translator_s0_rlast,               --                  .rlast
			axi_translator_s0_rvalid              => CONNECTED_TO_axi_translator_s0_rvalid,              --                  .rvalid
			axi_translator_s0_rready              => CONNECTED_TO_axi_translator_s0_rready,              --                  .rready
			clk_clk                               => CONNECTED_TO_clk_clk,                               --               clk.clk
			mem_mem_a                             => CONNECTED_TO_mem_mem_a,                             --               mem.mem_a
			mem_mem_ba                            => CONNECTED_TO_mem_mem_ba,                            --                  .mem_ba
			mem_mem_ck                            => CONNECTED_TO_mem_mem_ck,                            --                  .mem_ck
			mem_mem_ck_n                          => CONNECTED_TO_mem_mem_ck_n,                          --                  .mem_ck_n
			mem_mem_cke                           => CONNECTED_TO_mem_mem_cke,                           --                  .mem_cke
			mem_mem_cs_n                          => CONNECTED_TO_mem_mem_cs_n,                          --                  .mem_cs_n
			mem_mem_dm                            => CONNECTED_TO_mem_mem_dm,                            --                  .mem_dm
			mem_mem_ras_n                         => CONNECTED_TO_mem_mem_ras_n,                         --                  .mem_ras_n
			mem_mem_cas_n                         => CONNECTED_TO_mem_mem_cas_n,                         --                  .mem_cas_n
			mem_mem_we_n                          => CONNECTED_TO_mem_mem_we_n,                          --                  .mem_we_n
			mem_mem_reset_n                       => CONNECTED_TO_mem_mem_reset_n,                       --                  .mem_reset_n
			mem_mem_dq                            => CONNECTED_TO_mem_mem_dq,                            --                  .mem_dq
			mem_mem_dqs                           => CONNECTED_TO_mem_mem_dqs,                           --                  .mem_dqs
			mem_mem_dqs_n                         => CONNECTED_TO_mem_mem_dqs_n,                         --                  .mem_dqs_n
			mem_mem_odt                           => CONNECTED_TO_mem_mem_odt,                           --                  .mem_odt
			oct_rzqin                             => CONNECTED_TO_oct_rzqin,                             --               oct.rzqin
			pll_sharing_pll_mem_clk               => CONNECTED_TO_pll_sharing_pll_mem_clk,               --       pll_sharing.pll_mem_clk
			pll_sharing_pll_write_clk             => CONNECTED_TO_pll_sharing_pll_write_clk,             --                  .pll_write_clk
			pll_sharing_pll_locked                => CONNECTED_TO_pll_sharing_pll_locked,                --                  .pll_locked
			pll_sharing_pll_write_clk_pre_phy_clk => CONNECTED_TO_pll_sharing_pll_write_clk_pre_phy_clk, --                  .pll_write_clk_pre_phy_clk
			pll_sharing_pll_addr_cmd_clk          => CONNECTED_TO_pll_sharing_pll_addr_cmd_clk,          --                  .pll_addr_cmd_clk
			pll_sharing_pll_avl_clk               => CONNECTED_TO_pll_sharing_pll_avl_clk,               --                  .pll_avl_clk
			pll_sharing_pll_config_clk            => CONNECTED_TO_pll_sharing_pll_config_clk,            --                  .pll_config_clk
			pll_sharing_pll_mem_phy_clk           => CONNECTED_TO_pll_sharing_pll_mem_phy_clk,           --                  .pll_mem_phy_clk
			pll_sharing_afi_phy_clk               => CONNECTED_TO_pll_sharing_afi_phy_clk,               --                  .afi_phy_clk
			pll_sharing_pll_avl_phy_clk           => CONNECTED_TO_pll_sharing_pll_avl_phy_clk,           --                  .pll_avl_phy_clk
			reset_reset_n                         => CONNECTED_TO_reset_reset_n                          --             reset.reset_n
		);

