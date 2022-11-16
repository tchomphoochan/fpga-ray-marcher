cd src
iverilog -g2012 ../src/fixed_point_arith.sv ../src/vector_arith.sv ../src/sdf_primitives.sv ../sim/sdf_primitives_tb.sv && ./a.out | tee ../primitives.txt
rm -f a.out *.vcd