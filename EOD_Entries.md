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