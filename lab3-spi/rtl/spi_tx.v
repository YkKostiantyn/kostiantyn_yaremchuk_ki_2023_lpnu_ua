// =============================================================================
// spi_tx.v — передавач SPI (Tx): паралельно-послідовний зсувний регістр.
// По load завантажує слово; по shift зсуває вліво. MOSI = старший біт регістра,
// тому передача відбувається старшим бітом уперед (MSB first).
// =============================================================================
`timescale 1ns / 1ps
`default_nettype none

module spi_tx #(
    parameter integer DATA_W = 8
) (
    input  wire              clk,    // системний тактовий сигнал
    input  wire              rst_n,  // асинхронне скидання, активний 0
    input  wire              load,   // завантаження нового слова
    input  wire              shift,  // зсув на один біт (строб від FSM)
    input  wire [DATA_W-1:0] data,   // слово для передачі
    output wire              mosi    // послідовний вихід
);

    reg [DATA_W-1:0] shreg;  // зсувний регістр передавача

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            shreg <= {DATA_W{1'b0}};
        else if (load)
            shreg <= data;
        else if (shift)
            shreg <= {shreg[DATA_W-2:0], 1'b0};
    end

    assign mosi = shreg[DATA_W-1];

endmodule

`default_nettype wire
