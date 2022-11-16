cd src
iverilog -g2012 ../src/fixed_point_arith.sv ../sim/fixed_point_arith_tb.sv
vvp a.out 
cd ..