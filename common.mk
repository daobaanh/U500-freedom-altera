# See LICENSE for license details.

# Required variables:
# - MODEL
# - PROJECT
# - CONFIG_PROJECT
# - CONFIG
# - BUILD_DIR
# - FPGA_DIR

# Optional variables:
# - EXTRA_FPGA_VSRCS

# export to bootloader
export ROMCONF=$(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).rom.conf

# export to fpga-shells
export FPGA_TOP_SYSTEM=$(MODEL)
export FPGA_BUILD_DIR=$(BUILD_DIR)/$(FPGA_TOP_SYSTEM)
export fpga_common_script_dir=$(FPGA_DIR)/common/tcl
export fpga_board_script_dir=$(FPGA_DIR)/$(BOARD)/tcl

export BUILD_DIR

EXTRA_FPGA_VSRCS ?=
PATCHVERILOG ?= ""
BOOTROM_DIR ?= ""

base_dir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
export rocketchip_dir := $(base_dir)/rocket-chip
SBT ?= java -jar $(rocketchip_dir)/sbt-launch.jar ++2.12.4

# Build firrtl.jar and put it where chisel3 can find it.
FIRRTL_JAR ?= $(rocketchip_dir)/firrtl/utils/bin/firrtl.jar
FIRRTL ?= java -Xmx2G -Xss8M -XX:MaxPermSize=256M -cp $(FIRRTL_JAR) firrtl.Driver

$(FIRRTL_JAR): $(shell find $(rocketchip_dir)/firrtl/src/main/scala -iname "*.scala")
	$(MAKE) -C $(rocketchip_dir)/firrtl SBT="$(SBT)" root_dir=$(rocketchip_dir)/firrtl build-scala
	touch $(FIRRTL_JAR)
	mkdir -p $(rocketchip_dir)/lib
	cp -p $(FIRRTL_JAR) rocket-chip/lib
	mkdir -p $(rocketchip_dir)/chisel3/lib
	cp -p $(FIRRTL_JAR) $(rocketchip_dir)/chisel3/lib

# Build .fir
firrtl := $(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).fir
$(firrtl): $(shell find $(base_dir)/src/main/scala -name '*.scala') $(FIRRTL_JAR)
ifeq ($(keystone),yes)
	sed -i -e 's/MaskROMParams(address\s=\s0x10000/MaskROMParams(address = 0x78000000/g' src/main/scala/unleashed/DevKitConfigs.scala
else
	sed -i -e 's/MaskROMParams(address\s=\s0x78000000/MaskROMParams(address = 0x10000/g' src/main/scala/unleashed/DevKitConfigs.scala
endif
ifeq ($(pcie),yes)
	sed -i -e 's/\/\/val\spcie\s\s\s\s\s\s=\sOverlay(PCIeOverlayKey)/  val pcie      = Overlay(PCIeOverlayKey)/g' fpga-shells/src/main/scala/shell/xilinx/VC707NewShell.scala
else
	sed -i -e 's/\s\sval\spcie\s\s\s\s\s\s=\sOverlay(PCIeOverlayKey)/\/\/val pcie      = Overlay(PCIeOverlayKey)/g' fpga-shells/src/main/scala/shell/xilinx/VC707NewShell.scala
endif
	mkdir -p $(dir $@)
	$(SBT) "runMain freechips.rocketchip.system.Generator $(BUILD_DIR) $(PROJECT) $(MODEL) $(CONFIG_PROJECT) $(CONFIG)"

.PHONY: firrtl
firrtl: $(firrtl)

# Build .v
verilog := $(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).v
$(verilog): $(firrtl) $(FIRRTL_JAR)
	$(FIRRTL) -i $(firrtl) -o $@ -X verilog
ifneq ($(PATCHVERILOG),"")
	$(PATCHVERILOG)
endif

.PHONY: verilog
verilog: $(verilog)

