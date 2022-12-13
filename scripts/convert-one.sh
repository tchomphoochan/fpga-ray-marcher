mkdir $1
cp raw/$1.png $1/$1.png
cd $1
python3 ../img_to_mem.py $1.png L 16
rm -f $1.png
cd ..