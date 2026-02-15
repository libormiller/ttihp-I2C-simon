/*
 * Copyright (c) 2024 Libor Miller
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_libormiller_SIMON_I2C (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // I2C pin mapping:
  //   uio[0] = SDA (bidirectional, active-low open-drain)
  //   uio[1] = SCL (bidirectional, active-low open-drain)

  wire sda_i, sda_o, sda_t;
  wire scl_i, scl_o, scl_t;

  // I2C input: read from uio_in
  assign sda_i = uio_in[0];
  assign scl_i = uio_in[1];

  // I2C output: active-low open-drain emulation
  //   When slave wants to drive low: sda_t=0, sda_o=0 -> uio_out=0, uio_oe=1 (output, driven low)
  //   When slave releases (high-Z):  sda_t=1           -> uio_oe=0 (input, pulled up externally)
  assign uio_out[0] = sda_o;
  assign uio_oe[0]  = ~sda_t;  // sda_t=0 means drive -> oe=1; sda_t=1 means tristate -> oe=0

  assign uio_out[1] = scl_o;
  assign uio_oe[1]  = ~scl_t;  // same logic for SCL

  // Unused uio pins [7:2] as inputs
  assign uio_out[7:2] = 6'b0;
  assign uio_oe[7:2]  = 6'b0;

  // Unused dedicated outputs
  assign uo_out = 8'b0;

  // SIMON top instance
  simon_top simon_inst (
      .clk   (clk),
      .rst   (~rst_n),    // TT uses active-low reset, simon_top uses active-high
      .sda_i (sda_i),
      .sda_o (sda_o),
      .sda_t (sda_t),
      .scl_i (scl_i),
      .scl_o (scl_o),
      .scl_t (scl_t)
  );

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in, uio_in[7:2], 1'b0};

endmodule
