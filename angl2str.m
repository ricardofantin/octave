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
## Unless especified in unit, the angle is espected to be in degrees.
## The resulted string is intended to show angles in map.
## 
## The @var{sign_notation} specifies how the positive/negative sign is
## shown. The possibles values are "ew" (east/west), "ns" (north/shouth),
## "pm" (plus/minus) or "none".
## 
## The possible @var{unit}'s values are "radians", "degrees", "degress2dm" or "degrees2dms".
## dms stands for degrees minutes and seconds.
## 
## The parameter @var{n} indicates how many algarishm will be used to round the
## last angle part.
## @seealso{str2angle}
## @end deftypefn

## Author: Ricardo Fantin da Costa <ricardofantin@gmail.com>
## Created: 2018-03-27

function [string] = angl2str (angles, sign_notation = "none", unit = "degrees", n = -2)
  if (nargin < 1 || nargin > 4)
    print_usage ();
  endif
  
  sign_notation = tolower(sign_notation);
  if (!(strcmp (sign_notation, "ew") || strcmp (sign_notation, "ns") ||
        strcmp (sign_notation, "pm") || strcmp (sign_notation, "none")))
    error("sign_notation should be \"ew\" (east/west), \"ns\" (north/south), \"pm\" (plus/minus) or \"none\".");
  endif
  
  unit = tolower(unit);
  if (!(strcmp (unit, "radians") || strcmp (unit, "degrees") ||
        strcmp (unit, "degrees2dm") || strcmp (unit, "degrees2dms")))
    error ("unit should be \"radians\", \"degrees\", \"degrees2dm\" or \"degrees2dms\".");
  endif
  
  if (strcmp (unit, "radians"))
    angles = rad2deg (angles);
    unit = "degrees";
  endif
  
  signs = zeros (length (angles));
  switch (sign_notation)
    case "ew"
      for i = 1: length (angles)
        if (angles(i) == 0)
          signs(i) = " ";
        elseif (angles(i) < 0)
          signs(i) = "W";
        else
          signs(i) = "E";
        endif
      endfor
    case "ns"
      for i = 1: length (angles)
        if (angles(i) == 0)
          signs(i) = " ";
        elseif (angles(i) < 0)
          signs(i) = "S";
        else
          signs(i) = "N";
        endif
      endfor
    case "pm"
      for i = 1: length (angles)
        if (angles(i) >= 0)
          signs(i) = "+";
        elseif (angles(i) < 0)
          signs(i) = "-";
        endif
      endfor
    case "none"
      for i = 1: length (angles)
        if (angles(i) >= 0)
          signs(i) = " ";
        elseif (angles(i) < 0)
          signs(i) = "-";
        endif
      endfor
  endswitch
  angles = abs (angles);
  
  string_length = 0;
  switch (unit)
    case "degrees"
      string_length = 7;%"DDº S "
    case "degrees2dm"
      string_length = 11;%"DDº MM" S "
    case "degrees2dms"
      string_length = 15;%"DDº MM" SS' S "
  endswitch
%  if (n < 0)
%    string_length -= n -1;%1 for dot n for algorisms after the dot
%  endif
  %string = char (length (angles), string_length)
  string = char (zeros (length (angles), string_length));
  
  # first the verification, after the loop. For speed.
  switch (unit)
    case "degrees"
      for i = 1:length (angles);
        string(i, :) = sprintf("%2dº %c ", round (angles(i)), signs(i));
      endfor
    case "degrees2dm"
      for i = 1:length (angles);
        minutes = (angles(i) - round (angles(i)))*(60/100);
        string(i, :) = sprintf("%2dº %02d' %c ", round (angles(i)), round (minutes), signs(i));
      endfor
    case "degrees2dms"
      for i = 1:length (angles);
        minutes = (angles(i) - round (angles(i)))*(60/100);
        seconds = (minutes - round (minutes))*(60/100);
        seconds = round (seconds, -n);
        string(i, :) = sprintf("%2dº %02d' %02d\" %c ", angles(i), minutes, signs(i));
      endfor
  endswitch
  
endfunction

%!test
% assert (angl2str(40), "40º");
% assert (angl2str(0, "pm"), " 0º");
% assert (angl2str(, ""), "");