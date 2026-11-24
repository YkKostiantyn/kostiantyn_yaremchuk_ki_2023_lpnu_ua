@echo off
rem Синтез Yosys + nextpnr (iCE40 HX8K, CT256), звіт ресурсів і Fmax, Windows
setlocal
cd /d "%~dp0\.."
if not exist build mkdir build
yosys -q -l build\yosys.log -p "read_verilog rtl/spi_tx.v rtl/spi_rx.v rtl/spi_master.v; synth_ice40 -top spi_master -json build/spi_master.json; tee -o build/yosys_stat.txt stat" || exit /b 1
nextpnr-ice40 --hx8k --package ct256 --json build\spi_master.json --pcf-allow-unconstrained --freq 50 -l build\nextpnr.log || exit /b 1
echo ===== Yosys: resources =====
type build\yosys_stat.txt
echo ===== nextpnr: resources and Fmax =====
findstr /c:"ICESTORM_LC" /c:"SB_IO" /c:"SB_GB" /c:"Max frequency" build\nextpnr.log
