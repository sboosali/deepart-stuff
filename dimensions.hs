#! /usr/bin/env runhaskell

-- #! /usr/bin/env nix-shell
-- #! nix-shell -i runghc -p "haskellPackages.ghcWithPackages (ps: with ps; [optparse-applicative])"

----------------------------------------

{-# LANGUAGE GeneralizedNewtypeDeriving #-}

{-# OPTIONS_GHC -fno-warn-missing-signatures #-}
{-# OPTIONS_GHC -fno-warn-unused-imports #-} 

----------------------------------------

import Data.Ratio
import Data.Function ((&))
import System.Environment

----------------------------------------

data Size          = Size Height Width 
newtype Height     = Height Int
 deriving (Num,Integral,Real,Ord,Eq,Enum)
newtype Width      = Width  Int
 deriving (Num,Integral,Real,Ord,Eq,Enum)

data Offset        = Offset Horizontal Vertical
newtype Horizontal = Horizontal Int
 deriving (Num,Integral,Real,Ord,Eq,Enum)
newtype Vertical   = Vertical   Int
 deriving (Num,Integral,Real,Ord,Eq,Enum)

data Crop          = Crop Size Offset

----------------------------------------

main = do

  [h', w'] <- getArgs
  let (h,w) = (read h', read w')
  let size = Size (Height h) (Width w)
  
  let crop = getMTGArtworkCroppingDimensions size
  let s = displayCrop crop
  
  putStrLn s

----------------------------------------

{-|

for images of size 'defaultSize'

-}
defaultCrop :: Crop
defaultCrop = Crop (Size 510 410) (Offset 80 95)

{-|

images of size @672 x 936@

-}
defaultSize :: Size
defaultSize = Size 672 936

----------------------------------------

{-|

>>> getMTGArtworkCroppingDimensions 312 445 
Crop (Size 238 195) (Offset 38 46)

>>> getMTGArtworkCroppingDimensions 488 680
Crop (Size 371 298) (Offset 59 70)

-}
getMTGArtworkCroppingDimensions :: Size -> Crop
getMTGArtworkCroppingDimensions (Size height width) = crop
 where
 crop = Crop
        (Size   (h `resizeBy` rx) (w `resizeBy` ry))
        (Offset (x `resizeBy` rx) (y `resizeBy` ry))

 Crop (Size h w) (Offset x y) = defaultCrop

 rx = (height `divideLosslessly` defaultHeight) & id
 ry = (width  `divideLosslessly` defaultWidth)  & id
 -- Size (Height defaultHeight) (Width defaultWidth) = defaultSize
 Size defaultHeight defaultWidth = defaultSize

 resizeBy :: Integral i => i -> Rational -> i
 resizeBy i d = (fromIntegral i * d) & ceiling 

 divideLosslessly :: (Integral i) => i -> i -> Rational
 divideLosslessly i j = toInteger i % toInteger j

 -- mapRatio

{-|

>>> displayCrop $ Crop (Size 371 298) (Offset 59 70)
"238x195+38+46"

>>> displayCrop $ Crop (Size 371 298) (Offset 59 70)
"371x298+59+70"

-}
displayCrop :: Crop -> String
displayCrop
 (Crop (Size   (Height     h)
               (Width      w))
       (Offset (Horizontal x)
               (Vertical   y)))
 = concat
   [ show h
   , "x"
   , show w
   , "+"
   , show x
   , "+"
   , show y
   ]

----------------------------------------

{-



 Crop (Size   (Height h)
              (Width  w))
      (Offset (Horizontal x)
              (Vertical   y))
   =
   defaultCrop


 divideLosslessly :: (Integral i, Fractional d) => i -> i -> d
 divideLosslessly i j = i `div` j


>>> displayCrop (getMTGArtworkCroppingDimensions (Size 312 445))
"238x195+38+46"

>>> displayCrop (getMTGArtworkCroppingDimensions (Size 488 68))
"371x298+59+70"

-}
