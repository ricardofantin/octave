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
## @deftypefn {} {@var{metrics} =} cornermetric (@var{I}, @var{method}, @var{options})
## Calculate the quality metric for all pixels in image @var{I} using the method
## of "Harris" [1] (default) or Shi Tomasi "MinimumEigenvalue" [2].
## 
## The method parameter is optional. The options are optional too. The possible
## options are:
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
## 
## @seealso{corner}
## @end deftypefn

## Author: Ricardo Fantin da Costa <ricardo@ricardo-OEM>
## Created: 2018-05-03

function [metrics] = cornermetric (I, options)
  if (isrgb (I) || nargin < 1)
    print_usage ();
    error ();
  endif
  method = "Harris";
  FilterCoefficients = fspecial ("gaussian", [5 1], 1.5);
  SensitivityFactor = 0.04;
  nextArgument = 1;
  if (nargin >= 2)
     if (strcmp (varargin{1}, "MinimumEigenvalue"))
       method = "MinimumEigenvalue";
       nextArgument = 2;
     elseif (strcmp (varargin{1}, "Harris"))
       nextArgument = 2;
    endif
  endif
  [unused FilterCoefficients SensitivityFactor] = parseparams(options(nextArgument:end), "FilterCoefficients", "SensitivityFactor");
  if (mod (length (FilterCoefficients), 2) == 1 && length (FilterCoefficients) < 3)
    error ("Filter coefficients should be 3 or bigger and have odd length.");
  endif
  I = double (I) ./ 255;
  % [A C; C B] is the wanted matrix
  % A = Horizontal Gradient
  % B = Vertical Gradient
  % C = Diagonal Gradient
  A = [-1 0 1];
  B = A';
  A = imfilter (I, A);
  B = imfilter (I, B);
  C = A.*B;
  A = A.*A;
  B = B.*B;
  metrics = zeros (size (I));
  if (strcmp (method, "Harris"))
    metrics = A.*B - C.*C - SensitivityFactor*(A + B);
  else % method == "MinimumEigenvalue
    for i = 1:size(I)(1)
      for j = 1:size(I)(2)
        metrics(i, j) = eigs (double ([A(i, j) C(i, j); C(i, j) B(i, j)]), 1, "sm");
      endfor
    endfor
  endif
  F = FilterCoefficients*FilterCoefficients';
  W = imfilter (I, F);
  metrics = metrics .* W;
endfunction

%!test
%! I = imread("default.img");
%! metric = cornermetric(I);
%! metric_GT = [];
%! assert (metric, metric_GT);
%! metric = cornermetric (I, MinimumEigenvalue);
%! metric_GT = [];
%! assert (metric, metric_GT);
%! 