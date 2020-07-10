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
## "pm" (plus/minus) or "none". Default value is "none".
## 
## The possible @var{unit}'s values are "radians", "degrees", "degress2dm" or "degrees2dms".
## dms stands for degrees minutes and seconds.
## 
## The parameter @var{n} indicates how many algarishm will be used to round the
## last angle part.
##
## Octave uses ° for degress, Matlab uses ^{\circ} latex output.
## @seealso{str2angle}
## @end deftypefn

## Author: Ricardo Fantin da Costa <ricardofantin@gmail.com>
## Created: 2018-03-27

function [string] = angl2str (angles, sign_notation = "none", unit = "degrees", n = -2)
  if (nargin < 1 || nargin > 4)
    print_usage ();
  endif
  
  original = sign_notation;
  sign_notation = tolower(sign_notation);
  if (!(strcmp (sign_notation, "ew") || strcmp (sign_notation, "ns") ||
        strcmp (sign_notation, "pm") || strcmp (sign_notation, "none")))
    error(["angl2str.m: sign_notation should be \"ew\" (east/west), \"ns\" (north/south), \"pm\" (plus/minus) or \"none\". Got " original "."]);
  endif
  
  original = unit;
  unit = tolower(unit);
  if (!(strcmp (unit, "radians") || strcmp (unit, "degrees") ||
        strcmp (unit, "degrees2dm") || strcmp (unit, "degrees2dms")))
    error (["angl2str.m: unit should be \"radians\", \"degrees\", \"degrees2dm\" or \"degrees2dms\". Got " original "."]);
  endif
  
  % vectorize these for
  signs = char (zeros (length (angles), 1));
  switch (sign_notation)
    case "ew"
      for i = 1: length (angles)
        if (angles(i) == 0)
          signs(i) = ' ';
        elseif (angles(i) < 0)
          signs(i) = 'W';
        else
          signs(i) = 'E';
        endif
      endfor
    case "ns"
      for i = 1: length (angles)
        if (angles(i) == 0)
          signs(i) = ' ';
        elseif (angles(i) < 0)
          signs(i) = 'S';
        else
          signs(i) = 'N';
        endif
      endfor
    case "pm"
      for i = 1: length (angles)
        if (angles(i) >= 0)
          signs(i) = '+';
        elseif (angles(i) < 0)
          signs(i) = '-';
        endif
      endfor
    case "none"
      for i = 1: length (angles)
        if (angles(i) >= 0)
          signs(i) = ' ';
        elseif (angles(i) < 0)
          signs(i) = '-';
        endif
      endfor
  endswitch
  angles = abs (angles);
  
  # first the verification, after the loop. For speed.
  switch (unit)
    case "radians"
      number_part = round2str(angles, n, first=true);% num2str (angles, n);
    case "degrees"
      number_part = [round2str(angles, n, first=true) '°'];% num2str (angles, n);
    case "degrees2dm"
      for i = 1:length (angles);
        d = round (angles); % degrees
        m = (angles - d) * 60; % minutes
        degrees_part = num2str (d);
        minutes_part = round2str(m, n);
        number_part = [degrees_part '° ' minutes_part ''''];
      endfor
    case "degrees2dms"
      for i = 1:length (angles);
        d = round (angles); % degrees
        aux = m = (angles - d) * 60; % minutes
        m = round (m);
        s = (aux - m) * 60; % seconds
        degrees_part = num2str (d);
        minutes_part = round2str (m);
        seconds_part = round2str (s, n);
        number_part = [degrees_part '° ' minutes_part ''' ' seconds_part '"'];
      endfor
  endswitch
  
  space_char = char (ones (length (angles), 1)*' ');
  if (strcmp (unit, "radians") && (strcmp (sign_notation, "ew") || strcmp (sign_notation, "ns")))
    R_char = char (ones (length (angles), 1)*'R');
    string = [space_char number_part space_char R_char space_char signs space_char];
  elseif (strcmp (unit, "radians")) % sign_notation is 'pm' or 'none'
    R_char = char (ones (length (angles), 1)*'R');
    string = [space_char signs number_part space_char R_char space_char];
  elseif (strcmp (sign_notation, "ew") || strcmp (sign_notation, "ns")) % unit is degrees, degrees2dm or degrees2dms
    string = [space_char number_part space_char signs space_char];
  else % sign_notation is "pm" or "none" and unit is degrees, degrees2dm or degrees2dms
    string = [space_char signs number_part space_char];
  endif
  
endfunction

% digits to represent 
function [str] = round2str(number, dig = 0, first = false)
  if (dig < 0)
    significants = num2str (-1 * dig);
    str = num2str (number, ['%.' significants 'f']);
  elseif (dig == 0)
    str = num2str (number, ['%.f']);
  else
    multiplier = 10 ** (dig);
    number = round (number / multiplier) * multiplier;
    str = num2str (number, ['%.f']);
  endif
  
  if (first == false && number < 10)
    precending_zero = num2str ('0');
    str = [precending_zero str];
  endif
endfunction

function [num] = my_round (X, N, type = "decimals")
  dig = 0
  if (strcmp (type, "significant"))
    # first need to discover the number of digits before point
    %I = floor (X);
    dig = log10 (X);
  elseif (strcmp (type, "decimals") == 0)
    error (["round.m: Error, type should be \"decimals\" or \"significant\". You used " type " ."]);
    print_usage ();
  endif
  
##  if (strcmp (type, "decimals"))
##    
##  elseif (strcmp (type, "significant"))
##    error ("round.m: Error unimplemented.");
##    print_usage ();
##  else
##    error ("round.m: Error unsuported type.");
##    print_usage ();
##  endif
endfunction

%!test
%!assert (angl2str (-12, "ew", "radians", -5), " 12.00000 R W ");
%!assert (angl2str (-12, "ew", "radians", -2), " 12.00 R W ");
%!assert (angl2str (-12, "ew", "radians", 0), " 12 R W ");
%!assert (angl2str (-12, "ew", "radians", 1), " 10 R W ");
%!assert (angl2str (-12, "ew", "radians", 5), " 0 R W ");
%!assert (angl2str (-12, "ew", "degrees", -5), " 12.00000° W ");
%!assert (angl2str (-12, "ew", "degrees", -2), " 12.00° W ");
%!assert (angl2str (-12, "ew", "degrees", 0), " 12° W ");
%!assert (angl2str (-12, "ew", "degrees", 1), " 10° W ");
%!assert (angl2str (-12, "ew", "degrees", 5), " 0° W ");
%!assert (angl2str (-12, "ew", "degrees2dm", -5), " 12° 00.00000' W ");
%!assert (angl2str (-12, "ew", "degrees2dm", -2), " 12° 00.00' W ");
%!assert (angl2str (-12, "ew", "degrees2dm", 0), " 12° 00' W ");
%!assert (angl2str (-12, "ew", "degrees2dm", 1), " 12° 00' W ");
%!assert (angl2str (-12, "ew", "degrees2dm", 5), " 12° 00' W ");
%!assert (angl2str (-12, "ew", "degrees2dms", -5), " 12° 00' 00.00000\" W ");
%!assert (angl2str (-12, "ew", "degrees2dms", -2), " 12° 00' 00.00\" W ");
%!assert (angl2str (-12, "ew", "degrees2dms", 0), " 12° 00' 00\" W ");
%!assert (angl2str (-12, "ew", "degrees2dms", 1), " 12° 00' 00\" W ");
%!assert (angl2str (-12, "ew", "degrees2dms", 5), " 12° 00' 00\" W ");
%!assert (angl2str (-12, "ns", "radians", -5), " 12.00000 R S ");
%!assert (angl2str (-12, "ns", "radians", -2), " 12.00 R S ");
%!assert (angl2str (-12, "ns", "radians", 0), " 12 R S ");
%!assert (angl2str (-12, "ns", "radians", 1), " 10 R S ");
%!assert (angl2str (-12, "ns", "radians", 5), " 0 R S ");
%!assert (angl2str (-12, "ns", "degrees", -5), " 12.00000° S ");
%!assert (angl2str (-12, "ns", "degrees", -2), " 12.00° S ");
%!assert (angl2str (-12, "ns", "degrees", 0), " 12° S ");
%!assert (angl2str (-12, "ns", "degrees", 1), " 10° S ");
%!assert (angl2str (-12, "ns", "degrees", 5), " 0° S ");
%!assert (angl2str (-12, "ns", "degrees2dm", -5), " 12° 00.00000' S ");
%!assert (angl2str (-12, "ns", "degrees2dm", -2), " 12° 00.00' S ");
%!assert (angl2str (-12, "ns", "degrees2dm", 0), " 12° 00' S ");
%!assert (angl2str (-12, "ns", "degrees2dm", 1), " 12° 00' S ");
%!assert (angl2str (-12, "ns", "degrees2dm", 5), " 12° 00' S ");
%!assert (angl2str (-12, "ns", "degrees2dms", -5), " 12° 00' 00.00000\" S ");
%!assert (angl2str (-12, "ns", "degrees2dms", -2), " 12° 00' 00.00\" S ");
%!assert (angl2str (-12, "ns", "degrees2dms", 0), " 12° 00' 00\" S ");
%!assert (angl2str (-12, "ns", "degrees2dms", 1), " 12° 00' 00\" S ");
%!assert (angl2str (-12, "ns", "degrees2dms", 5), " 12° 00' 00\" S ");
%!assert (angl2str (-12, "pm", "radians", -5), " -12.00000 R ");
%!assert (angl2str (-12, "pm", "radians", -2), " -12.00 R ");
%!assert (angl2str (-12, "pm", "radians", 0), " -12 R ");
%!assert (angl2str (-12, "pm", "radians", 1), " -10 R ");
%!assert (angl2str (-12, "pm", "radians", 5), " -0 R ");
%!assert (angl2str (-12, "pm", "degrees", -5), " -12.00000° ");
%!assert (angl2str (-12, "pm", "degrees", -2), " -12.00° ");
%!assert (angl2str (-12, "pm", "degrees", 0), " -12° ");
%!assert (angl2str (-12, "pm", "degrees", 1), " -10° ");
%!assert (angl2str (-12, "pm", "degrees", 5), " -0° ");
%!assert (angl2str (-12, "pm", "degrees2dm", -5), " -12° 00.00000' ");
%!assert (angl2str (-12, "pm", "degrees2dm", -2), " -12° 00.00' ");
%!assert (angl2str (-12, "pm", "degrees2dm", 0), " -12° 00' ");
%!assert (angl2str (-12, "pm", "degrees2dm", 1), " -12° 00' ");
%!assert (angl2str (-12, "pm", "degrees2dm", 5), " -12° 00' ");
%!assert (angl2str (-12, "pm", "degrees2dms", -5), " -12° 00' 00.00000\" ");
%!assert (angl2str (-12, "pm", "degrees2dms", -2), " -12° 00' 00.00\" ");
%!assert (angl2str (-12, "pm", "degrees2dms", 0), " -12° 00' 00\" ");
%!assert (angl2str (-12, "pm", "degrees2dms", 1), " -12° 00' 00\" ");
%!assert (angl2str (-12, "pm", "degrees2dms", 5), " -12° 00' 00\" ");
%!assert (angl2str (-12, "none", "radians", -5), " -12.00000 R ");
%!assert (angl2str (-12, "none", "radians", -2), " -12.00 R ");
%!assert (angl2str (-12, "none", "radians", 0), " -12 R ");
%!assert (angl2str (-12, "none", "radians", 1), " -10 R ");
%!assert (angl2str (-12, "none", "radians", 5), " -0 R ");
%!assert (angl2str (-12, "none", "degrees", -5), " -12.00000° ");
%!assert (angl2str (-12, "none", "degrees", -2), " -12.00° ");
%!assert (angl2str (-12, "none", "degrees", 0), " -12° ");
%!assert (angl2str (-12, "none", "degrees", 1), " -10° ");
%!assert (angl2str (-12, "none", "degrees", 5), " -0° ");
%!assert (angl2str (-12, "none", "degrees2dm", -5), " -12° 00.00000' ");
%!assert (angl2str (-12, "none", "degrees2dm", -2), " -12° 00.00' ");
%!assert (angl2str (-12, "none", "degrees2dm", 0), " -12° 00' ");
%!assert (angl2str (-12, "none", "degrees2dm", 1), " -12° 00' ");
%!assert (angl2str (-12, "none", "degrees2dm", 5), " -12° 00' ");
%!assert (angl2str (-12, "none", "degrees2dms", -5), " -12° 00' 00.00000\" ");
%!assert (angl2str (-12, "none", "degrees2dms", -2), " -12° 00' 00.00\" ");
%!assert (angl2str (-12, "none", "degrees2dms", 0), " -12° 00' 00\" ");
%!assert (angl2str (-12, "none", "degrees2dms", 1), " -12° 00' 00\" ");
%!assert (angl2str (-12, "none", "degrees2dms", 5), " -12° 00' 00\" ");
%!assert (angl2str (-5.3333, "ew", "radians", -5), " 5.33330 R W ");
%!assert (angl2str (-5.3333, "ew", "radians", -2), " 5.33 R W ");
%!assert (angl2str (-5.3333, "ew", "radians", 0), " 5 R W ");
%!assert (angl2str (-5.3333, "ew", "radians", 1), " 10 R W ");
%!assert (angl2str (-5.3333, "ew", "radians", 5), " 0 R W ");
%!assert (angl2str (-5.3333, "ew", "degrees", -5), " 5.33330° W ");
%!assert (angl2str (-5.3333, "ew", "degrees", -2), " 5.33° W ");
%!assert (angl2str (-5.3333, "ew", "degrees", 0), " 5° W ");
%!assert (angl2str (-5.3333, "ew", "degrees", 1), " 10° W ");
%!assert (angl2str (-5.3333, "ew", "degrees", 5), " 0° W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dm", -5), " 5° 19.99800' W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dm", -2), " 5° 20.00' W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dm", 0), " 5° 20' W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dm", 1), " 5° 20' W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dm", 5), " 5° 00' W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dms", -5), " 5° 19' 59.88000\" W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dms", -2), " 5° 19' 59.88\" W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dms", 0), " 5° 20' 00\" W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dms", 1), " 5° 20' 00\" W ");
%!assert (angl2str (-5.3333, "ew", "degrees2dms", 5), " 5° 20' 00\" W ");
%!assert (angl2str (-5.3333, "ns", "radians", -5), " 5.33330 R S ");
%!assert (angl2str (-5.3333, "ns", "radians", -2), " 5.33 R S ");
%!assert (angl2str (-5.3333, "ns", "radians", 0), " 5 R S ");
%!assert (angl2str (-5.3333, "ns", "radians", 1), " 10 R S ");
%!assert (angl2str (-5.3333, "ns", "radians", 5), " 0 R S ");
%!assert (angl2str (-5.3333, "ns", "degrees", -5), " 5.33330° S ");
%!assert (angl2str (-5.3333, "ns", "degrees", -2), " 5.33° S ");
%!assert (angl2str (-5.3333, "ns", "degrees", 0), " 5° S ");
%!assert (angl2str (-5.3333, "ns", "degrees", 1), " 10° S ");
%!assert (angl2str (-5.3333, "ns", "degrees", 5), " 0° S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dm", -5), " 5° 19.99800' S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dm", -2), " 5° 20.00' S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dm", 0), " 5° 20' S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dm", 1), " 5° 20' S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dm", 5), " 5° 00' S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dms", -5), " 5° 19' 59.88000\" S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dms", -2), " 5° 19' 59.88\" S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dms", 0), " 5° 20' 00\" S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dms", 1), " 5° 20' 00\" S ");
%!assert (angl2str (-5.3333, "ns", "degrees2dms", 5), " 5° 20' 00\" S ");
%!assert (angl2str (-5.3333, "pm", "radians", -5), " -5.33330 R ");
%!assert (angl2str (-5.3333, "pm", "radians", -2), " -5.33 R ");
%!assert (angl2str (-5.3333, "pm", "radians", 0), " -5 R ");
%!assert (angl2str (-5.3333, "pm", "radians", 1), " -10 R ");
%!assert (angl2str (-5.3333, "pm", "radians", 5), " -0 R ");
%!assert (angl2str (-5.3333, "pm", "degrees", -5), " -5.33330° ");
%!assert (angl2str (-5.3333, "pm", "degrees", -2), " -5.33° ");
%!assert (angl2str (-5.3333, "pm", "degrees", 0), " -5° ");
%!assert (angl2str (-5.3333, "pm", "degrees", 1), " -10° ");
%!assert (angl2str (-5.3333, "pm", "degrees", 5), " -0° ");
%!assert (angl2str (-5.3333, "pm", "degrees2dm", -5), " -5° 19.99800' ");
%!assert (angl2str (-5.3333, "pm", "degrees2dm", -2), " -5° 20.00' ");
%!assert (angl2str (-5.3333, "pm", "degrees2dm", 0), " -5° 20' ");
%!assert (angl2str (-5.3333, "pm", "degrees2dm", 1), " -5° 20' ");
%!assert (angl2str (-5.3333, "pm", "degrees2dm", 5), " -5° 00' ");
%!assert (angl2str (-5.3333, "pm", "degrees2dms", -5), " -5° 19' 59.88000\" ");
%!assert (angl2str (-5.3333, "pm", "degrees2dms", -2), " -5° 19' 59.88\" ");
%!assert (angl2str (-5.3333, "pm", "degrees2dms", 0), " -5° 20' 00\" ");
%!assert (angl2str (-5.3333, "pm", "degrees2dms", 1), " -5° 20' 00\" ");
%!assert (angl2str (-5.3333, "pm", "degrees2dms", 5), " -5° 20' 00\" ");
%!assert (angl2str (-5.3333, "none", "radians", -5), " -5.33330 R ");
%!assert (angl2str (-5.3333, "none", "radians", -2), " -5.33 R ");
%!assert (angl2str (-5.3333, "none", "radians", 0), " -5 R ");
%!assert (angl2str (-5.3333, "none", "radians", 1), " -10 R ");
%!assert (angl2str (-5.3333, "none", "radians", 5), " -0 R ");
%!assert (angl2str (-5.3333, "none", "degrees", -5), " -5.33330° ");
%!assert (angl2str (-5.3333, "none", "degrees", -2), " -5.33° ");
%!assert (angl2str (-5.3333, "none", "degrees", 0), " -5° ");
%!assert (angl2str (-5.3333, "none", "degrees", 1), " -10° ");
%!assert (angl2str (-5.3333, "none", "degrees", 5), " -0° ");
%!assert (angl2str (-5.3333, "none", "degrees2dm", -5), " -5° 19.99800' ");
%!assert (angl2str (-5.3333, "none", "degrees2dm", -2), " -5° 20.00' ");
%!assert (angl2str (-5.3333, "none", "degrees2dm", 0), " -5° 20' ");
%!assert (angl2str (-5.3333, "none", "degrees2dm", 1), " -5° 20' ");
%!assert (angl2str (-5.3333, "none", "degrees2dm", 5), " -5° 00' ");
%!assert (angl2str (-5.3333, "none", "degrees2dms", -5), " -5° 19' 59.88000\" ");
%!assert (angl2str (-5.3333, "none", "degrees2dms", -2), " -5° 19' 59.88\" ");
%!assert (angl2str (-5.3333, "none", "degrees2dms", 0), " -5° 20' 00\" ");
%!assert (angl2str (-5.3333, "none", "degrees2dms", 1), " -5° 20' 00\" ");
%!assert (angl2str (-5.3333, "none", "degrees2dms", 5), " -5° 20' 00\" ");
%!assert (angl2str (0, "ew", "radians", -5), " 0.00000 R   ");
%!assert (angl2str (0, "ew", "radians", -2), " 0.00 R   ");
%!assert (angl2str (0, "ew", "radians", 0), " 0 R   ");
%!assert (angl2str (0, "ew", "radians", 1), " 0 R   ");
%!assert (angl2str (0, "ew", "radians", 5), " 0 R   ");
%!assert (angl2str (0, "ew", "degrees", -5), " 0.00000°   ");
%!assert (angl2str (0, "ew", "degrees", -2), " 0.00°   ");
%!assert (angl2str (0, "ew", "degrees", 0), " 0°   ");
%!assert (angl2str (0, "ew", "degrees", 1), " 0°   ");
%!assert (angl2str (0, "ew", "degrees", 5), " 0°   ");
%!assert (angl2str (0, "ew", "degrees2dm", -5), " 0° 00.00000'   ");
%!assert (angl2str (0, "ew", "degrees2dm", -2), " 0° 00.00'   ");
%!assert (angl2str (0, "ew", "degrees2dm", 0), " 0° 00'   ");
%!assert (angl2str (0, "ew", "degrees2dm", 1), " 0° 00'   ");
%!assert (angl2str (0, "ew", "degrees2dm", 5), " 0° 00'   ");
%!assert (angl2str (0, "ew", "degrees2dms", -5), " 0° 00' 00.00000\"   ");
%!assert (angl2str (0, "ew", "degrees2dms", -2), " 0° 00' 00.00\"   ");
%!assert (angl2str (0, "ew", "degrees2dms", 0), " 0° 00' 00\"   ");
%!assert (angl2str (0, "ew", "degrees2dms", 1), " 0° 00' 00\"   ");
%!assert (angl2str (0, "ew", "degrees2dms", 5), " 0° 00' 00\"   ");
%!assert (angl2str (0, "ns", "radians", -5), " 0.00000 R   ");
%!assert (angl2str (0, "ns", "radians", -2), " 0.00 R   ");
%!assert (angl2str (0, "ns", "radians", 0), " 0 R   ");
%!assert (angl2str (0, "ns", "radians", 1), " 0 R   ");
%!assert (angl2str (0, "ns", "radians", 5), " 0 R   ");
%!assert (angl2str (0, "ns", "degrees", -5), " 0.00000°   ");
%!assert (angl2str (0, "ns", "degrees", -2), " 0.00°   ");
%!assert (angl2str (0, "ns", "degrees", 0), " 0°   ");
%!assert (angl2str (0, "ns", "degrees", 1), " 0°   ");
%!assert (angl2str (0, "ns", "degrees", 5), " 0°   ");
%!assert (angl2str (0, "ns", "degrees2dm", -5), " 0° 00.00000'   ");
%!assert (angl2str (0, "ns", "degrees2dm", -2), " 0° 00.00'   ");
%!assert (angl2str (0, "ns", "degrees2dm", 0), " 0° 00'   ");
%!assert (angl2str (0, "ns", "degrees2dm", 1), " 0° 00'   ");
%!assert (angl2str (0, "ns", "degrees2dm", 5), " 0° 00'   ");
%!assert (angl2str (0, "ns", "degrees2dms", -5), " 0° 00' 00.00000\"   ");
%!assert (angl2str (0, "ns", "degrees2dms", -2), " 0° 00' 00.00\"   ");
%!assert (angl2str (0, "ns", "degrees2dms", 0), " 0° 00' 00\"   ");
%!assert (angl2str (0, "ns", "degrees2dms", 1), " 0° 00' 00\"   ");
%!assert (angl2str (0, "ns", "degrees2dms", 5), " 0° 00' 00\"   ");
%!assert (angl2str (0, "pm", "radians", -5), " 0.00000 R ");
%!assert (angl2str (0, "pm", "radians", -2), " 0.00 R ");
%!assert (angl2str (0, "pm", "radians", 0), " 0 R ");
%!assert (angl2str (0, "pm", "radians", 1), " 0 R ");
%!assert (angl2str (0, "pm", "radians", 5), " 0 R ");
%!assert (angl2str (0, "pm", "degrees", -5), " 0.00000° ");
%!assert (angl2str (0, "pm", "degrees", -2), " 0.00° ");
%!assert (angl2str (0, "pm", "degrees", 0), " 0° ");
%!assert (angl2str (0, "pm", "degrees", 1), " 0° ");
%!assert (angl2str (0, "pm", "degrees", 5), " 0° ");
%!assert (angl2str (0, "pm", "degrees2dm", -5), " 0° 00.00000' ");
%!assert (angl2str (0, "pm", "degrees2dm", -2), " 0° 00.00' ");
%!assert (angl2str (0, "pm", "degrees2dm", 0), " 0° 00' ");
%!assert (angl2str (0, "pm", "degrees2dm", 1), " 0° 00' ");
%!assert (angl2str (0, "pm", "degrees2dm", 5), " 0° 00' ");
%!assert (angl2str (0, "pm", "degrees2dms", -5), " 0° 00' 00.00000\" ");
%!assert (angl2str (0, "pm", "degrees2dms", -2), " 0° 00' 00.00\" ");
%!assert (angl2str (0, "pm", "degrees2dms", 0), " 0° 00' 00\" ");
%!assert (angl2str (0, "pm", "degrees2dms", 1), " 0° 00' 00\" ");
%!assert (angl2str (0, "pm", "degrees2dms", 5), " 0° 00' 00\" ");
%!assert (angl2str (0, "none", "radians", -5), " 0.00000 R ");
%!assert (angl2str (0, "none", "radians", -2), " 0.00 R ");
%!assert (angl2str (0, "none", "radians", 0), " 0 R ");
%!assert (angl2str (0, "none", "radians", 1), " 0 R ");
%!assert (angl2str (0, "none", "radians", 5), " 0 R ");
%!assert (angl2str (0, "none", "degrees", -5), " 0.00000° ");
%!assert (angl2str (0, "none", "degrees", -2), " 0.00° ");
%!assert (angl2str (0, "none", "degrees", 0), " 0° ");
%!assert (angl2str (0, "none", "degrees", 1), " 0° ");
%!assert (angl2str (0, "none", "degrees", 5), " 0° ");
%!assert (angl2str (0, "none", "degrees2dm", -5), " 0° 00.00000' ");
%!assert (angl2str (0, "none", "degrees2dm", -2), " 0° 00.00' ");
%!assert (angl2str (0, "none", "degrees2dm", 0), " 0° 00' ");
%!assert (angl2str (0, "none", "degrees2dm", 1), " 0° 00' ");
%!assert (angl2str (0, "none", "degrees2dm", 5), " 0° 00' ");
%!assert (angl2str (0, "none", "degrees2dms", -5), " 0° 00' 00.00000\" ");
%!assert (angl2str (0, "none", "degrees2dms", -2), " 0° 00' 00.00\" ");
%!assert (angl2str (0, "none", "degrees2dms", 0), " 0° 00' 00\" ");
%!assert (angl2str (0, "none", "degrees2dms", 1), " 0° 00' 00\" ");
%!assert (angl2str (0, "none", "degrees2dms", 5), " 0° 00' 00\" ");
%!assert (angl2str (1, "ew", "radians", -5), " 1.00000 R E ");
%!assert (angl2str (1, "ew", "radians", -2), " 1.00 R E ");
%!assert (angl2str (1, "ew", "radians", 0), " 1 R E ");
%!assert (angl2str (1, "ew", "radians", 1), " 0 R E ");
%!assert (angl2str (1, "ew", "radians", 5), " 0 R E ");
%!assert (angl2str (1, "ew", "degrees", -5), " 1.00000° E ");
%!assert (angl2str (1, "ew", "degrees", -2), " 1.00° E ");
%!assert (angl2str (1, "ew", "degrees", 0), " 1° E ");
%!assert (angl2str (1, "ew", "degrees", 1), " 0° E ");
%!assert (angl2str (1, "ew", "degrees", 5), " 0° E ");
%!assert (angl2str (1, "ew", "degrees2dm", -5), " 1° 00.00000' E ");
%!assert (angl2str (1, "ew", "degrees2dm", -2), " 1° 00.00' E ");
%!assert (angl2str (1, "ew", "degrees2dm", 0), " 1° 00' E ");
%!assert (angl2str (1, "ew", "degrees2dm", 1), " 1° 00' E ");
%!assert (angl2str (1, "ew", "degrees2dm", 5), " 1° 00' E ");
%!assert (angl2str (1, "ew", "degrees2dms", -5), " 1° 00' 00.00000\" E ");
%!assert (angl2str (1, "ew", "degrees2dms", -2), " 1° 00' 00.00\" E ");
%!assert (angl2str (1, "ew", "degrees2dms", 0), " 1° 00' 00\" E ");
%!assert (angl2str (1, "ew", "degrees2dms", 1), " 1° 00' 00\" E ");
%!assert (angl2str (1, "ew", "degrees2dms", 5), " 1° 00' 00\" E ");
%!assert (angl2str (1, "ns", "radians", -5), " 1.00000 R N ");
%!assert (angl2str (1, "ns", "radians", -2), " 1.00 R N ");
%!assert (angl2str (1, "ns", "radians", 0), " 1 R N ");
%!assert (angl2str (1, "ns", "radians", 1), " 0 R N ");
%!assert (angl2str (1, "ns", "radians", 5), " 0 R N ");
%!assert (angl2str (1, "ns", "degrees", -5), " 1.00000° N ");
%!assert (angl2str (1, "ns", "degrees", -2), " 1.00° N ");
%!assert (angl2str (1, "ns", "degrees", 0), " 1° N ");
%!assert (angl2str (1, "ns", "degrees", 1), " 0° N ");
%!assert (angl2str (1, "ns", "degrees", 5), " 0° N ");
%!assert (angl2str (1, "ns", "degrees2dm", -5), " 1° 00.00000' N ");
%!assert (angl2str (1, "ns", "degrees2dm", -2), " 1° 00.00' N ");
%!assert (angl2str (1, "ns", "degrees2dm", 0), " 1° 00' N ");
%!assert (angl2str (1, "ns", "degrees2dm", 1), " 1° 00' N ");
%!assert (angl2str (1, "ns", "degrees2dm", 5), " 1° 00' N ");
%!assert (angl2str (1, "ns", "degrees2dms", -5), " 1° 00' 00.00000\" N ");
%!assert (angl2str (1, "ns", "degrees2dms", -2), " 1° 00' 00.00\" N ");
%!assert (angl2str (1, "ns", "degrees2dms", 0), " 1° 00' 00\" N ");
%!assert (angl2str (1, "ns", "degrees2dms", 1), " 1° 00' 00\" N ");
%!assert (angl2str (1, "ns", "degrees2dms", 5), " 1° 00' 00\" N ");
%!assert (angl2str (1, "pm", "radians", -5), " +1.00000 R ");
%!assert (angl2str (1, "pm", "radians", -2), " +1.00 R ");
%!assert (angl2str (1, "pm", "radians", 0), " +1 R ");
%!assert (angl2str (1, "pm", "radians", 1), " +0 R ");
%!assert (angl2str (1, "pm", "radians", 5), " +0 R ");
%!assert (angl2str (1, "pm", "degrees", -5), " +1.00000° ");
%!assert (angl2str (1, "pm", "degrees", -2), " +1.00° ");
%!assert (angl2str (1, "pm", "degrees", 0), " +1° ");
%!assert (angl2str (1, "pm", "degrees", 1), " +0° ");
%!assert (angl2str (1, "pm", "degrees", 5), " +0° ");
%!assert (angl2str (1, "pm", "degrees2dm", -5), " +1° 00.00000' ");
%!assert (angl2str (1, "pm", "degrees2dm", -2), " +1° 00.00' ");
%!assert (angl2str (1, "pm", "degrees2dm", 0), " +1° 00' ");
%!assert (angl2str (1, "pm", "degrees2dm", 1), " +1° 00' ");
%!assert (angl2str (1, "pm", "degrees2dm", 5), " +1° 00' ");
%!assert (angl2str (1, "pm", "degrees2dms", -5), " +1° 00' 00.00000\" ");
%!assert (angl2str (1, "pm", "degrees2dms", -2), " +1° 00' 00.00\" ");
%!assert (angl2str (1, "pm", "degrees2dms", 0), " +1° 00' 00\" ");
%!assert (angl2str (1, "pm", "degrees2dms", 1), " +1° 00' 00\" ");
%!assert (angl2str (1, "pm", "degrees2dms", 5), " +1° 00' 00\" ");
%!assert (angl2str (1, "none", "radians", -5), " 1.00000 R ");
%!assert (angl2str (1, "none", "radians", -2), " 1.00 R ");
%!assert (angl2str (1, "none", "radians", 0), " 1 R ");
%!assert (angl2str (1, "none", "radians", 1), " 0 R ");
%!assert (angl2str (1, "none", "radians", 5), " 0 R ");
%!assert (angl2str (1, "none", "degrees", -5), " 1.00000° ");
%!assert (angl2str (1, "none", "degrees", -2), " 1.00° ");
%!assert (angl2str (1, "none", "degrees", 0), " 1° ");
%!assert (angl2str (1, "none", "degrees", 1), " 0° ");
%!assert (angl2str (1, "none", "degrees", 5), " 0° ");
%!assert (angl2str (1, "none", "degrees2dm", -5), " 1° 00.00000' ");
%!assert (angl2str (1, "none", "degrees2dm", -2), " 1° 00.00' ");
%!assert (angl2str (1, "none", "degrees2dm", 0), " 1° 00' ");
%!assert (angl2str (1, "none", "degrees2dm", 1), " 1° 00' ");
%!assert (angl2str (1, "none", "degrees2dm", 5), " 1° 00' ");
%!assert (angl2str (1, "none", "degrees2dms", -5), " 1° 00' 00.00000\" ");
%!assert (angl2str (1, "none", "degrees2dms", -2), " 1° 00' 00.00\" ");
%!assert (angl2str (1, "none", "degrees2dms", 0), " 1° 00' 00\" ");
%!assert (angl2str (1, "none", "degrees2dms", 1), " 1° 00' 00\" ");
%!assert (angl2str (1, "none", "degrees2dms", 5), " 1° 00' 00\" ");
%!assert (angl2str (27, "ew", "radians", -5), " 27.00000 R E ");
%!assert (angl2str (27, "ew", "radians", -2), " 27.00 R E ");
%!assert (angl2str (27, "ew", "radians", 0), " 27 R E ");
%!assert (angl2str (27, "ew", "radians", 1), " 30 R E ");
%!assert (angl2str (27, "ew", "radians", 5), " 0 R E ");
%!assert (angl2str (27, "ew", "degrees", -5), " 27.00000° E ");
%!assert (angl2str (27, "ew", "degrees", -2), " 27.00° E ");
%!assert (angl2str (27, "ew", "degrees", 0), " 27° E ");
%!assert (angl2str (27, "ew", "degrees", 1), " 30° E ");
%!assert (angl2str (27, "ew", "degrees", 5), " 0° E ");
%!assert (angl2str (27, "ew", "degrees2dm", -5), " 27° 00.00000' E ");
%!assert (angl2str (27, "ew", "degrees2dm", -2), " 27° 00.00' E ");
%!assert (angl2str (27, "ew", "degrees2dm", 0), " 27° 00' E ");
%!assert (angl2str (27, "ew", "degrees2dm", 1), " 27° 00' E ");
%!assert (angl2str (27, "ew", "degrees2dm", 5), " 27° 00' E ");
%!assert (angl2str (27, "ew", "degrees2dms", -5), " 27° 00' 00.00000\" E ");
%!assert (angl2str (27, "ew", "degrees2dms", -2), " 27° 00' 00.00\" E ");
%!assert (angl2str (27, "ew", "degrees2dms", 0), " 27° 00' 00\" E ");
%!assert (angl2str (27, "ew", "degrees2dms", 1), " 27° 00' 00\" E ");
%!assert (angl2str (27, "ew", "degrees2dms", 5), " 27° 00' 00\" E ");
%!assert (angl2str (27, "ns", "radians", -5), " 27.00000 R N ");
%!assert (angl2str (27, "ns", "radians", -2), " 27.00 R N ");
%!assert (angl2str (27, "ns", "radians", 0), " 27 R N ");
%!assert (angl2str (27, "ns", "radians", 1), " 30 R N ");
%!assert (angl2str (27, "ns", "radians", 5), " 0 R N ");
%!assert (angl2str (27, "ns", "degrees", -5), " 27.00000° N ");
%!assert (angl2str (27, "ns", "degrees", -2), " 27.00° N ");
%!assert (angl2str (27, "ns", "degrees", 0), " 27° N ");
%!assert (angl2str (27, "ns", "degrees", 1), " 30° N ");
%!assert (angl2str (27, "ns", "degrees", 5), " 0° N ");
%!assert (angl2str (27, "ns", "degrees2dm", -5), " 27° 00.00000' N ");
%!assert (angl2str (27, "ns", "degrees2dm", -2), " 27° 00.00' N ");
%!assert (angl2str (27, "ns", "degrees2dm", 0), " 27° 00' N ");
%!assert (angl2str (27, "ns", "degrees2dm", 1), " 27° 00' N ");
%!assert (angl2str (27, "ns", "degrees2dm", 5), " 27° 00' N ");
%!assert (angl2str (27, "ns", "degrees2dms", -5), " 27° 00' 00.00000\" N ");
%!assert (angl2str (27, "ns", "degrees2dms", -2), " 27° 00' 00.00\" N ");
%!assert (angl2str (27, "ns", "degrees2dms", 0), " 27° 00' 00\" N ");
%!assert (angl2str (27, "ns", "degrees2dms", 1), " 27° 00' 00\" N ");
%!assert (angl2str (27, "ns", "degrees2dms", 5), " 27° 00' 00\" N ");
%!assert (angl2str (27, "pm", "radians", -5), " +27.00000 R ");
%!assert (angl2str (27, "pm", "radians", -2), " +27.00 R ");
%!assert (angl2str (27, "pm", "radians", 0), " +27 R ");
%!assert (angl2str (27, "pm", "radians", 1), " +30 R ");
%!assert (angl2str (27, "pm", "radians", 5), " +0 R ");
%!assert (angl2str (27, "pm", "degrees", -5), " +27.00000° ");
%!assert (angl2str (27, "pm", "degrees", -2), " +27.00° ");
%!assert (angl2str (27, "pm", "degrees", 0), " +27° ");
%!assert (angl2str (27, "pm", "degrees", 1), " +30° ");
%!assert (angl2str (27, "pm", "degrees", 5), " +0° ");
%!assert (angl2str (27, "pm", "degrees2dm", -5), " +27° 00.00000' ");
%!assert (angl2str (27, "pm", "degrees2dm", -2), " +27° 00.00' ");
%!assert (angl2str (27, "pm", "degrees2dm", 0), " +27° 00' ");
%!assert (angl2str (27, "pm", "degrees2dm", 1), " +27° 00' ");
%!assert (angl2str (27, "pm", "degrees2dm", 5), " +27° 00' ");
%!assert (angl2str (27, "pm", "degrees2dms", -5), " +27° 00' 00.00000\" ");
%!assert (angl2str (27, "pm", "degrees2dms", -2), " +27° 00' 00.00\" ");
%!assert (angl2str (27, "pm", "degrees2dms", 0), " +27° 00' 00\" ");
%!assert (angl2str (27, "pm", "degrees2dms", 1), " +27° 00' 00\" ");
%!assert (angl2str (27, "pm", "degrees2dms", 5), " +27° 00' 00\" ");
%!assert (angl2str (27, "none", "radians", -5), " 27.00000 R ");
%!assert (angl2str (27, "none", "radians", -2), " 27.00 R ");
%!assert (angl2str (27, "none", "radians", 0), " 27 R ");
%!assert (angl2str (27, "none", "radians", 1), " 30 R ");
%!assert (angl2str (27, "none", "radians", 5), " 0 R ");
%!assert (angl2str (27, "none", "degrees", -5), " 27.00000° ");
%!assert (angl2str (27, "none", "degrees", -2), " 27.00° ");
%!assert (angl2str (27, "none", "degrees", 0), " 27° ");
%!assert (angl2str (27, "none", "degrees", 1), " 30° ");
%!assert (angl2str (27, "none", "degrees", 5), " 0° ");
%!assert (angl2str (27, "none", "degrees2dm", -5), " 27° 00.00000' ");
%!assert (angl2str (27, "none", "degrees2dm", -2), " 27° 00.00' ");
%!assert (angl2str (27, "none", "degrees2dm", 0), " 27° 00' ");
%!assert (angl2str (27, "none", "degrees2dm", 1), " 27° 00' ");
%!assert (angl2str (27, "none", "degrees2dm", 5), " 27° 00' ");
%!assert (angl2str (27, "none", "degrees2dms", -5), " 27° 00' 00.00000\" ");
%!assert (angl2str (27, "none", "degrees2dms", -2), " 27° 00' 00.00\" ");
%!assert (angl2str (27, "none", "degrees2dms", 0), " 27° 00' 00\" ");
%!assert (angl2str (27, "none", "degrees2dms", 1), " 27° 00' 00\" ");
%!assert (angl2str (27, "none", "degrees2dms", 5), " 27° 00' 00\" ");
%!assert (angl2str (77.7778, "ew", "radians", -5), " 77.77777 R E ");
%!assert (angl2str (77.7778, "ew", "radians", -2), " 77.78 R E ");
%!assert (angl2str (77.7778, "ew", "radians", 0), " 78 R E ");
%!assert (angl2str (77.7778, "ew", "radians", 1), " 80 R E ");
%!assert (angl2str (77.7778, "ew", "radians", 5), " 0 R E ");
%!assert (angl2str (77.7778, "ew", "degrees", -5), " 77.77777° E ");
%!assert (angl2str (77.7778, "ew", "degrees", -2), " 77.78° E ");
%!assert (angl2str (77.7778, "ew", "degrees", 0), " 78° E ");
%!assert (angl2str (77.7778, "ew", "degrees", 1), " 80° E ");
%!assert (angl2str (77.7778, "ew", "degrees", 5), " 0° E ");
%!assert (angl2str (77.7778, "ew", "degrees2dm", -5), " 77° 46.66620' E ");
%!assert (angl2str (77.7778, "ew", "degrees2dm", -2), " 77° 46.67' E ");
%!assert (angl2str (77.7778, "ew", "degrees2dm", 0), " 77° 47' E ");
%!assert (angl2str (77.7778, "ew", "degrees2dm", 1), " 77° 50' E ");
%!assert (angl2str (77.7778, "ew", "degrees2dm", 5), " 78° 00' E ");
%!assert (angl2str (77.7778, "ew", "degrees2dms", -5), " 77° 46' 39.97200\" E ");
%!assert (angl2str (77.7778, "ew", "degrees2dms", -2), " 77° 46' 39.97\" E ");
%!assert (angl2str (77.7778, "ew", "degrees2dms", 0), " 77° 46' 40\" E ");
%!assert (angl2str (77.7778, "ew", "degrees2dms", 1), " 77° 46' 40\" E ");
%!assert (angl2str (77.7778, "ew", "degrees2dms", 5), " 77° 47' 00\" E ");
%!assert (angl2str (77.7778, "ns", "radians", -5), " 77.77777 R N ");
%!assert (angl2str (77.7778, "ns", "radians", -2), " 77.78 R N ");
%!assert (angl2str (77.7778, "ns", "radians", 0), " 78 R N ");
%!assert (angl2str (77.7778, "ns", "radians", 1), " 80 R N ");
%!assert (angl2str (77.7778, "ns", "radians", 5), " 0 R N ");
%!assert (angl2str (77.7778, "ns", "degrees", -5), " 77.77777° N ");
%!assert (angl2str (77.7778, "ns", "degrees", -2), " 77.78° N ");
%!assert (angl2str (77.7778, "ns", "degrees", 0), " 78° N ");
%!assert (angl2str (77.7778, "ns", "degrees", 1), " 80° N ");
%!assert (angl2str (77.7778, "ns", "degrees", 5), " 0° N ");
%!assert (angl2str (77.7778, "ns", "degrees2dm", -5), " 77° 46.66620' N ");
%!assert (angl2str (77.7778, "ns", "degrees2dm", -2), " 77° 46.67' N ");
%!assert (angl2str (77.7778, "ns", "degrees2dm", 0), " 77° 47' N ");
%!assert (angl2str (77.7778, "ns", "degrees2dm", 1), " 77° 50' N ");
%!assert (angl2str (77.7778, "ns", "degrees2dm", 5), " 78° 00' N ");
%!assert (angl2str (77.7778, "ns", "degrees2dms", -5), " 77° 46' 39.97200\" N ");
%!assert (angl2str (77.7778, "ns", "degrees2dms", -2), " 77° 46' 39.97\" N ");
%!assert (angl2str (77.7778, "ns", "degrees2dms", 0), " 77° 46' 40\" N ");
%!assert (angl2str (77.7778, "ns", "degrees2dms", 1), " 77° 46' 40\" N ");
%!assert (angl2str (77.7778, "ns", "degrees2dms", 5), " 77° 47' 00\" N ");
%!assert (angl2str (77.7778, "pm", "radians", -5), " +77.77777 R ");
%!assert (angl2str (77.7778, "pm", "radians", -2), " +77.78 R ");
%!assert (angl2str (77.7778, "pm", "radians", 0), " +78 R ");
%!assert (angl2str (77.7778, "pm", "radians", 1), " +80 R ");
%!assert (angl2str (77.7778, "pm", "radians", 5), " +0 R ");
%!assert (angl2str (77.7778, "pm", "degrees", -5), " +77.77777° ");
%!assert (angl2str (77.7778, "pm", "degrees", -2), " +77.78° ");
%!assert (angl2str (77.7778, "pm", "degrees", 0), " +78° ");
%!assert (angl2str (77.7778, "pm", "degrees", 1), " +80° ");
%!assert (angl2str (77.7778, "pm", "degrees", 5), " +0° ");
%!assert (angl2str (77.7778, "pm", "degrees2dm", -5), " +77° 46.66620' ");
%!assert (angl2str (77.7778, "pm", "degrees2dm", -2), " +77° 46.67' ");
%!assert (angl2str (77.7778, "pm", "degrees2dm", 0), " +77° 47' ");
%!assert (angl2str (77.7778, "pm", "degrees2dm", 1), " +77° 50' ");
%!assert (angl2str (77.7778, "pm", "degrees2dm", 5), " +78° 00' ");
%!assert (angl2str (77.7778, "pm", "degrees2dms", -5), " +77° 46' 39.97200\" ");
%!assert (angl2str (77.7778, "pm", "degrees2dms", -2), " +77° 46' 39.97\" ");
%!assert (angl2str (77.7778, "pm", "degrees2dms", 0), " +77° 46' 40\" ");
%!assert (angl2str (77.7778, "pm", "degrees2dms", 1), " +77° 46' 40\" ");
%!assert (angl2str (77.7778, "pm", "degrees2dms", 5), " +77° 47' 00\" ");
%!assert (angl2str (77.7778, "none", "radians", -5), " 77.77777 R ");
%!assert (angl2str (77.7778, "none", "radians", -2), " 77.78 R ");
%!assert (angl2str (77.7778, "none", "radians", 0), " 78 R ");
%!assert (angl2str (77.7778, "none", "radians", 1), " 80 R ");
%!assert (angl2str (77.7778, "none", "radians", 5), " 0 R ");
%!assert (angl2str (77.7778, "none", "degrees", -5), " 77.77777° ");
%!assert (angl2str (77.7778, "none", "degrees", -2), " 77.78° ");
%!assert (angl2str (77.7778, "none", "degrees", 0), " 78° ");
%!assert (angl2str (77.7778, "none", "degrees", 1), " 80° ");
%!assert (angl2str (77.7778, "none", "degrees", 5), " 0° ");
%!assert (angl2str (77.7778, "none", "degrees2dm", -5), " 77° 46.66620' ");
%!assert (angl2str (77.7778, "none", "degrees2dm", -2), " 77° 46.67' ");
%!assert (angl2str (77.7778, "none", "degrees2dm", 0), " 77° 47' ");
%!assert (angl2str (77.7778, "none", "degrees2dm", 1), " 77° 50' ");
%!assert (angl2str (77.7778, "none", "degrees2dm", 5), " 78° 00' ");
%!assert (angl2str (77.7778, "none", "degrees2dms", -5), " 77° 46' 39.97200\" ");
%!assert (angl2str (77.7778, "none", "degrees2dms", -2), " 77° 46' 39.97\" ");
%!assert (angl2str (77.7778, "none", "degrees2dms", 0), " 77° 46' 40\" ");
%!assert (angl2str (77.7778, "none", "degrees2dms", 1), " 77° 46' 40\" ");
%!assert (angl2str (77.7778, "none", "degrees2dms", 5), " 77° 47' 00\" ");
%!assert (angl2str (-12), "-12°   ");
%!assert (angl2str (-5.333333333333), "-12°   ");
%!assert (angl2str (0), "0°   ");
%!assert (angl2str (1), "1°   ");
%!assert (angl2str (27), "27°   ");
%!assert (angl2str (77.77777777), "77°   ");
%!assert (angl2str (40), "40°   ");
%!assert (angl2str (-12, "ew"), "12° w");
%!assert (angl2str (27, "ew"), "27° e");
%!assert (angl2str (-12, "ns"), "12° s");
%!assert (angl2str (27, "ns"), "27° n");
%!assert (angl2str(0, "pm"), " 0° + ");
%!assert (angl2str(-12, "pm"), "12° - ");