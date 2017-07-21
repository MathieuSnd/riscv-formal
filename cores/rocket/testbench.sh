#!/bin/bash

set -ex

use_iverilog=false
tracetb=insncheck/insn_sw_ch0/engine_0/trace_tb.v

egrep -v 'UUT.(core.rvfi_|core.io_status_dprv|core.csr.io_time|core.csr.io_status_dprv|frontend.icache.io_resp_bits)' $tracetb > testbench.v

if $use_iverilog; then
	iverilog -o testbench -s testbench testbench.v \
			rocket-chip/vsim/generated-src/freechips.rocketchip.chip.DefaultConfigWithRVFIMonitors.v \
			rocket-chip/vsim/generated-src/freechips.rocketchip.chip.DefaultConfigWithRVFIMonitors.behav_srams.v \
			rocket-chip/vsrc/plusarg_reader.v rocket-chip/vsrc/RVFIMonitor.v
	./testbench +vcd=testbench.vcd
else
	verilator --exe  --cc -Wno-fatal --top-module testbench --trace testbench.v testbench.cc \
			rocket-chip/vsim/generated-src/freechips.rocketchip.chip.DefaultConfigWithRVFIMonitors.v \
			rocket-chip/vsim/generated-src/freechips.rocketchip.chip.DefaultConfigWithRVFIMonitors.behav_srams.v \
			rocket-chip/vsrc/plusarg_reader.v rocket-chip/vsrc/RVFIMonitor.v
	make -C obj_dir -f Vtestbench.mk
	./obj_dir/Vtestbench
fi
