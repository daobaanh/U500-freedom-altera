This repository consist of:
  1. Quartus Prime cleaned tempalte projects for u500-freedom on TR4 and SoCKit Boards.
  2. Modified common.mk, it can automatically modify the u500-freedom-vc707 generated verilog code to be compatible with previous Quartus Prime tempalte projects.    
  3. Guide Document that has detailed explaination for porting manually.

Quick instruction:
  1. Follow [this repo](https://github.com/thuchoang90/tutorial/tree/VC707) and generate the u500-freedom-vc707 verilog and mcs files.
  2. Clone this repository.
  3. Replace the common.mk in the "freedom" directory with new one from this repository.
  4. Run "make" with the "altera_TR4" target. It will copy and make some needed modification to the generated files from step 1 and put them in "freedom/builds/altera_TR4_board" folder.
  5. Copy and add files in "freedom/builds/altera_TR4_board" folder to Quartus Prime Project.
  6. Do Full Compile Design in Quartus Prime project, then program the board and test as usual (as in u500-freedom vc707 prj).
  
  
