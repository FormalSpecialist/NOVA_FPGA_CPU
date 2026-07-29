# End of Day Entries

## Description
The main purpose of this file is to provide a form of documentation for any updates, notes, changes, and goals for myself as the project continues. This level of documentation focuses more as a readable format as compared to any GitHub updates.



*** June 23rd, 2026 ***
Changes:
- Created the base project file
    - Added the blank XDC constraints file for the Nexys A7 FPGA.
    - Connected VSCode to Vivado.

- Created the GitHub repositoy and pushed the files. 

Issues:
- Vivado was strugling to locate VSCode via the path.
    - This was bipassed by setting a direct path and setting the text editor to custom rather than VSCode

- Generally feeling unsure of how to begin this project
    - Research into the different sections and start at the most simplistic level

Goals:
- Refresh understanding of programming in Vivado
- Understand the architecture of CPU's to break down each problem into sub-problems
    - Which core component is the starting point?



*** June 24th, 2026 ***

Created the basic structure to allow the hardware to make a decision based on the operational code. This decision determines which of the four main operations will be performed (Add, Sub, AND, and OR).

Changes:
- Created the alu.v file which will be the top level file for the ALU in the CPU.
- Within the alu.v file, started creating the structure which will determine which opCode is used

Issues:
- Remembering how to properly program in Verilog 

Goals:
- Finish Programming the case statement
- Program checks for flags
- Begin developing base files for each operational code.



*** July 9th, 2026 ***

Moved structure for Flags to a separate file (arithmeticFlags.v), in the hopes of separating out logical components. However, the extentions used within VSCode are directly having a issue with these types of file references. 

Changes:
- Create arithmeticFlags.v to hold all code for flags. 
- Fleshed out the code needed for basic flags (overflow and underflow)
- Moved code referencing flags from alu.v to arithmeticFlags.v

Issues:
- Need to resolve syntax issues related to referencing other files.
    - Perhaps try deleting all extensions and re-installing

Goals:
- Finish Programming the case statement
- Resolve issues in Extentions



*** July 10th, 2026 ***

Removed Extentions and transitioned to TerosHDL 

Changes:
- Removed Extentions
- Began experimenting with TerosHDL
- Finished the Case Statement to do basic functionality, need to fact check whether it works

Issues:
- Need to read through the guide... if I'm unable to get it to work, then I will simply just use Vivado to program... not ideal but may be necessary.

Goals:
- Either figure out how to use TerosHDL or transition to Vivado.
- Build a testbench



*** July 13th, 2026 ***

Decided on using base Vivado for error control and programming. 

Changes:
- Transitioned out of VSCode, except for these specific entries and all READMEs
- Created the alu_tb.v file 
- Added and subsequently fixed code within ALU focused on reset. 

Issues:
- Likely need to add a clock to properly allow for the testbench to properly work. 

Goals:
- Add a clock into ALU and then run testbench.



*** July 24th, 2026 ***

Fixed the ALU testbench and base code

Changes:
- Changed the Testbench code to accurately reflect the proper file
- Fixed the reset button in ALU file

Issues:
- Likely need to add a clock to properly allow for the testbench to properly work. However, after testing Testbench, doesn't seem to have any issues.

Goals:
- Expand the differnet calculations to be performed by the ALU
- Begin on Memory and storage. 



*** July 28th, 2026 ***

Researched Next Steps on Memory Access

Changes:
- Updated Comment Descriptions of Files
- Fixed initialization in alu.v
- Researched how to begin development on Memory Unit for CPU
    - Breaks into multiple sections: Program Counter, Register File (16 Registers), Data RAM (Random Access Memory)
    - RAM consists of 256, 8 bit values for memory, registers are easier to access values for intermediate transportation of data (reading and writing)
    - Need to update opCodes to 4 bits to accomodate READ and WRITE (LOAD and STORE) commands 
    - State machine for clock cycle functions, and MUX for determining wether to store a value from Memory or ALU

Issues:
- No current issues.

Goals:
- Expand OpCodes
- Begin Structuring Memory