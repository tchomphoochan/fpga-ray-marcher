cd src
iverilog -g2012 ../src/sdf_query.sv ../src/ray_unit.sv ../src/fp_inv_sqrt_folded.sv ../src/ray_generator.sv ../src/ray_generator_folded.sv ../src/ray_marcher.sv ../sim/full_ray_marcher_sim.sv
vvp a.out > ../full-ray-marcher-sim.txt
vvp a.out > ../full-ray-marcher-sim.txt
cd ..
echo "See full-ray-marcher-sim.txt"
python scripts/txt_to_img.py full-ray-marcher-sim.txt