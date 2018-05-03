## Copyright (C) 2018 Ricardo Fantin da Costa
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{retval} =} corner (@var{I}, @var{method}, @var{N}, @var{options})
## The function corner finds corner points in images. Corner points have great
## gradient in horizontal, vertical and diagonal directions.
## 
## The second argument @var{method} standard value is "Harris" to use his
## goodness metric, another option is "MinimumEigenvalue". This other option
## is good to detect the initial points to be tracked with sparse optical flow.
## 
## The third option @var{N} is the maximun number of points returned. The
## default is 200.
## 
## The available options are:
## 
## QualityLevel: The worst point quality have at least QualityLevel times the
## quality of the best point. The defaut value is 0.01 (1%).
## 
## FilterCoefficients: Harris paper suggests filter the image before the
## analysis. The product vector*vector' gives the kernel to filter the image.
## It should be an odd length vector. The default value for vector is given by
## fspecial ("gaussian", [5 1], 1.5).
## 
## SensitivityFactor: In Harris paper the quality is a weighted sum. The
## ponderation is given by SensitivityFactor. The default is 0.04.
## 
## [1] Chris Harris and Mike Stephens (1988). "A Combined Corner and Edge
## Detector". 1998. Alvey Vision Conference.
## 
## [2] Jianbo Shi and C. Tomasi. "Good features to track". 1994. Proceedings of
## IEEE Conference on Computer Vision and Pattern Recognition, Seattle, WA,
## 1994, pp. 593-600. doi: 10.1109/CVPR.1994.323794
## @seealso{cornermetric, detectHarrisFeatures, detectMinEigenFeatures, opticalFlowLK}
## @end deftypefn

## Author: Ricardo Fantin da Costa <ricardofantin@gmail.com>
## Created: 2018-04-06

function [points] = corner (I, varargin)
  if (isrgb (I) || nargin < 1)
    print_usage ();
    error ();
  endif
  method = "Harris";
  N = 200;
  FilterCoefficients = fspecial ("gaussian", [5 1], 1.5);
  QualityLevel = 0.01;
  SensitivityFactor = 0.04;
  nextArgument = 1;
  if (nargin >= 2)
     if (strcmp (varargin{1}, "MinimumEigenvalue"))
       method = "MinimumEigenvalue";
       nextArgument++;
     elseif (strcmp (varargin{1}, "Harris"))
       nextArgument++;
    endif
  endif
  if (nargin > nextArgument)
    if (isnumeric (varargin{nextArgument}) && length (varargin{nextArgument}))
      N = varargin{nextArgument};
      nextArgument++;
    endif
  endif
  if (mod (nargin - nextArgument, 2) == 1)
    print_usage ();
    error ("One of you parameters only have a name or property and not a pair");
  endif
  if (nargin > nextArgument + 2) % +1 for propertie name + 1 for value
    [unused FilterCoefficients QualityLevel SensitivityFactor] = parseparams(varargin(nextArgument:end), "FilterCoefficients", "QualityLevel", "SensitivityFactor");
  endif
  Q = cornermetric (I, method, "FilterCoefficients", FilterCoefficients, "SensitivityFactor", SensitivityFactor);
  [s ind] = sort (Q(:), "descend");
  % minQualityLevel = min(Q(:))(1), maxQualityLevel = max(Q(:))(1)
  result_size = N - length (find (s(1:min(N,length(s)) <= s(1)*QualityLevel)));
  points = zeros (result_size, 2);
  image_height = size (I)(1);
  for i = 1:result_size
    points(i, 1) = floor (ind(i)/image_height);
    points(i, 2) = mod (ind(i), image_height);
  endfor
endfunction

