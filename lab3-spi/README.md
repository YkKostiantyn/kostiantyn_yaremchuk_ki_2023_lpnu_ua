# Лабораторна робота №3 — SPI Master (Verilog)

Яремчук К. В., КІ-404, варіант 30: протокол **SPI**, мова **Verilog**.

| Каталог | Вміст |
|---|---|
| `rtl/spi_master.v` | верхній рівень: дільник SCK, FSM, CS, екземпляри Tx/Rx |
| `rtl/spi_tx.v` | передавач (зсувний регістр MOSI) |
| `rtl/spi_rx.v` | приймач (зсувний регістр MISO) |
| `tb/tb_spi_master.v` | тестбенч із самоперевіркою |
| `tb/spi_slave_model.v` | поведінкова модель веденого SPI |
| `sim/run_sim.sh` | симуляція в режимах 0–3 (Icarus Verilog) |
| `sim/run_synth.sh` | синтез Yosys + nextpnr для iCE40 HX8K, звіт ресурсів і Fmax |

Запуск:
```bash
./sim/run_sim.sh
gtkwave build/spi_mode0.vcd sim/spi.gtkw
./sim/run_synth.sh
```
