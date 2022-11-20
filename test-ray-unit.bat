cd src
iverilog -g2012 -DTESTING_RAY_UNIT ../src/ray_unit.sv ../sim/ray_unit_tb.sv
vvp a.out > ../ray-unit.txt
echo "See ray-unit.txt"
cd ..