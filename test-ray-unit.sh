cd src
iverilog -g2012 -DTESTING_RAY_UNIT  ../src/sdf_query.sv ../src/fp_inv_sqrt_folded.sv ../src/ray_generator_folded.sv ../src/ray_unit.sv ../sim/ray_unit_tb.sv && vvp a.out > ../ray-unit.txt
cp ray_unit.vcd ..
rm -f a.out ray_unit.vcd
echo "See ray-unit.txt"