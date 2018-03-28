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