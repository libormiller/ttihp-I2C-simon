`default_nettype none
`timescale 1ns / 1ps

/* This testbench instantiates the TT module and provides
   open-drain I2C simulation wires for cocotb test.py.
*/

module tb ();

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // ---- Open-drain I2C simulation ----
  // Master enable signals driven by cocotb (active-low: 0 = master pulls low)
  reg sda_master_en;
  reg scl_master_en;
  initial begin
    sda_master_en = 1;
    scl_master_en = 1;
  end

  // Open-drain bus wires (active-low, active-high = pulled up)
  wire sda_pin;
  wire scl_pin;

  // I2C open-drain: bus is low if master OR slave pulls low, otherwise pulled high
  // Slave drives low when: uio_oe[0]=1 and uio_out[0]=0
  wire sda_slave_drives_low = uio_oe[0] && !uio_out[0];
  wire scl_slave_drives_low = uio_oe[1] && !uio_out[1];

  assign sda_pin = (!sda_master_en || sda_slave_drives_low) ? 1'b0 : 1'b1;
  assign scl_pin = (!scl_master_en || scl_slave_drives_low) ? 1'b0 : 1'b1;

  // Feed bus state back into uio_in for the slave to read
  always @(*) begin
    uio_in[0] = sda_pin;
    uio_in[1] = scl_pin;
    uio_in[7:2] = 6'b0;
  end

  // Active-high reset for cocotb convenience
  wire rst = ~rst_n;

  tt_um_libormiller_SIMON_I2C user_project (
      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );

endmodule
