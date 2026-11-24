// =============================================================================
// spi_slave_model.v — поведінкова модель веденого SPI (тільки для симуляції).
// Імітує зовнішній пристрій: приймає байт з MOSI і передає tx_byte у MISO
// у тому ж режимі CPOL/CPHA, що й master. Використовується для перевірки Rx.
// =============================================================================
`timescale 1ns / 1ps

module spi_slave_model #(
    parameter integer CPOL = 0,
    parameter integer CPHA = 0
) (
    input  wire       sck,
    input  wire       cs_n,
    input  wire       mosi,
    output reg        miso,
    input  wire [7:0] tx_byte,   // байт, який ведений передає ведучому
    output reg  [7:0] rx_byte,   // байт, прийнятий від ведучого
    output reg        rx_valid   // 1 — прийнято 8 біт
);

    reg [7:0] tx_sh, rx_sh;
    integer   bit_cnt;

    initial begin
        miso     = 1'bz;
        rx_byte  = 8'h00;
        rx_valid = 1'b0;
        bit_cnt  = 0;
    end

    // Початок транзакції: при CPHA=0 старший біт виставляється одразу по CS
    always @(negedge cs_n) begin
        tx_sh    = tx_byte;
        rx_sh    = 8'h00;
        bit_cnt  = 0;
        rx_valid = 1'b0;
        if (CPHA == 0) begin
            miso  = tx_sh[7];
            tx_sh = {tx_sh[6:0], 1'b0};
        end
    end

    // Кінець транзакції: MISO у високоімпедансний стан
    always @(posedge cs_n) miso = 1'bz;

    task do_sample;
        begin
            rx_sh   = {rx_sh[6:0], mosi};
            bit_cnt = bit_cnt + 1;
            if (bit_cnt == 8) begin
                rx_byte  = rx_sh;
                rx_valid = 1'b1;
            end
        end
    endtask

    task do_shift;
        begin
            miso  = tx_sh[7];
            tx_sh = {tx_sh[6:0], 1'b0};
        end
    endtask

    // Фронт вибірки — наростаючий, якщо CPOL == CPHA; інакше спадаючий
    always @(posedge sck) if (cs_n === 1'b0) begin
        if (CPOL == CPHA) do_sample; else do_shift;
    end

    always @(negedge sck) if (cs_n === 1'b0) begin
        if (CPOL != CPHA) do_sample; else do_shift;
    end

endmodule