romgen := $(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).rom.v
$(romgen): $(verilog)
ifneq ($(BOOTROM_DIR),"")
	$(MAKE) -C $(BOOTROM_DIR) romgen
	mv $(BUILD_DIR)/rom.v $@
endif

.PHONY: romgen
romgen: $(romgen)

f := $(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).vsrcs.F
$(f):
	echo $(VSRCS) > $@

bit := $(BUILD_DIR)/obj/$(MODEL).bit
$(bit): $(romgen) $(f)
	cd $(BUILD_DIR); vivado \
		-nojournal -mode batch \
		-source $(fpga_common_script_dir)/vivado.tcl \
		-tclargs \
		-top-module "$(MODEL)" \
		-F "$(f)" \
		-ip-vivado-tcls "$(shell find '$(BUILD_DIR)' -name '*.vivado.tcl')" \
		-board "$(BOARD)"


# Build .mcs
mcs := $(BUILD_DIR)/obj/$(MODEL).mcs
$(mcs): $(bit)
	cd $(BUILD_DIR); vivado -nojournal -mode batch -source $(fpga_common_script_dir)/write_cfgmem.tcl -tclargs $(BOARD) $@ $<

.PHONY: mcs
mcs: $(mcs)

# Build Libero project
prjx := $(BUILD_DIR)/libero/$(MODEL).prjx
$(prjx): $(verilog)
	cd $(BUILD_DIR); libero SCRIPT:$(fpga_common_script_dir)/libero.tcl SCRIPT_ARGS:"$(BUILD_DIR) $(MODEL) $(PROJECT) $(CONFIG) $(BOARD)"

.PHONY: prjx
prjx: $(prjx)

####################################################################

