## Copyright (C) 2018 Ricardo Fantin da Costa <ricardofantin@gmail.com>
##
## The decomposition of diamond shape is optimized thought the 
## Logarithmic decomposition: Rein van den Boomgard and Richard
## van Balen, "Methods for Fast Morphological Image Transforms
## Using Bitmapped Binary Images," CVGIP: Models and Image
## Processing, vol. 54, no. 3, May 1992, pp. 252-254.
## The ideia is decompose large diamond shapes whith smaller ones.
## a code in java is avaliable in:
## https://github.com/tinevez/imglib2-algorithm/blob/master/src/main/java/net/imglib2/algorithm/morphology/StructuringElements.java

# template taken from octave-image/?/@strel/getsequence.m

function template = get_diamond_template ()
  s1 = s2 = [0 1 0; 1 1 1; 0 1 0];
  s2(2, 2) = 0;
  s3 = zeros(5);
  s3([3 11 15 23]) = 1;
  s4 = zeros(9);
  s4([5 37 45 77]) = 1;
  template = repmat (
  
#  template = repmat ({false(3)}, 4, 1);
#  template{1}(2,:)     = true;
#  template{2}(:,2)     = true;
#  template{3}([1 5 9]) = true;
#  template{4}([3 5 7]) = true;
#  template = cellfun (@(x) strel ("arbitrary", x), template, "UniformOutput", false);
endfunction


if (strcmp(se.shape, "diamond") && numel (se.nhood) > 49) # only boost speed with more than 16
  
endif
