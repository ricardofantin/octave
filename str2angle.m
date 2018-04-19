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
## @deftypefn {Function File} {@var{angles} =} str2angle (@var{str})
##
## @seealso{angl2str}
## @end deftypefn

## Author: Ricardo Fantin da Costa <ricardo@ricardo-desktop>
## Created: 2018-04-18

function [angles] = str2angle (str)
  angles = zeros (length (str), 1);
  for i = 1:length (str)
    if (strfind (str(i), "º") != [])%"175°20''50"W"
      [d, m, s, sign, number_errors, errors] = sscanf(str(i), "%dº%d''%d\"%c");
      angles(i) = d + m/60 + s/360;
      if (sign == "W" || sign == "S")
        angles(i) *= -1;
      endif
    elseif (strfind (str(i), "d") != [])%"175d20m50sW"
      [d, m, s, sign] = sscanf(str(i), "%dd%dm%ds%c");
      angles(i) = d + m/60 + s/360;
      if (sign == "W" || sign == "S")
        angles(i) *= -1;
      endif
    elseif (strfind (str(i), "-") != [])%"175-20-50W"
      [d, m, s, sign] = sscanf(str(i), "%d-%d-%d%c");
      angles(i) = d + m/60 + s/360;
      if (sign == "W" || sign == "S")
        angles(i) *= -1;
      endif
    else%1752050W
      [d, sign] = sscanf(str(i), "%d%c");
    endif
  endfor
endfunction