# Modify verilog code in order to be worked with Altera FPGA
altera_TR4 := $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
$(altera_TR4): $(mcs)
	mkdir -p $(base_dir)/builds/altera_TR4_board
	cp -p $(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).v $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	cp -p $(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).rom.v $(base_dir)/builds/altera_TR4_board/TR4_freedom.rom.v
	cp -p $(rocketchip_dir)/src/main/resources/vsrc/AsyncResetReg.v $(base_dir)/builds/altera_TR4_board/AsyncResetReg.v
	cp -p $(rocketchip_dir)/src/main/resources/vsrc/plusarg_reader.v $(base_dir)/builds/altera_TR4_board/plusarg_reader.v
	cp -p $(FPGA_DIR)/common/vsrc/PowerOnResetFPGAOnly.v $(base_dir)/builds/altera_TR4_board/PowerOnResetFPGAOnly.v
	cp -p $(BUILD_DIR)/vc707zsbl.hex $(base_dir)/builds/altera_TR4_board/vc707zsbl.hex              
	####### replace blackbox ###########
	sed -i -e '/vc707mig1gb\sblackbox\s(/{n;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;d}' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/vc707mig1gb\sblackbox\s(/DDR3AXI4 blackbox (\
	\t.afi_half_clk_clk(blackbox_ui_clk),\
	\t.afi_reset_reset_n(blackbox_ui_clk_sync_rst),\
	\t.axi_translator_s0_awid(blackbox_s_axi_awid),\
	\t.axi_translator_s0_awaddr(blackbox_s_axi_awaddr),\
	\t.axi_translator_s0_awlen(blackbox_s_axi_awlen),\
	\t.axi_translator_s0_awsize(blackbox_s_axi_awsize),\
	\t.axi_translator_s0_awburst(blackbox_s_axi_awburst),\
	\t.axi_translator_s0_awlock(blackbox_s_axi_awlock),\
	\t.axi_translator_s0_awcache(blackbox_s_axi_awcache),\
	\t.axi_translator_s0_awprot(blackbox_s_axi_awprot),\
	\t.axi_translator_s0_awqos(blackbox_s_axi_awqos),\
	\t.axi_translator_s0_awvalid(blackbox_s_axi_awvalid),\
	\t.axi_translator_s0_awready(blackbox_s_axi_awready),\
	\t.axi_translator_s0_wdata(blackbox_s_axi_wdata),\
	\t.axi_translator_s0_wstrb(blackbox_s_axi_wstrb),\
	\t.axi_translator_s0_wlast(blackbox_s_axi_wlast),\
	\t.axi_translator_s0_wvalid(blackbox_s_axi_wvalid),\
	\t.axi_translator_s0_wready(blackbox_s_axi_wready),\
	\t.axi_translator_s0_bid(blackbox_s_axi_bid),\
	\t.axi_translator_s0_bresp(blackbox_s_axi_bresp),\
	\t.axi_translator_s0_bvalid(blackbox_s_axi_bvalid),\
	\t.axi_translator_s0_bready(blackbox_s_axi_bready),\
	\t.axi_translator_s0_arid(blackbox_s_axi_arid),\
	\t.axi_translator_s0_araddr(blackbox_s_axi_araddr),\
	\t.axi_translator_s0_arlen(blackbox_s_axi_arlen),\
	\t.axi_translator_s0_arsize(blackbox_s_axi_arsize),\
	\t.axi_translator_s0_arburst(blackbox_s_axi_arburst),\
	\t.axi_translator_s0_arlock(blackbox_s_axi_arlock),\
	\t.axi_translator_s0_arcache(blackbox_s_axi_arcache),\
	\t.axi_translator_s0_arprot(blackbox_s_axi_arprot),\
	\t.axi_translator_s0_arqos(blackbox_s_axi_arqos),\
	\t.axi_translator_s0_arvalid(blackbox_s_axi_arvalid),\
	\t.axi_translator_s0_arready(blackbox_s_axi_arready),\
	\t.axi_translator_s0_rid(blackbox_s_axi_rid),\
	\t.axi_translator_s0_rdata(blackbox_s_axi_rdata),\
	\t.axi_translator_s0_rresp(blackbox_s_axi_rresp),\
	\t.axi_translator_s0_rlast(blackbox_s_axi_rlast),\
	\t.axi_translator_s0_rvalid(blackbox_s_axi_rvalid),\
	\t.axi_translator_s0_rready(blackbox_s_axi_rready),\
	\t.clk_clk(blackbox_sys_clk_i),\
	\t.mem_mem_a(blackbox_ddr3_addr),\
	\t.mem_mem_ba(blackbox_ddr3_ba),\
	\t.mem_mem_ck(blackbox_ddr3_ck_p),\
	\t.mem_mem_ck_n(blackbox_ddr3_ck_n),\
	\t.mem_mem_cke(blackbox_ddr3_cke),\
	\t.mem_mem_cs_n(blackbox_ddr3_cs_n),\
	\t.mem_mem_dm(blackbox_ddr3_dm),\
	\t.mem_mem_ras_n(blackbox_ddr3_ras_n),\
	\t.mem_mem_cas_n(blackbox_ddr3_cas_n),\
	\t.mem_mem_we_n(blackbox_ddr3_we_n),\
	\t.mem_mem_reset_n(blackbox_ddr3_reset_n),\
	\t.mem_mem_dq(io_port_ddr3_dq),\
	\t.mem_mem_dqs(io_port_ddr3_dqs_p),\
	\t.mem_mem_dqs_n(io_port_ddr3_dqs_n),\
	\t.mem_mem_odt(blackbox_ddr3_odt),\
	\t.oct_rdn(blackbox_oct_rdn),\
	\t.oct_rup(blackbox_oct_rup),\
	\t.pll_sharing_pll_mem_clk(),\
	\t.pll_sharing_pll_write_clk(),\
	\t.pll_sharing_pll_locked(blackbox_mmcm_locked),\
	\t.pll_sharing_pll_write_clk_pre_phy_clk(),\
	\t.pll_sharing_pll_addr_cmd_clk(),\
	\t.pll_sharing_pll_avl_clk(),\
	\t.pll_sharing_pll_config_clk(),\
	\t.reset_reset_n(blackbox_sys_rst)\
	/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# assign oct in Island
	sed -i -e 's/assign\saxi_async_aw_bits_addr\s=\saxi4asink_auto_out_aw_bits_addr;/assign blackbox_oct_rdn = io_port_blackbox_oct_rdn;\n  assign blackbox_oct_rup = io_port_blackbox_oct_rup;\n  assign axi_async_aw_bits_addr = axi4asink_auto_out_aw_bits_addr;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# invert reset output to Sink
	sed -i -e 's/assign\sio_port_ui_clk_sync_rst\s=\sblackbox_ui_clk_sync_rst;/assign io_port_ui_clk_sync_rst = ~blackbox_ui_clk_sync_rst;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# invert reset input to blackbox
	sed -i -e 's/assign\sblackbox_sys_rst\s=\sio_port_sys_rst;/assign blackbox_sys_rst = ~io_port_sys_rst;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# wire oct in Island
	sed -i -e 's/wire\s\sblackbox_sys_rst;/wire  blackbox_sys_rst;\n  wire  blackbox_oct_rdn;\n  wire  blackbox_oct_rup;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# input oct in Island
	sed -i -e 's/module\sXilinxVC707MIGIsland(/module XilinxVC707MIGIsland(\n  input         io_port_blackbox_oct_rdn,\n  input         io_port_blackbox_oct_rup,/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# mapping oct in Mig
	sed -i -e 's/XilinxVC707MIGIsland\sisland\s(/XilinxVC707MIGIsland island (\n\t\t.io_port_blackbox_oct_rdn(island_io_port_blackbox_oct_rdn),\n\t\t.io_port_blackbox_oct_rup(island_io_port_blackbox_oct_rup),/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# assign oct in Mig
	sed -i -e 's/assign\sisland_io_port_sys_rst\s=\sio_port_sys_rst;/assign island_io_port_blackbox_oct_rup = io_port_oct_rup;\n  assign island_io_port_blackbox_oct_rdn = io_port_oct_rdn;\n  assign island_io_port_sys_rst = io_port_sys_rst;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# wire oct in Mig
	sed -i -e 's/wire\s\saxi4asource_auto_out_r_safe_sink_reset_n;/wire  axi4asource_auto_out_r_safe_sink_reset_n;\n  wire island_io_port_blackbox_oct_rdn;\n  wire island_io_port_blackbox_oct_rup;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# input oct in Mig
	sed -i -e 's/module\sXilinxVC707MIG(/module XilinxVC707MIG(\n  input        io_port_oct_rdn,\n  input        io_port_oct_rup,/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# mapping oct in DevKitFPGADesign
	sed -i -e 's/XilinxVC707MIG\smig\s(/XilinxVC707MIG mig (\n\t\t.io_port_oct_rdn(mig_io_port_oct_rdn),\n\t\t.io_port_oct_rup(mig_io_port_oct_rup),/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# assign oct in DevKitFPGADesign
	sed -i -e 's/assign\smig_clock\s=\sclock;/assign mig_io_port_oct_rup = auto_io_port_oct_rup;\n  assign mig_io_port_oct_rdn = auto_io_port_oct_rdn;\n  assign mig_clock = clock;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# wire oct in DevKitFPGADesign
	sed -i -e 's/wire\s\smig_clock;/wire  mig_io_port_oct_rdn;\n  wire  mig_io_port_oct_rup;\n  wire  mig_clock;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# input oct in DevKitFPGADesign
	sed -i -e 's/module\sDevKitFPGADesign(/module DevKitFPGADesign(\n  input         auto_io_port_oct_rdn,\n  input         auto_io_port_oct_rup,/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# mapping oct in DevKitWrapper
	sed -i -e 's/DevKitFPGADesign\stopMod\s(/DevKitFPGADesign topMod (\n\t\t.auto_io_port_oct_rdn(topMod_oct_rdn),\n\t\t.auto_io_port_oct_rup(topMod_oct_rup),/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# assign oct in DevKitWrapper
	sed -i -e 's/assign\stopMod_debug_systemjtag_reset\s=\swrangler_auto_out_0_reset;/assign topMod_debug_systemjtag_reset = wrangler_auto_out_0_reset;\n  assign topMod_oct_rup = auto_topMod_oct_rup;\n  assign topMod_oct_rdn = auto_topMod_oct_rdn;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# wire oct in DevKitWrapper
	sed -i -e 's/wire\s\stopMod_debug_ndreset;/wire  topMod_debug_ndreset;\n  wire  topMod_oct_rup;\n  wire  topMod_oct_rdn;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# input oct in DevKitWrapper
	sed -i -e 's/module\sDevKitWrapper(/module DevKitWrapper(\n  input         auto_topMod_oct_rdn,\n  input         auto_topMod_oct_rup,/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# mapping oct in FPGAShell
	sed -i -e 's/DevKitWrapper\stopDesign (/DevKitWrapper topDesign (\n\t\t.auto_topMod_oct_rdn(topDesign_oct_rdn),\n\t\t.auto_topMod_oct_rup(topDesign_oct_rup),/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# assign oct in FPGAShell
	sed -i -e 's/assign\sfpga_power_on_clock\s=\ssys_clock_ibufds_O;/assign fpga_power_on_clock = sys_clock_ibufds_O;\n  assign topDesign_oct_rdn = mem_oct_rdn;\n  assign topDesign_oct_rup = mem_oct_rup;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# wire oct in FPGAShell
	sed -i -e 's/wire\s\sfpga_power_on_power_on_reset;/wire  fpga_power_on_power_on_reset;\n  wire  topDesign_oct_rdn;\n  wire  topDesign_oct_rup;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# input oct in FPGAShell, also change the shell to TR4Shell
	sed -i -e '/module\sVC707Shell(/{n;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;d}' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/module\sVC707Shell(/module TR4_freedom(\n\tinput 		          		OSC_50_BANK1,\
	\tinput 		          		OSC_50_BANK3,\
	\tinput 		          		OSC_50_BANK4,\
	\tinput 		          		OSC_50_BANK7,\
	\tinput 		          		OSC_50_BANK8,\
	\tinput 		          		LOOP_CLKIN0,\
	\tinput 		          		LOOP_CLKIN1,\
	\toutput		          		LOOP_CLKOUT0,\
	\toutput		          		LOOP_CLKOUT1,\
	\toutput		     [7:0]		LED,\
	\tinput 		     [3:0]		BUTTON,\
	\tinput 		          		mem_EVENT_n,\
	\toutput		          		mem_SCL,\
	\tinout 		          		mem_SDA,\
	\toutput		    [15:0]		mem_a,\
	\toutput		     [2:0]		mem_ba,\
	\toutput		          		mem_cas_n,\
	\toutput		     [1:0]		mem_ck,\
	\toutput		     [1:0]		mem_ck_n,\
	\toutput		     [1:0]		mem_cke,\
	\toutput		     [1:0]		mem_cs_n,\
	\toutput		     [7:0]		mem_dm,\
	\tinout 		    [63:0]		mem_dq,\
	\tinout 		     [7:0]		mem_dqs,\
	\tinout 		     [7:0]		mem_dqs_n,\
	\toutput		     [1:0]		mem_odt,\
	\toutput		          		mem_ras_n,\
	\toutput		          		mem_reset_n,\
	\toutput		          		mem_we_n,\
	\tinput 		          		mem_oct_rdn,\
	\tinput 		          		mem_oct_rup,\
	\tinout 		    [35:0]		GPIO,\
	\tinput 		          		HSM_CLKIN0,\
	\tinput 		          		HSM_CLKIN_n1,\
	\tinput 		          		HSM_CLKIN_n2,\
	\tinput 		          		HSM_CLKIN_p1,\
	\tinput 		          		HSM_CLKIN_p2,\
	\toutput		          		HSM_CLKOUT_n1,\
	\toutput		          		HSM_CLKOUT_n2,\
	\toutput		          		HSM_CLKOUT_p1,\
	\toutput		          		HSM_CLKOUT_p2,\
	\tinout 		     [3:0]		HSM_D,\
	\tinout 		          		HSM_OUT0,\
	\tinout 		    [16:0]		HSM_RX_n,\
	\tinout 		    [16:0]		HSM_RX_p,\
	\tinout 		    [16:0]		HSM_TX_n,\
	\tinout 		    [16:0]		HSM_TX_p,\
	\toutput		          		HSMC_DEF_SCL,\
	\tinout 		          		HSMC_DEF_SDA,\
	\tinput 		          		jtag_jtag_TCK,\
	\tinput 		          		jtag_jtag_TMS,\
	\tinput 		          		jtag_jtag_TDI,\
	\toutput 		          		jtag_jtag_TDO,\
	\toutput 		          		uart_txd,\
	\tinput 		          		uart_rxd,\
	\toutput 		          		uart_rtsn,\
	\tinput 		          		uart_ctsn\
	/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# replace DDR3 ports
	sed -i -e 's/.auto_topMod_io_out_port_ddr3_dq(ddr_ddr3_dq),/.auto_topMod_io_out_port_ddr3_dq(mem_dq),/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/.auto_topMod_io_out_port_ddr3_dqs_n(ddr_ddr3_dqs_n),/.auto_topMod_io_out_port_ddr3_dqs_n(mem_dqs_n),/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/.auto_topMod_io_out_port_ddr3_dqs_p(ddr_ddr3_dqs_p),/.auto_topMod_io_out_port_ddr3_dqs_p(mem_dqs),/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/assign\sddr_ddr3_addr\s=\stopDesign_auto_topMod_io_out_port_ddr3_addr;/assign mem_a = topDesign_auto_topMod_io_out_port_ddr3_addr;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/assign\sddr_ddr3_ba\s=\stopDesign_auto_topMod_io_out_port_ddr3_ba;/assign mem_ba = topDesign_auto_topMod_io_out_port_ddr3_ba;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/assign\sddr_ddr3_ras_n\s=\stopDesign_auto_topMod_io_out_port_ddr3_ras_n;/assign mem_ras_n = topDesign_auto_topMod_io_out_port_ddr3_ras_n;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/assign\sddr_ddr3_cas_n\s=\stopDesign_auto_topMod_io_out_port_ddr3_cas_n;/assign mem_cas_n = topDesign_auto_topMod_io_out_port_ddr3_cas_n;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/assign\sddr_ddr3_we_n\s=\stopDesign_auto_topMod_io_out_port_ddr3_we_n;/assign mem_we_n = topDesign_auto_topMod_io_out_port_ddr3_we_n;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/assign\sddr_ddr3_reset_n\s=\stopDesign_auto_topMod_io_out_port_ddr3_reset_n;/assign mem_reset_n = topDesign_auto_topMod_io_out_port_ddr3_reset_n;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/assign\sddr_ddr3_ck_p\s=\stopDesign_auto_topMod_io_out_port_ddr3_ck_p;/assign mem_ck = topDesign_auto_topMod_io_out_port_ddr3_ck_p;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/assign\sddr_ddr3_ck_n\s=\stopDesign_auto_topMod_io_out_port_ddr3_ck_n;/assign mem_ck_n = topDesign_auto_topMod_io_out_port_ddr3_ck_n;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/assign\sddr_ddr3_cke\s=\stopDesign_auto_topMod_io_out_port_ddr3_cke;/assign mem_cke = topDesign_auto_topMod_io_out_port_ddr3_cke;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/assign\sddr_ddr3_cs_n\s=\stopDesign_auto_topMod_io_out_port_ddr3_cs_n;/assign mem_cs_n = topDesign_auto_topMod_io_out_port_ddr3_cs_n;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/assign\sddr_ddr3_dm\s=\stopDesign_auto_topMod_io_out_port_ddr3_dm;/assign mem_dm = topDesign_auto_topMod_io_out_port_ddr3_dm;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/assign\sddr_ddr3_odt\s=\stopDesign_auto_topMod_io_out_port_ddr3_odt;/assign mem_odt = topDesign_auto_topMod_io_out_port_ddr3_odt;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# replace SDIO ports
	sed -i -e 's/assign\ssdio_sdio_clk\s=\stopDesign_auto_topMod_spi_source_out_sck;/assign HSM_CLKOUT_p1 = topDesign_auto_topMod_spi_source_out_sck;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/assign\ssdio_sdio_cmd\s=\stopDesign_auto_topMod_spi_source_out_dq_0_o;/assign HSM_RX_p[15] = topDesign_auto_topMod_spi_source_out_dq_0_o;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/assign\ssdio_sdio_dat_3\s=\stopDesign_auto_topMod_spi_source_out_cs_0;/assign HSM_RX_p[9] = topDesign_auto_topMod_spi_source_out_cs_0;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/assign\stopDesign_auto_topMod_spi_source_out_dq_1_i\s=\ssdio_sdio_dat_0;/assign topDesign_auto_topMod_spi_source_out_dq_1_i = HSM_RX_n[14];/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v	
	# replace LED ports
	sed -i -e 's/assign\sled\s=\stopDesign_auto_topMod_led_source_out;/assign LED = topDesign_auto_topMod_led_source_out;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# replace input clock from XTAL
	sed -i -e 's/assign\ssys_clock_ibufds_IB\s=\ssys_clock_n;/assign sys_clock_ibufds_O = OSC_50_BANK1;/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e '/assign\ssys_clock_ibufds_I\s=\ssys_clock_p;/d' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# replace RESET button
	sed -i -e 's/assign\sreset_ibuf_I\s=\sreset;/assign reset_ibuf_I = ~BUTTON[0];/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# replace corePLL
	sed -i -e 's/corePLL\scorePLL/altpll_corePLL corePLL/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/.reset(corePLL_reset),/.areset(corePLL_reset),/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/.clk_out1(corePLL_clk_out1),/.c0(corePLL_clk_out1),/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/.clk_in1(corePLL_clk_in1)/.inclk0(corePLL_clk_in1)/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# delete IBUFDS
	sed -i -e '/sys_clock_ibufds\s(/d' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e '/.IB(sys_clock_ibufds_IB),/d' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e '/.I(sys_clock_ibufds_I),/d' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e '/.O(sys_clock_ibufds_O)/{n;d}' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e '/.O(sys_clock_ibufds_O)/d' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	# replace IBUF
	sed -i -e 's/IBUF\sreset_ibuf\s(/altiobuf_ibuf reset_ibuf (/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/.I(reset_ibuf_I),/.datain(reset_ibuf_I),/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	sed -i -e 's/.O(reset_ibuf_O)/.dataout(reset_ibuf_O)/g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	#sed -i -e 's///g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	#sed -i -e 's///g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	#sed -i -e 's///g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	#sed -i -e 's///g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	#sed -i -e 's///g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	#sed -i -e 's///g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	#sed -i -e 's///g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	#sed -i -e 's///g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	#sed -i -e 's///g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	#sed -i -e 's///g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	#sed -i -e 's///g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	#sed -i -e 's///g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	#sed -i -e 's///g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v
	#sed -i -e 's///g' $(base_dir)/builds/altera_TR4_board/TR4_freedom.v




.PHONY: altera_TR4
altera_TR4: $(altera_TR4)

###################################################################

# Clean
.PHONY: clean
clean:
ifneq ($(BOOTROM_DIR),"")
	$(MAKE) -C $(BOOTROM_DIR) clean
endif
	$(MAKE) -C $(FPGA_DIR) clean
	rm -rf $(BUILD_DIR)
