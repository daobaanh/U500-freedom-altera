set_global_assignment -entity "altpll_corePLL" -library "lib_altpll_corePLL" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "altpll_corePLL" -library "lib_altpll_corePLL" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "altpll_corePLL" -library "lib_altpll_corePLL" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_altpll_corePLL" -name SPD_FILE [file join $::quartus(sip_path) "altpll_corePLL.spd"]

set_global_assignment -library "lib_altpll_corePLL" -name MISC_FILE [file join $::quartus(sip_path) "altpll_corePLL_sim/altpll_corePLL.vo"]
