## Copyright (C) 2017 Ricardo Fantin da Costa
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
## Created: 2017-12-24

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
  elseif ( isa(I, "uint8") )
    H = hist(I(:), max(I(:)), 1);
  elseif ( isa(I, "uint16") )
    H = hist(I(:), max(I(:)), 1);
  endif
  # [TODO] we can make this function faster removing zero values in the histogram, and in the end correct the thresholds values
  
  # H is our histogram, need to make the divisions
  accumulative = cumsum (H);
  n_bins = length (H);
  total = accumulative(n_bins);
  accumulative_moment = cumsum ((1:n_bins) .* H);
  
  better = 0;
  better_combination = zeros (N, 1);
  mi_T = 0;
  for i = 1:n_bins
    mi_T += i * H(i);
  endfor
  
  combination = 1:N;
  
  # There are N + 1 classes
  w = zeros(N + 1, 1); # percentage of pixels in each class
  mi = zeros(N + 1, 1); # variance of pixels in each class
  while true
    # evaluate combination
    w(1) = accumulative (combination (1));
    if(w(1) != 0)
      mi(1) = accumulative_moment (combination(1)) / w(1);
    else
      mi(1) = 0;
    endif
    for i = 2:N
      w(i) = accumulative(combination(i)) - accumulative(combination(i - 1));
      if(w(i) != 0)
        mi(i) = (accumulative_moment(combination(i)) - accumulative_moment(combination(i - 1))) / w(i);
      else
        mi(i) = 0;
      endif
    endfor
    w(N + 1) = accumulative(end) - accumulative( combination(N) );
    if(w(N + 1) != 0)
      mi(N + 1) = (accumulative_moment(end) - accumulative_moment( combination(N) ) ) / (w(N + 1));
    else
      mi(N + 1) = 0;
    endif
    
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
      if combination(i) != n_bins - (N-i)
        upd = i;
        break;
      endif
    endfor
    if upd == 0 # don't need to update anything, calculation is over
      break;
    endif
    combination(upd:end) = (combination(upd) + 1):(combination(upd) + 1 + (N - upd));
  endwhile
  
  thresh = better_combination;
  
  if nargout() == 2
    # calculate the quality
    # eta = o_B**2 / o_T**2
    # o_T = (i - mi_T)**2 p_i
    o_T2 = sum ((((1:n_bins) .- ones (1, n_bins).*mi_T ).^2) .* H );
    quality = better/o_T2;
  endif
endfunction