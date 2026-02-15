<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Hardware implementation of the Simon block cipher (32/64 configuration) integrated with an I2C Slave interface. The design allows a Master device to write a 64-bit key and 32-bit data block, configure the operation mode (Encrypt/Decrypt), and read back the result.

## Register Map

All registers are 8-bit wide. Multi-byte registers are stored **Little-Endian** (LSB at lower address).

| Address (Hex) | Name | Access | Description |
| :--- | :--- | :--- | :--- |
| **0x00 - 0x07** | `KEY` | R/W | 64-bit Key (LSB first: `0x00` is Key[7:0]). |
| **0x08 - 0x0B** | `DATA_IN` | R/W | 32-bit Input Block (Plaintext or Ciphertext). LSB first. |
| **0x0C** | `CONTROL` | R/W | **Bit [0]: CORE_RST** (1 = Reset/Load, 0 = Run)<br>**Bit [1]: CORE_MODE** (0 = Encrypt, 1 = Decrypt) |
| **0x10 - 0x13** | `RESULT` | R | 32-bit Output Block (Ciphertext or Plaintext). Valid only when `DONE` is 1. |
| **0x14** | `STATUS` | R | **Bit [1]: DONE** (1 = Valid Result Ready)<br>**Bit [0]: BUSY** (1 = Calculating) |


## How to test

Automatic simulation testing using cocotb with simulated I2C master. In real implementation, only I2C master is needed.

## External hardware

Anything that can act as I2C master