#!/usr/bin/env bash
# Синтез (Yosys) і розміщення/трасування з часовим аналізом (nextpnr)
# для ПЛІС Lattice iCE40 HX8K (корпус CT256).
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
yosys -q -l build/yosys.log -p "read_verilog rtl/spi_tx.v rtl/spi_rx.v rtl/spi_master.v; \
    synth_ice40 -top spi_master -json build/spi_master.json; tee -o build/yosys_stat.txt stat"
nextpnr-ice40 --hx8k --package ct256 --json build/spi_master.json \
    --pcf-allow-unconstrained --freq 50 -l build/nextpnr.log
echo "===== Yosys: ресурси ====="
cat build/yosys_stat.txt
echo "===== nextpnr: ресурси і Fmax ====="
grep -E "ICESTORM_LC|SB_IO|SB_GB|Max frequency" build/nextpnr.log
