pkg load image;

M = imread ('moletom.jpg');
MG = rgb2gray (M);
imshow (MG)
[T1, Q1] = graythresh (MG)
[T2, Q2] = multithresh (MG)

if(Q1 - Q2 < 0.0001)
  'graythresh == multithresh'
else
  'graythresh != multithresh'
endif

[T2, Q2] = multithresh (MG, 2)

S = zeros (size (MG));
S(MG > T2(1) & MG <= T2(2)) = 127;
S(MG > T2(2)) = 255;
imshow (S, [1,255]);

U = imread ("default.img");
[T3, Q3] = graythresh (U)
[T4, Q4] = multithresh (U)
[T5, Q5] = multithresh (U, 2)
imshow (U)
V = zeros (size (U));
V(U > T5(1) & U <=T5(2)) = 0.5;
V(U>T5(2)) = 1;
figure, imshow (V);

%! I = [0 1 0 2];
%! [T1, Q1] = graythresh (I);
%! [T2, Q2] = multithresh (I);
%! assert (Q2, Q1, 0.001)
%! assert (T2, round(T1*length(I)), 0.001)
%!
%! I = [1 2 3 4 5 6 7 8 9 10];
%! [T3, Q3] = graythresh (I);
%! [T4, Q4] = multithresh (I);
%! #assert (Q4, Q3, 0.001)
%! assert (T4, round(T3*length(I)), 0.001)
%!
%! I = imread("tulips.png");
%! [T5, Q5] = graythresh (I);
%! [T6, Q6] = multithresh (I);
%! assert (Q6, Q5, 0.001)
%! assert (T6, round(T5*length(hist (I(:), 0:intmax (class (I))))), 1)
%!
%! I = imread("peppers.png");
%! [T7, Q7] = graythresh (I);
%! [T8, Q8] = multithresh (I);
%! assert (Q8, Q7, 0.001)
%! assert (T8, round(T7*length(hist (I(:), 0:intmax (class (I))))), 1)
%!
%! I = imread("fruits.png");
%! [T9, Q9] = graythresh (I);
%! [T10, Q10] = multithresh (I);
%! assert (Q10, Q9, 0.001)
%! assert (T10, round(T9*length(hist (I(:), 0:intmax (class (I))))), 1)
%!
%! I = imread("cameraman.tif");
%! [T11, Q11] = graythresh (I);
%! [T12, Q12] = multithresh (I);
%! assert (Q12, Q11, 0.001)
%! assert (T12, round(T11*length(hist (I(:), 0:intmax (class (I))))), 1)
%!
