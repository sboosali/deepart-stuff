#!/bin/bash
set -e

# imagemagick
# feh | gpicview

########################################

INPUT="$1"

########################################

function directory {
 FILEPATH="$1"
 DIRECTORY=$(dirname "$FILEPATH")
 echo "$DIRECTORY"
}

function filename {
 FILEPATH="$1"
 FILEBASE=$(basename "$FILEPATH")
 FILENAME="${FILEBASE%.*}"
 echo "$FILENAME"
}

function extension {
 FILEPATH="$1"
 EXTENSION="${FILEPATH##*.}"
 echo "$EXTENSION"
}

########################################

INPUT_DIRECTORY=$(directory "$INPUT")
INPUT_FILENAME=$(filename "$INPUT")
INPUT_EXTENSION=$(extension "$INPUT")

OUTPUT="${INPUT_DIRECTORY}/cropped_${INPUT_FILENAME}.${INPUT_EXTENSION}"

########################################

echo
echo "$INPUT"
echo "$OUTPUT"
echo

# convert  input.jpg  -resize 100x100^  -gravity Center   -extent 100x100  output.jpg

SIZE=$(convert  "$INPUT"  -ping  -format "%w %h" info:)

echo "$SIZE"
echo

EXTENT=$(./dimensions.hs $SIZE)
# EXTENT=371x298+59+70  

echo "$EXTENT"
echo

convert  "$INPUT"  -extent "$EXTENT"  "$OUTPUT"

echo

# e.g.
# 510x410+80+95 
# 371x298+59+70
# 238x195+38+46 

feh -Z "$OUTPUT"

# NOTE  -extent WxH+X+Y
# W,H the crop size
# X,Y is the offset

########################################


# HEIGHT=
# WIDTH=
# # EXTENT=$(./dimensions.hs "$HEIGHT" "$WIDTH")


# feh -FZ "$OUTPUT"
# gpicview "$OUTPUT"

# e.g.
#  convert  regeneration.jpg  -resize 100x100^  -gravity Center   -extent 100x100  regeneration.crop.jpg  &&  feh -Z regeneration.crop.jpg

#NOTE old frames
# size (of original) is:
#  672 x 936
# crop is between
#  { 80x95 - 590x505 }
#
# i.e. 510x410+80+95
#
# 510/672 and 410/936
# i.e. ~76% of the width and ~44% of the height
#
# absolute:
# 312*(76/100) x 445*(44/100)
# =
# 237 x 196

#NOTE resizing
# larger:   672 x 936
# smaller:  312 x 445
# ratio:    (312/672) x (445/936)
#         = 0.46428571428 x 0.47542735042
# relative:
# (510*0.465) x (410*0.475) +(80*0.465) +(95*0.475)
# =
# 
# > [(510*0.465),(410*0.475),(80*0.465),(95*0.475)] & fmap ceiling & fmap show & (\[h,w,x,y] -> concat [h,"x",w,"+",x,"+",y]) & putStrLn
# 238x195+38+46

#NOTE resizing
# larger:   672 x 936
# medium:   488 x 680
# ratio:    

