cd src
iverilog -g2012 ../sim/fixed_point_arith_tb.sv && vvp a.out | tee ../fixed-point.txt
rm -f a.out *.vcd