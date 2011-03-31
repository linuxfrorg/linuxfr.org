#!/bin/bash

# http://www.imagemagick.org/Usage/warping/animate_mixer
function mixer {
	local i

	command="convert -delay 20 $1"
	for i in `seq 10 40 360; seq 340 -40 -360; seq -340 40 0`; do
	  command="$command \\( -clone 0 -swirl $i \\)"
	done

	command="$command -loop 0 $2"
	eval $command
}

# http://www.imagemagick.org/Usage/warping/animate_whirlpool
function whirlpool {
	local i

	command="convert -delay 10 $1"
	command="$command -bordercolor white -border 40x40"

	for i in `seq 1 72`; do
	  s_arg=`echo "$i * 15" | bc`
	  i_arg=`echo "scale=2; $i / 54" | bc`
	  command="$command \\( -clone 0 -swirl $s_arg -implode $i_arg \\)"
	done

	command="$command -shave 40x40 +repage -loop 0 $2"
	eval $command
}

# http://www.imagemagick.org/Usage/warping/animate_explode
function explode {
	local i

	command="convert -delay 50 $1"
	command="$command -bordercolor white -border 60x60"  # enlarge image
	center='rectangle 97,97 98,98'   # the pixels that control the explosion color

	for i in `seq 1 2 20`; do
		#c_arg="white"
		c_arg=`perl -e '$i=1-'$i'/12; $i=$i>0?($i*400):0; $i=$i>255?255:$i; \
			printf "rgb(%d,%d,%d)", $i, $i, $i;'`
		command="$command \\( -clone 0 -draw 'fill $c_arg $center'"
		command="$command -implode -$i -set delay 10 \\)"
	done

	command="$command -shave 60x60 +repage -loop 0 $2"
	eval $command
}

# http://www.imagemagick.org/Usage/warping/animate_flex
function flex {
	local i

	command="convert -delay 10 $1"
	command="$command -background white -bordercolor white -border 0x10"

	for i in `seq 10 -2 -8; seq -10 2 8`; do
	  command="$command \\( -clone 0 -wave ${i}x150 \\)"
	done

	# remove original image
	# center all the image frames vertically by center cropping
	command="$command -delete 0 +repage -gravity center -crop 0x98+0+0"
	command="$command +repage -loop 0 $2"
	eval $command
}

# http://www.imagemagick.org/Usage/warping/animate_flag
function flag {
	local i

	command="convert -delay 20 $1"
	command="$command -background white -bordercolor white -border 5x2"

	for i in `seq 100 -4 0;`; do
	  command="$command \\( -clone 0 -splice ${i}x0+0+0 "
	  command="$command -wave 10x100 -chop ${i}x0+0+0 \\)"
	done

	# remove page offsets and delet the original image
	command="$command +repage -delete 0 -loop 0 $2"
	eval $command
}

# http://www.imagemagick.org/Usage/warping/animate_rotate
function rotate {
	local i

	command="convert -delay 10 $1"
	command="$command -background white -gravity center -compose Src"

	for i in `seq 5 5 360`; do
	  command="$command \\( -clone 0 -rotate $i -clone 0 +swap -composite \\)"
	done

	command="$command -delete 0 -loop 0 $2"
	eval $command
}


# Main
cd public/avatars
animations=( mixer whirlpool explode flex flag rotate )
nb=${#animations[*]}

for i in *; do
	cd $i
	animation=${animations[`expr $i % $nb`]}
	for j in */*/*; do
		k=${j%\.*}_1.gif
		$animation $j $k
		chmod 644 $k
	done
	cd ..
	echo $i
done

