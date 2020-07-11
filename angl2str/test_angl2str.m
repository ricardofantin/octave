% script to compare to Matlab results. Just random inputs and after some error inputs.
a = [-12;-5.3333;0;1;27;77.77777];
s = {'ew'; 'ns'; 'pm'; 'none'};
u = {'radians'; 'degrees'; 'degrees2dm'; 'degrees2dms'};
n = [-5; -2; 0; 1; 5];
for i = 1:length (a)
  for j = 1:length (s)
    for k = 1:length (u)
      for l = 1:length (n)
        print2test(a(i), cell2mat(s(j)), cell2mat(u(k)), n(l))
      end
    end
  end
end
% angles over 180 and 360 in latitude and longitude
angl2str([-181; 181; -361; 361])
angl2str([-181; 181; -361; 361], 'ew')
angl2str([-181; 181; -361; 361], 'ns')
% unexpected inputs types:
angl2str('string_instead_of_number')
angl2str([1 2;3 4]);
angl2str(1, 'SIGN_NOTATION_UNKNOWN')
angl2str(1, 'none', 'UNIT_UNKNOWN')
angl2str(1, 'none', 'degrees', 'string_instead_of_number')

function [string] = print2test(input1, input2, input3, input4)
  if nargin == 1
    arguments = num2str(input1);
    result = angl2str(input1);
  elseif nargin == 2
    arguments = [num2str(input1) ', "' num2str(input2) '"'];
    result = angl2str(input1, input2);
  elseif nargin == 3
    arguments = [num2str(input1) ', "' num2str(input2) '", "' num2str(input3) '"'];
    result = angl2str(input1, input2, input3);
  elseif nargin == 4
    arguments = [num2str(input1) ', "' num2str(input2) '", "' num2str(input3) '", ' num2str(input4)];
    result = angl2str(input1, input2, input3, input4);
  end
  string = ['%!assert (angl2str (', arguments ,'), "', result, '");'];
end