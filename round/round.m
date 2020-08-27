function [num] = round (X, N = 0, type = "decimals")
  if (strcmp (type, "decimals") == 0 && strcmp (type, "significant") == 0)
    error (["round.m: Error, type should be \"decimals\" or \"significant\". Received " type " ."]);
    print_usage ();
  elseif (isnumeric (N) == 0)
    str = num2str (N);
    error (["round.m: Error, second argument N should be an integer. Received " str " ."]);
    print_usage ();
  elseif (strcmp (type, "significant") && N <= 0)
    error (["round.m: Error, N should be equal or greater than 1 for \"significant\" type. Received " num2str (N) " as N."]);
  endif
  
  if (N == 0 && strcmp (type, "decimals"))
    num = floor (X + 0.5 + 0.5i); # should be std::round
    return;
  endif
  
  if (strcmp (type, "decimals"))
    multiplier = 10 .** (N);
    num = (floor ((X .* multiplier) + 0.5 + 0.5i)) ./ multiplier;
  else # type is significant
    # first need to discover the number of digits before point
    sig = floor (log10 (X));
    multiplier = 10 .** (sig + 1 - N);
    num = (floor ((X ./ multiplier) + 0.5)) .* multiplier;
  endif
endfunction

# test("round", "normal", "result.txt")
%!assert (round ([-5090.543           -100             -3              0        1.11111       8.888888], -10, "decimals"), [0  0  0  0  0  0]);
%!assert (round ([0-13i                       0-7i                       0+0i                       0+1i                       0+2i                      0+10i], -10, "decimals"), [0  0  0  0  0  0]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                   8.888888+10i], -10, "decimals"), [0  0  0  0  0  0]);
%!assert (round ([-5090.543           -100             -3              0        1.11111      8.8888884], -10, "decimals"), [0  0  0  0  0  0]);
%!assert (round ([0-13i     0-7i     0+0i     0+1i     0+2i    0+10i], -10, "decimals"), [0  0  0  0  0  0]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                  8.8888884+10i], -10, "decimals"), [0  0  0  0  0  0]);
%!assert (round ([0-5090.543i                         0-100i                           0-3i                           0+0i                     0+1.11111i                    0+8.888888i], -10, "decimals"), [0  0  0  0  0  0]);
%!assert (round ([13            7            0           -1           -2          -10], -10, "decimals"), [0  0  0  0  0  0]);
%!assert (round ([-5090.543           -100             -3              0        1.11111       8.888888], -5, "decimals"), [0  0  0  0  0  0]);
%!assert (round ([0-13i                       0-7i                       0+0i                       0+1i                       0+2i                      0+10i], -5, "decimals"), [0  0  0  0  0  0]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                   8.888888+10i], -5, "decimals"), [0  0  0  0  0  0]);
%!assert (round ([-5090.543           -100             -3              0        1.11111      8.8888884], -5, "decimals"), [0  0  0  0  0  0]);
%!assert (round ([0-13i     0-7i     0+0i     0+1i     0+2i    0+10i], -5, "decimals"), [0  0  0  0  0  0]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                  8.8888884+10i], -5, "decimals"), [0  0  0  0  0  0]);
%!assert (round ([0-5090.543i                         0-100i                           0-3i                           0+0i                     0+1.11111i                    0+8.888888i], -5, "decimals"), [0  0  0  0  0  0]);
%!assert (round ([13            7            0           -1           -2          -10], -5, "decimals"), [0  0  0  0  0  0]);
%!assert (round ([-5090.543           -100             -3              0        1.11111       8.888888], -1, "decimals"), [-5090  -100     0     0     0    10]);
%!assert (round ([0-13i                       0-7i                       0+0i                       0+1i                       0+2i                      0+10i], -1, "decimals"), [0-10i    0-10i     0+0i     0+0i     0+0i    0+10i]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                   8.888888+10i], -1, "decimals"), [-5090-10i     -100-10i         0+0i         0+0i         0+0i       10+10i]);
%!assert (round ([-5090.543           -100             -3              0        1.11111      8.8888884], -1, "decimals"), [-5090  -100     0     0     0    10]);
%!assert (round ([0-13i     0-7i     0+0i     0+1i     0+2i    0+10i], -1, "decimals"), [0-10i    0-10i     0+0i     0+0i     0+0i    0+10i]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                  8.8888884+10i], -1, "decimals"), [-5090-10i     -100-10i         0+0i         0+0i         0+0i       10+10i]);
%!assert (round ([0-5090.543i                         0-100i                           0-3i                           0+0i                     0+1.11111i                    0+8.888888i], -1, "decimals"), [0-5090i       0-100i         0+0i         0+0i         0+0i        0+10i]);
%!assert (round ([13            7            0           -1           -2          -10], -1, "decimals"), [10  10   0   0   0 -10]);
%!assert (round ([-5090.543           -100             -3              0        1.11111       8.888888], 0, "decimals"), [-5091  -100    -3     0     1     9]);
%!assert (round ([0-13i                       0-7i                       0+0i                       0+1i                       0+2i                      0+10i], 0, "decimals"), [0-13i     0-7i     0+0i     0+1i     0+2i    0+10i]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                   8.888888+10i], 0, "decimals"), [-5091-13i      -100-7i        -3+0i         0+1i         1+2i        9+10i]);
%!assert (round ([-5090.543           -100             -3              0        1.11111      8.8888884], 0, "decimals"), [-5091  -100    -3     0     1     9]);
%!assert (round ([0-13i     0-7i     0+0i     0+1i     0+2i    0+10i], 0, "decimals"), [0-13i     0-7i     0+0i     0+1i     0+2i    0+10i]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                  8.8888884+10i], 0, "decimals"), [-5091-13i      -100-7i        -3+0i         0+1i         1+2i        9+10i]);
%!assert (round ([0-5090.543i                         0-100i                           0-3i                           0+0i                     0+1.11111i                    0+8.888888i], 0, "decimals"), [0-5091i       0-100i         0-3i         0+0i         0+1i         0+9i]);
%!assert (round ([13            7            0           -1           -2          -10], 0, "decimals"), [13   7   0  -1  -2 -10]);
%!assert (round ([-5090.543           -100             -3              0        1.11111       8.888888], 1, "decimals"), [-5090.5           -100             -3              0            1.1            8.9]);
%!assert (round ([0-13i                       0-7i                       0+0i                       0+1i                       0+2i                      0+10i], 1, "decimals"), [0-13i     0-7i     0+0i     0+1i     0+2i    0+10i]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                   8.888888+10i], 1, "decimals"), [-5090.5-13i                        -100-7i                          -3+0i                           0+1i                         1.1+2i                        8.9+10i]);
%!assert (round ([-5090.543           -100             -3              0        1.11111      8.8888884], 1, "decimals"), [-5090.5           -100             -3              0            1.1      8.9]);
%!assert (round ([0-13i     0-7i     0+0i     0+1i     0+2i    0+10i], 1, "decimals"), [0-13i     0-7i     0+0i     0+1i     0+2i    0+10i]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                  8.8888884+10i], 1, "decimals"), [-5090.5-13i                        -100-7i                          -3+0i                           0+1i                         1.1+2i                  8.8999996+10i]);
%!assert (round ([0-5090.543i                         0-100i                           0-3i                           0+0i                     0+1.11111i                    0+8.888888i], 1, "decimals"), [0-5090.5i                         0-100i                           0-3i                           0+0i                         0+1.1i                         0+8.9i]);
%!assert (round ([13            7            0           -1           -2          -10], 1, "decimals"), [13   7   0  -1  -2 -10]);
%!assert (round ([-5090.543           -100             -3              0        1.11111       8.888888], 2, "decimals"), [-5090.54           -100             -3              0           1.11           8.89]);
%!assert (round ([0-13i                       0-7i                       0+0i                       0+1i                       0+2i                      0+10i], 2, "decimals"), [0-13i     0-7i     0+0i     0+1i     0+2i    0+10i]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                   8.888888+10i], 2, "decimals"), [-5090.54-13i                        -100-7i                          -3+0i                           0+1i                        1.11+2i                       8.89+10i]);
%!assert (round ([-5090.543           -100             -3              0        1.11111      8.8888884], 2, "decimals"), [-5090.54           -100             -3              0           1.11      8.8900003]);
%!assert (round ([0-13i     0-7i     0+0i     0+1i     0+2i    0+10i], 2, "decimals"), [0-13i     0-7i     0+0i     0+1i     0+2i    0+10i]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                  8.8888884+10i], 2, "decimals"), [-5090.54-13i                        -100-7i                          -3+0i                           0+1i                        1.11+2i                  8.8900003+10i]);
%!assert (round ([0-5090.543i                         0-100i                           0-3i                           0+0i                     0+1.11111i                    0+8.888888i], 2, "decimals"), [0-5090.54i                         0-100i                           0-3i                           0+0i                        0+1.11i                        0+8.89i]);
%!assert (round ([13            7            0           -1           -2          -10], 2, "decimals"), [13   7   0  -1  -2 -10]);
%!assert (round ([-5090.543           -100             -3              0        1.11111       8.888888], 7, "decimals"), [-5090.543           -100             -3              0        1.11111       8.888888]);
%!assert (round ([0-13i                       0-7i                       0+0i                       0+1i                       0+2i                      0+10i], 7, "decimals"), [0-13i     0-7i     0+0i     0+1i     0+2i    0+10i]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                   8.888888+10i], 7, "decimals"), [-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                   8.888888+10i]);
%!assert (round ([-5090.543           -100             -3              0        1.11111      8.8888884], 7, "decimals"), [-5090.543           -100             -3              0        1.11111      8.8888884]);
%!assert (round ([0-13i     0-7i     0+0i     0+1i     0+2i    0+10i], 7, "decimals"), [0-13i     0-7i     0+0i     0+1i     0+2i    0+10i]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                  8.8888884+10i], 7, "decimals"), [-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                  8.8888884+10i]);
%!assert (round ([0-5090.543i                         0-100i                           0-3i                           0+0i                     0+1.11111i                    0+8.888888i], 7, "decimals"), [0-5090.543i                         0-100i                           0-3i                           0+0i                     0+1.11111i                    0+8.888888i]);
%!assert (round ([13            7            0           -1           -2          -10], 7, "decimals"), [13   7   0  -1  -2 -10]);
%!assert (round ([-5090.543           -100             -3              0        1.11111       8.888888], 1, "significant"), [-5000  -100    -3     0     1     9]);
%!assert (round ([0-13i                       0-7i                       0+0i                       0+1i                       0+2i                      0+10i], 1, "significant"), [0-10i     0-7i     0+0i     0+1i     0+2i    0+10i]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                   8.888888+10i], 1, "significant"), [-5000-10i      -100-7i        -3+0i         0+1i         1+2i        9+10i]);
%!assert (round ([-5090.543           -100             -3              0        1.11111      8.8888884], 1, "significant"), [-5000  -100    -3     0     1     9]);
%!assert (round ([0-13i     0-7i     0+0i     0+1i     0+2i    0+10i], 1, "significant"), [0-10i     0-7i     0+0i     0+1i     0+2i    0+10i]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                  8.8888884+10i], 1, "significant"), [-5000-10i      -100-7i        -3+0i         0+1i         1+2i        9+10i]);
%!assert (round ([0-5090.543i                         0-100i                           0-3i                           0+0i                     0+1.11111i                    0+8.888888i], 1, "significant"), [0-5000i       0-100i         0-3i         0+0i         0+1i         0+9i]);
%!assert (round ([13            7            0           -1           -2          -10], 1, "significant"), [10   7   0  -1  -2 -10]);
%!assert (round ([-5090.543           -100             -3              0        1.11111       8.888888], 2, "significant"), [-5100           -100             -3              0            1.1            8.9]);
%!assert (round ([0-13i                       0-7i                       0+0i                       0+1i                       0+2i                      0+10i], 2, "significant"), [0-13i     0-7i     0+0i     0+1i     0+2i    0+10i]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                   8.888888+10i], 2, "significant"), [-5100-13i                        -100-7i                          -3+0i                           0+1i                         1.1+2i                        8.9+10i]);
%!assert (round ([-5090.543           -100             -3              0        1.11111      8.8888884], 2, "significant"), [-5100           -100             -3              0            1.1      8.8999996]);
%!assert (round ([0-13i     0-7i     0+0i     0+1i     0+2i    0+10i], 2, "significant"), [0-13i     0-7i     0+0i     0+1i     0+2i    0+10i]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                  8.8888884+10i], 2, "significant"), [-5100-13i                        -100-7i                          -3+0i                           0+1i                         1.1+2i                  8.8999996+10i]);
%!assert (round ([0-5090.543i                         0-100i                           0-3i                           0+0i                     0+1.11111i                    0+8.888888i], 2, "significant"), [0-5100i                         0-100i                           0-3i                           0+0i                         0+1.1i                         0+8.9i]);
%!assert (round ([13            7            0           -1           -2          -10], 2, "significant"), [13   7   0  -1  -2 -10]);
%!assert (round ([-5090.543           -100             -3              0        1.11111       8.888888], 7, "significant"), [-5090.543           -100             -3              0        1.11111       8.888888]);
%!assert (round ([0-13i                       0-7i                       0+0i                       0+1i                       0+2i                      0+10i], 7, "significant"), [0-13i     0-7i     0+0i     0+1i     0+2i    0+10i]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                   8.888888+10i], 7, "significant"), [-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                   8.888888+10i]);
%!assert (round ([-5090.543           -100             -3              0        1.11111      8.8888884], 7, "significant"), [-5090.543           -100             -3              0        1.11111      8.8888884]);
%!assert (round ([0-13i     0-7i     0+0i     0+1i     0+2i    0+10i], 7, "significant"), [0-13i     0-7i     0+0i     0+1i     0+2i    0+10i]);
%!assert (round ([-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                  8.8888884+10i], 7, "significant"), [-5090.543-13i                        -100-7i                          -3+0i                           0+1i                     1.11111+2i                  8.8888884+10i]);
%!assert (round ([0-5090.543i                         0-100i                           0-3i                           0+0i                     0+1.11111i                    0+8.888888i], 7, "significant"), [0-5090.543i                         0-100i                           0-3i                           0+0i                     0+1.11111i                    0+8.888888i]);
%!assert (round ([13            7            0           -1           -2          -10], 7, "significant"), [13   7   0  -1  -2 -10]);
