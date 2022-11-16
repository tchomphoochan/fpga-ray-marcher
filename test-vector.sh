cd src
iverilog -g2012 ../src/fixed_point_arith.sv ../src/vector_arith.sv ../sim/vector_arith_tb.sv && vvp a.out | tee ../vector.txt
rm -f a.out *.vcd