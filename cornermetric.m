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

function [metrics] = cornermetric (I, varargin)
  if (isrgb (I) || nargin < 1)
    print_usage ();
    error ();
  endif
  method = "Harris";
  nextArgument = 1;
  if (nargin >= 2)
     if (strcmp (varargin{1}, "MinimumEigenvalue"))
       method = "MinimumEigenvalue";
       nextArgument = 2;
     elseif (strcmp (varargin{1}, "Harris"))
       nextArgument = 2;
    endif
  endif
  [unused FilterCoefficients SensitivityFactor] = parseparams(varargin(nextArgument:end), "FilterCoefficients", fspecial ("gaussian", [5 1], 1.5), "SensitivityFactor", 0.04);
  if (mod (length (FilterCoefficients), 2) == 1 && length (FilterCoefficients) < 3)
    error ("Filter coefficients should be 3 or bigger and have odd length.");
  endif
  I = double (I);% ./ 255;
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
%! K = [1 0 0 0 0 0 0 0 0 0;
%!      0 0 0 0 0 0 0 1 0 0;
%!      0 0 0 0 0 0 1 1 1 0;
%!      0 0 0 0 0 0 0 1 0 0;
%!      1 1 1 0 0 0 0 0 0 0;
%!      0 0 0 0 0 0 0 0 0 0;
%!      0 0 0 1 0 0 1 1 1 0;
%!      0 0 1 0 0 0 1 1 1 0;
%!      0 1 0 1 0 0 1 1 1 0;
%!      1 0 0 0 1 0 0 0 0 0];
%! metric = cornermetric(K, "Harris");
%! metric_GT = [      0       0       0 -0.0000  0.0019  0.0279  0.1867  0.3793  0.3516  0.0509;
%!              -0.0006 -0.0004 -0.0002  0.0010  0.0114  0.0537  0.1859  0.3447  0.4165  0.3516;
%!               0.0009  0.0063  0.0077  0.0068  0.0172  0.0560  0.1472  0.2560  0.3447  0.3793;
%!               0.0038  0.0228  0.0292  0.0229  0.0249  0.0464  0.1063  0.1828  0.2355  0.2447;
%!               0.0123  0.0463  0.0642  0.0517  0.0436  0.0549  0.0984  0.1520  0.1932  0.2065;
%!               0.0504  0.0811  0.0953  0.0770  0.0628  0.0756  0.1200  0.1676  0.2056  0.2235;
%!               0.0447  0.0677  0.0954  0.0974  0.0964  0.1189  0.1801  0.2306  0.2708  0.2921;
%!               0.0249  0.0440  0.0932  0.1166  0.1356  0.1700  0.2636  0.3257  0.3968  0.4491;
%!               0.0064  0.0248  0.0832  0.1184  0.1431  0.1811  0.3256  0.3968  0.4165  0.3516;
%!               0.0071  0.0144  0.0539  0.0976  0.1187  0.1527  0.3594  0.4491  0.3516  0.0509];
%! assert(metric, metric_GT, 0.001);
%! I = imread("default.img");
%! metric = cornermetric(I);
%! metric_GT = [];
%! I = imread("default.img");
%! metric = cornermetric(I);
%! metric_GT = [];
%! assert (metric, metric_GT);
%! metric = cornermetric (I, MinimumEigenvalue);
%! metric_GT = [];
%! assert (metric, metric_GT);
%! 