%!test
%! I = imread("default.img");
%! % GT stands for groundtruth, CV stands for OpenCV
%! p1_GT = [37 34; 25 33; 27  6;  5 30; 31 45;
%!           3 36;  9 51; 12 32;  4 15; 30 29;
%!           2 26;  1 30; 20 49; 12 45; 37 47;
%!          30 25;  8 45;  3 53; 15 42; 20 44;
%!           9 21; 18 32; 13 19];
%! p1_CV = [ 2 29; 36 34; 33 34; 27  6;  6 29;
%!           3 34;  4 15; 29 45; 33 44;  9 52;
%!          31 29; 14 45;  2 13; 16 42; 11 29;
%!          15 33;  9 20; 25 33; 12 42; 29 42;
%!          20 48; 18 44; 18 32;  7 44; 23 35];
%! p2_GT = [36 33; 24 33; 28  7;  3 36; 31 45;
%!           5 30; 29 46;  9 51; 11 32; 13 32;
%!          33 35; 30 28; 34 33;  4 16;  2 26;
%!          20 49; 37 48; 17 49; 16 51;  9 45;
%!          20 43; 12 45; 39 32; 18 32; 30 26;
%!           3 53;  2 30; 13 48; 31 33; 26 46;
%!          15 42;  9 21; 35 46; 20 19];
%! p3_GT = [36 33; 28  6;  3 36; 25 33; 32 45;
%!           9 51; 33 33;  6 29; 10 30; 14 32;
%!           4 15; 12 45; 21 49;  2 25; 31 29;
%!          19 44; 37 47; 18 33; 17 50;  8 45;
%!          16 42;  3 53; 30 25;  9 21; 37 51;
%!          20 40; 12 36;  1 47; 24 17; 13 19;
%!          12 40; 20 19; 27 53; 27 20; 23  6;
%!          15  8; 18 14; 39 14; 30 15;  9 12;
%!          16 18; 21 12; 40 18;  1 11];
%! p3_CV = [ 2 29; 36 34; 33 34;  6 28;  2 34;
%!          27  5;  4 15; 33 44;  9 52; 29 45;
%!          14 45; 15 33; 39 33; 25 33; 31 29;
%!          18 44;  8 44; 26 44; 11 43; 18 32;
%!          10 31; 12 41;  2 13; 29 42; 16 42;
%!          20 48;  9 20; 23 45; 29 25; 10 35;
%!          23 43; 26 37; 31 52; 12 21;  6 38;
%!          29 35;  2 39; 25 49;  6 49;  2 42;
%!          20 39; 37 47;  8 17;  2 52; 37 50;
%!          17 52; 20 19; 29 19; 15 38; 26 21;
%!           6 41; 22  6; 12 14; 13 52; 17  6;
%!          12 25; 19 23; 13 10;  8 12; 17 14;
%!          17 11; 15  3;  7  8;  5  8];
%! p4_GT = [36 33; 24 33;  3 36; 28  7;  5 30;
%!          27 33; 31 45; 14 32;  9 51; 29 46;
%!          11 32; 10 30;  4 15; 34 32; 37 47;
%!          20 48; 18 32; 33 35;  2 26; 30 28;
%!           8 44; 17 49; 12 45;  2 29; 19 44;
%!          16 51; 21 45; 14 45; 26 45;  3 53;
%!          30 42; 15 35; 22 36; 30 26; 31 33;
%!           9 21; 37 53; 15 42; 35 53; 13 36;
%!          35 51; 35 46; 25 17;  1 48;  6 41;
%!          20 19; 23 16;  8 39; 20 39; 12 41;
%!          15  8; 13 19; 32 22; 27 52; 25 51;
%!           9 11;  4 23; 24  6; 18 15; 27 20;
%!          18  7; 16 16; 23 53; 39 14; 27 15;
%!           9 26; 17 20; 31 15; 40 47; 15 11;
%!          24 12; 30 17; 38 18; 29 10;  2 11;
%!           9 24; 31 12; 21 12; 23 23;  1 18;
%!          33  3; 32 49; 13 13; 39 26; 13 25;
%!          19 24; 30  3];
%! p1 = corner (I);
%! assert (p1, p1_GT);
%! assert (p1, p1_CV);
%! p2 = corner (I, "FilterCoefficients", [1 2 1]);
%! assert (p2, p2_GT);
%! p3 = corner (I, "MinimumEigenvalue");
%! assert (p3, p3_GT);
%! assert (p3, p3_CV);
%! p4 = corner (I, "MinimumEigenvalue", "FilterCoefficients", [1 2 1]);
%! assert (p4, p4_GT);
%
%!demo
%! I = imread ("default.img");
%! imshow (I);
%! hold;
%! p = corner (I, "MinimumEigenvalue");
%! plot (p(:,1), p(:,2),"marker", "o", "color", "r", "linestyle", "none");