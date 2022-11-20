cd src
iverilog -g2012 -DTESTING_RAY_UNIT ../src/sdf_query.sv ../src/fp_inv_sqrt_folded.sv ../src/ray_generator_folded.sv ../src/ray_unit.sv ../sim/ray_unit_tb.sv
vvp a.out > ../ray-unit.txt
echo "See ray-unit.txt"
cd ..