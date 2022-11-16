cd src
iverilog -g2012 -DTESTING_RAY_MARCHER ../src/ray_unit_dummy.sv ../src/ray_marcher.sv ../sim/ray_marcher_tb.sv
vvp a.out > ../ray-marcher.txt
echo "See ray-marcher.txt"
cd ..