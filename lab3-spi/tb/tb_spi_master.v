// =============================================================================
// tb_spi_master.v — тестбенч SPI Master.
//  * генерує CLK (50 МГц) і RESET;
//  * подає тестові слова на вхід передавача (tx_data);
//  * модель веденого spi_slave_model імітує передачу даних від іншого пристрою
//    (перевірка приймача) і приймає дані MOSI (перевірка передавача);
//  * автоматично порівнює результати й виводить PASS/FAIL.
// Режим SPI задається параметром MODE (0..3): CPOL = MODE[1], CPHA = MODE[0].
// Запуск: iverilog -P tb_spi_master.MODE=<n> ...
// =============================================================================
`timescale 1ns / 1ps

module tb_spi_master;

    parameter integer MODE = 0;
    localparam integer CPOL    = (MODE >> 1) & 1;
    localparam integer CPHA    = MODE & 1;
    localparam integer CLK_DIV = 4;       // SCK = 50 МГц / 8 = 6.25 МГц

    reg        clk   = 1'b0;
    reg        rst_n = 1'b0;
    reg        start = 1'b0;
    reg  [7:0] tx_data  = 8'h00;
    reg  [7:0] slave_tx = 8'h00;

    wire [7:0] rx_data, slave_rx;
    wire       busy, done, sck, mosi, miso, cs_n, slave_valid;

    integer errors = 0;
    integer tests  = 0;
    reg [8*20:1] vcd_name;

    always #10 clk = ~clk;  // період 20 нс — 50 МГц

    spi_master #(
        .DATA_W(8), .CLK_DIV(CLK_DIV), .CPOL(CPOL), .CPHA(CPHA)
    ) dut (
        .clk(clk), .rst_n(rst_n), .start(start), .tx_data(tx_data),
        .rx_data(rx_data), .busy(busy), .done(done),
        .sck(sck), .mosi(mosi), .miso(miso), .cs_n(cs_n)
    );

    spi_slave_model #(.CPOL(CPOL), .CPHA(CPHA)) slave (
        .sck(sck), .cs_n(cs_n), .mosi(mosi), .miso(miso),
        .tx_byte(slave_tx), .rx_byte(slave_rx), .rx_valid(slave_valid)
    );

    // Одна повнодуплексна транзакція: master -> m_byte, slave -> s_byte
    task transfer(input [7:0] m_byte, input [7:0] s_byte);
        begin
            slave_tx = s_byte;
            @(posedge clk);
            tx_data <= m_byte;
            start   <= 1'b1;
            @(posedge clk);
            start   <= 1'b0;
            @(posedge done);
            #1;
            tests = tests + 1;
            if (rx_data !== s_byte || slave_rx !== m_byte || slave_valid !== 1'b1) begin
                errors = errors + 1;
                $display("[MODE %0d] FAIL: master sent %h, slave got %h | slave sent %h, master got %h",
                         MODE, m_byte, slave_rx, s_byte, rx_data);
            end else begin
                $display("[MODE %0d] PASS: master->slave %h, slave->master %h", MODE, m_byte, rx_data);
            end
            repeat (2) @(posedge clk);
            if (cs_n !== 1'b1 || sck !== CPOL[0] || busy !== 1'b0) begin
                errors = errors + 1;
                $display("[MODE %0d] FAIL: idle state (cs_n=%b sck=%b busy=%b)", MODE, cs_n, sck, busy);
            end
            repeat (4) @(posedge clk);
        end
    endtask

    initial begin
        $sformat(vcd_name, "spi_mode%0d.vcd", MODE);
        $dumpfile(vcd_name);
        $dumpvars(0, tb_spi_master);

        $display("=== SPI master testbench: MODE %0d (CPOL=%0d, CPHA=%0d) ===", MODE, CPOL, CPHA);
        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        repeat (3) @(posedge clk);

        transfer(8'hA5, 8'h3C);
        transfer(8'hFF, 8'h00);
        transfer(8'h00, 8'hFF);
        transfer(8'h5A, 8'hC3);
        transfer(8'h81, 8'h7E);

        if (errors == 0)
            $display("[MODE %0d] ALL TESTS PASSED (%0d transfers)", MODE, tests);
        else
            $display("[MODE %0d] TEST FAILED: %0d errors", MODE, errors);
        $finish;
    end

    // Сторожовий таймер: захист від зависання FSM
    initial begin
        #200000;
        $display("[MODE %0d] TEST FAILED: timeout", MODE);
        $finish;
    end

endmodule
