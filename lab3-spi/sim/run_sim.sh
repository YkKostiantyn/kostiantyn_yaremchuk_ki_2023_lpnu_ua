#!/usr/bin/env bash
# Симуляція SPI Master у всіх чотирьох режимах (Icarus Verilog).
# Результат: build/spi_mode<N>.vcd і build/sim_mode<N>.log
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
status=0
for m in 0 1 2 3; do
    iverilog -g2005 -Wall -P tb_spi_master.MODE=$m -o build/tb_mode$m \
        rtl/spi_tx.v rtl/spi_rx.v rtl/spi_master.v tb/spi_slave_model.v tb/tb_spi_master.v
    (cd build && vvp -n tb_mode$m | tee sim_mode$m.log)
    grep -q "ALL TESTS PASSED" build/sim_mode$m.log || status=1
done
[ $status -eq 0 ] && echo "SIMULATION: ALL MODES PASSED" || echo "SIMULATION: FAILED"
exit $status
