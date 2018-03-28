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
## @deftypefn {} {@var{string} =} angl2str (@var{angles}, @var{sign_notation}, @var{unit}, @var{n})
## Convert angles to notation as angles represents latitudes or longitudes.
## 
## The sign 
## @seealso{angl2str}
## @end deftypefn

## Author: Ricardo Fantin da Costa <ricardofantin@gmail.com>
## Created: 2018-03-27

function [string] = angl2str (angles, sign_notation = "none", unit = "radians", n = -2)
  if (nargin < 1 || nargin > 4)
    print_usage ();
  endif
  
  if (sign_notation != "ew" && sign_notation != "ns" && sign_notation != "'pm" && sign_notation != "none")
    error("sign_notation should be \"ew\" (east/west), \"ns\" (north/south), \"pm\" (plus/minus) or \"none\".");
  endif
  
  if (unit != "radians" && unit != "degrees" && unit != "degress2dm" && unit != "degrees2dms")
    error ("unit should be \"radians\", \"degrees\", \"degrees2dm\" or \"degrees2dms\".");
  endif
  
  
  # need the round () function with the second argument
  
  # first the verification, after the loop. For speed.
  for i = 1:length (angles)
    
  endfor
  
endfunction
