cd src
iverilog -g2012 ../src/fixed_point_arith.sv ../sim/fixed_point_arith_tb.sv && ./a.out | tee ../fixed-point.txt
rm -f a.out *.vcd