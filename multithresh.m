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
## @deftypefn {} {@var{threash, quality} =} multithresh (@var{I}, @var{N})
## The function multithres return the values of the image or histogram @var{I}
## that better separate the the image in @var{N} regions accordingly to the
## otsu's algorithm.
## 
## Is important to note that different from graythresh,
## multithresh return the threshold value not the normalized value.
## 
## If is asked to segment in more regions than existing color levels,
## then the quality will be 0 and arbitraries levels will be returned.
## @seealso{graythresh, otsuthresh}
## @end deftypefn

## Author: Ricardo Fantin da Costa <ricardofantin@gmail.com>
## Created: 2018-03-16

function [thresh, quality] = multithresh (I, N = 1)
  if (nargin < 1 || nargin > 2)
    print_usage ();
  endif
  
  if (isrgb (I))
    I = rgb2gray (I);
  endif
  # Need convert the input in a histogram
  # we have a gray image or a histogram?
  if (isvector (I) && !issparse (I) && isreal (I) && all (I >= 0))
    H = I;
  # need to make a histogram
  elseif ( isa (I, "uint8") )
    H = hist (I(:), max (I(:)), 1);
  elseif ( isa (I, "uint16") )
    H = hist (I(:), max (I(:)), 1);
  endif
  
  # H is our histogram, need to make the divisions
  accumulative = cumsum (H);
  n_bins = length (H);
  total = accumulative(n_bins);
  accumulative_moment = cumsum ((1:n_bins) .* H);
  
  # Removing zero values to speed calculation and
  # remove possible division by zero
  zeros_values = find (H == 0);
  nonzeros_values = find (H != 0);
  accumulative = accumulative(nonzeros_values);
  accumulative_moment = accumulative_moment(nonzeros_values);
  n_bins = length (accumulative);
  
  # Testing if is wanted more regions than existing color levels
  if(N >= n_bins)
    warning (["There are " num2str(n_bins) " different colors (bins in Histogram), this number should be bigger than N"])
    thresh = 1:N;
    quality = 0;
    return;
  endif
  
  better = 0;
  better_combination = zeros (N, 1);
  mi_T = 0;
  for i = 1:length (H)
    mi_T += i * H(i);
  endfor
  
  combination = 1:N;
  
  # There are N + 1 classes
  w = zeros (N + 1, 1); # percentage of pixels in each class
  mi = zeros (N + 1, 1); # variance of pixels in each class
  while true
    # evaluate combination
    w(1) = accumulative (combination(1));
    mi(1) = accumulative_moment (combination(1)) / w(1);
    for i = 2:N
      w(i) = accumulative(combination(i)) - accumulative(combination(i - 1));
      mi(i) = (accumulative_moment(combination(i)) - accumulative_moment(combination(i - 1))) / w(i);
    endfor
    w(N + 1) = accumulative(end) - accumulative( combination(N) );
    mi(N + 1) = (accumulative_moment(end) - accumulative_moment( combination(N) ) ) / (w(N + 1));
    
    value = 0;
    for i = 1 : N + 1
      value += w(i) * (mi(i) - mi_T)**2;
    endfor
    
    if value > better
      better = value;
      better_combination = combination;
    endif
    
    # next combination
    # which thresholds we should update?
    upd = 0;
    for i = N:-1:1
      if combination(i) != n_bins - (N-i) - 1
        upd = i;
        break;
      endif
    endfor
    if upd == 0 # don't need to update anything, calculation is over
      break;
    endif
    combination(upd:end) = (combination(upd) + 1):(combination(upd) + 1 + (N - upd));
  endwhile
  
  for i = 1:length (better_combination)
    better_combination(i) += length (find (zeros_values <= better_combination(i)));
  endfor
  
  thresh = better_combination;
  
  if nargout() == 2
    # calculate the quality
    # eta = o_B**2 / o_T**2
    # o_T = (i - mi_T)**2 p_i
    n_bins = length (H);
    o_T2 = sum ((((1:n_bins) .- ones (1, n_bins).*mi_T ).^2) .* H );
    quality = better/o_T2;
  endif
endfunction

%!test
%! U = imread ("default.img");
%! [T1, Q1] = graythresh (U);
%! [T2, Q2] = multithresh (U);
%! assert (Q1, Q2, 0.001)
%! [T3, Q3] = multithresh (U, 2);
%! assert (T3, [17 36])
%! imshow (U)
%! V = zeros (size (U));
%! V(U > T3(1) & U <= T3(2)) = 0.5;
%! V(U > T3(2)) = 1;
%! figure, imshow (V);