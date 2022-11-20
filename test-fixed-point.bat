cd src
iverilog -g2012 ../sim/fixed_point_arith_tb.sv
vvp a.out 
cd ..