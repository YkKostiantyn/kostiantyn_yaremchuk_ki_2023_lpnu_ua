@echo off
rem Симуляція SPI Master у режимах 0-3 (Icarus Verilog), Windows
setlocal
cd /d "%~dp0\.."
if not exist build mkdir build
set STATUS=0
for %%m in (0 1 2 3) do (
  iverilog -g2005 -Wall -P tb_spi_master.MODE=%%m -o build\tb_mode%%m rtl\spi_tx.v rtl\spi_rx.v rtl\spi_master.v tb\spi_slave_model.v tb\tb_spi_master.v || set STATUS=1
  pushd build
  vvp -n tb_mode%%m > sim_mode%%m.log
  type sim_mode%%m.log
  findstr /c:"ALL TESTS PASSED" sim_mode%%m.log >nul || set STATUS=1
  popd
)
if "%STATUS%"=="0" (echo SIMULATION: ALL MODES PASSED) else (echo SIMULATION: FAILED)
exit /b %STATUS%
