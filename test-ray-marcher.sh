cd src
iverilog -g2012 -DTESTING_RAY_MARCHER ../src/ray_marcher.sv ../sim/ray_marcher_tb.sv && ./a.out | tee ../ray-marcher.txt
rm -f a.out *.vcd