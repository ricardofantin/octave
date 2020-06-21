% script to compare to Matlab results. Just random inputs and after some error inputs.
a = [-12;-5.3333;0;1;27;77.77777];
s = {'ew'; 'ns'; 'pm'; 'none'};
u = {'radians'; 'degrees'; 'degrees2dm'; 'degrees2dms'};
n = [-5; -2; 0; 1; 5];
for i = 1:length (a)
  for j = 1:length (s)
    for k = 1:length (u)
      for l = 1:length (n)
        {a(i); cell2mat(s(j)); cell2mat(u(k)); n(l);
        angl2str(a(i), cell2mat(s(j)), cell2mat(u(k)), n(l))}
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
angl2str(1, 'SIGN_NOTATION_UNKNOWN')
angl2str(1, 'none', 'UNIT_UNKNOWN')
angl2str(1, 'none', 'degrees', 'string_instead_of_number')
