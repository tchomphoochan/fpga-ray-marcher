cd src
iverilog -g2012 -DTESTING_RAY_MARCHER ../src/ray_unit_dummy.sv ../src/ray_marcher.sv ../sim/ray_marcher_tb.sv && ./a.out > ../ray-marcher.txt
cp ray_marcher.vcd ..
rm -f a.out ray_marcher.vcd
echo "See ray-marcher.txt"