rm -fR for-lab-bc
mkdir for-lab-bc
cd for-lab-bc
ln -s ../obj ./obj
ln -s ../xdc ./xdc
ln -s ../data ./data
mkdir ./src
cd ..
cp test-*.sh for-lab-bc
python3 scripts/combiner.py