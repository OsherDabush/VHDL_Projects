This project demonstrates a VHDL-based system that converts a 4-bit binary input from the Basys3 FPGA switches into a hexadecimal value, displayed on a seven-segment display. 
Features:
Binary to Hex Conversion: Converts 4-bit binary input (SW0-SW3) to hexadecimal for display.
Seven-Segment Display: Shows numbers 0-9 and letters A-F.
The user select which of the seven segments (1-4) will display the value from the switches.
Dynamic Anode Control: Manages the seven-segment display anode activation.
Components:
SEG_Decoder: Decodes 4-bit input to seven-segment format.
Anode_Encoder: Controls which seven-segment display to activate.
Main: Top-level module connecting the components.
Hardware Setup:
FPGA Board: Basys3 (Xilinx Artix-7)
Inputs: SW0-SW3 for binary input
Outputs: Seven-segment display shows corresponding hexadecimal value.
Usage:
Set switches (SW0-SW3) for binary input.
View the hexadecimal equivalent on the seven-segment display.
Files:
SEG_Decoder.vhd
Anode_Encoder.vhd
Main.vhd
.xdc file for pin mappings
