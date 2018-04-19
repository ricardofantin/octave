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
## The second argument @var{method} standard value is "Harris" to use his goodness
## metric, another option is "MinimumEigenvalue". This other option  is good to
## detect the initial points to be tracked with sparse optical flow.
##
## The third option @var{N} is the maximun number of points returned. The default is
## 200.
##
## The available options are:
##
## QualityLevel: The worst point quality have at least QualityLevel times the
## quality of the best point. The defaut value is 0.01 (1%).
##
## FilterCoefficients: Harris paper suggests filter the image before the
## analysis. The product vector*vector' gives the kernel to filter the image.
## It should be an odd length vector.
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
  FilterCoefficients = [1];
  QualityLevel = 0.01;
  SensitivityFactor = 0.04;
  nextArgument = 1;
  if (nargin >= 2)
     if (varargin{1} == "MinimumEigenvalue")
      method = "MinimumEigenvalue";
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
  FilterCoefficients = [1];
  QualityLevel = 0.01;
  SensitivityFactor = 0.04;
  if (nargin > nextArgument)
    [unused FilterCoefficients QualityLevel SensitivityFactor] = parseparams(varargin, "FilterCoefficients", "QualityLevel", "SensitivityFactor");
  endif
#  for i = nextArgument:2:nargin+1
#    switch varargin{i}
#      case {"FilterCoefficients"}
%        % not implemented yet
%        SensitivityFactor = varargin{i+1};
%      case {"QualityLevel"}
%        if (! isnumeric (varargin{i+1}))
%          print_usage ();
%          error("The sensitivity factor should be a numeric value");
%        endif
%        QualityLevel = varargin{i+1};
%      break;
%      case {"SensitivityFactor"}
%        if (!isnumeric (varargin{i+1}))
%          print_usage ();
%          error("The sensitivity factor should be a numeric value");
%        endif
%        SensitivityFactor = varargin{i+1};
%      otherwise
%        error (["Unrecognized parameter " varargin(i)]);
%    endswitch
%  endfor
  % [A C; C B] is the wanted matrix
  % A = Horizontal Gradient
  % B = Vertical Gradient
  % C = Diagonal Gradient
  A = [1 -2 1; 2 -4 2; 1 -2 1];
  B = A';
  A = filter2(A, I);
  B = filter2(B, I);
  C = [1 0 -1; 0 0 0; -1 0 1];
  C = filter2(C, I);
  Q = zeros (size (I));
  if (method == "Harris")
    Q = A.*B - C.*C - SensitivityFactor*(A + B);
  else % method == "MinimumEigenvalue
    for i = i:size(I)(1)
      for j = j:size(I)(2)
        Q(i, j) = eigs ([A(i)(j) C(i)(j);C(i)(j) B(i)(j)], "sr");
      endfor
    endfor
  endif
  [s ind] = sort (Q(:), "descend");
  result_size = N - length (find (s(1:min(N,length(s)) <= s(1)*QualityLevel)));
  points = zeros (result_size, 2);
  image_height = size (I)(1);
  for i = 1:result_size
    points(i, 1) = mod (ind(i), image_height);
    points(i, 2) = floor (ind(i)/image_height);
  endfor
endfunction

%!test
% I = imread("default.img");
% ground_truth = [];