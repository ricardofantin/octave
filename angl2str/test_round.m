% test to be run in MATLAB
a = [-5090.543 -100 -3 0 1.11111 8.888888];
b = [-13i -7i 0 1i 2i 9.99999999i];
N = [-10 -5 -1 0 1 2 7];
T = {'decimals';'significant'};
F = fopen('assert_round.m', 'w')
for ti = 1:length(T)
  for ni = 1:length(N)
    print_assert(a, N(ni), cell2mat(T(ti)), F);
    print_assert(b, N(ni), cell2mat(T(ti)), F);
    print_assert(a+b, N(ni), cell2mat(T(ti)), F);
    print_assert(single(a), N(ni), cell2mat(T(ti)), F);
    print_assert(single(b), N(ni), cell2mat(T(ti)), F);
    print_assert(single(a+b), N(ni), cell2mat(T(ti)), F);
    print_assert(a.*i, N(ni), cell2mat(T(ti)), F);
    print_assert(b.*i, N(ni), cell2mat(T(ti)), F);
  end
end

function [] = print_assert(X, N, T, F)
  result = num2str(round(X, N, T));
  arguments = ['[' num2str(X) '], ' num2str(N) ', "' T '"'];
  str = ['%!assert (round (', arguments ,'), [', result, ']);'];
  fwrite(F, str);
end