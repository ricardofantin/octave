#include <highgui.h>
#include "opencv2/imgproc/imgproc.hpp"

using namespace cv;

int main(int argc, char** argv){
	Mat img;
	if(argc == 2)
		img = imread(argv[1]);
	else
		img = imread("../default.png");
	cvtColor(img, img, COLOR_BGR2GRAY);
	Mat filter = (Mat_<double>(5, 5) << 0.014419, 0.028084, 0.035073, 0.028084, 0.014419, 0.028084, 0.054700, 0.068312, 0.054700, 0.028084, 0.035073, 0.068312, 0.085312, 0.068312, 0.035073, 0.028084, 0.054700, 0.068312, 0.054700, 0.028084, 0.014419, 0.028084, 0.035073, 0.028084, 0.014419);
	filter2D(img, img, CV_8UC1, filter);
	vector<Point2f> points;
	//antes era 35 32; 27 5; 2 35; 1 28; 8 50; 4 29; 30 44; 28 45; 33 31; 24 32; 3 14; 38 32; 9 29; 19 47; 16 48; 17 32; 30 28; 36 46; 18 43; 8 32; 14 48; 6 44; 10 43; 13 44; 14 31; 14 41; 20 45; 25 44; 29 25; 29 points
	goodFeaturesToTrack(img, points, 500, 0.01, 2, noArray(), 3, false);
	printf("MinEigenvalue %zu points.\n", points.size());
	Mat imgMinEigenvalue;
	img.copyTo(imgMinEigenvalue);
	for(int i = 0; i < points.size(); i++){
		circle(imgMinEigenvalue, Point((int)points [i].x, (int)points [i].y), 1, Scalar(255), -1);
		printf("%2d %2d; ", (int)points[i].x + 1, (int)points[i].y + 1);
		if (i != 0 && (i + 1) % 5 ==  0)
			printf("\n          ");
	}
	printf("\n");
	imwrite("minimumEigenvalue.png", imgMinEigenvalue);
	vector<Point2f> points2;
	//35 32; 1 28; 27 5; 4 29; 24 32; 2 34; 33 32; 38 32; 8 50; 30 44; 28 45; 11 points
	goodFeaturesToTrack(img, points2, 500, 0.01, 2, noArray(), 3, true);
	printf("Harris %zu points.\n", points2.size());
	Mat imgHarris;
	img.copyTo(imgHarris);
	for(int i = 0; i < points2.size(); i++){
		circle(imgHarris,        Point((int)points2[i].x, (int)points2[i].y), 1, Scalar(255), -1);
		printf("%2d %2d; ", (int)points2[i].x + 1, (int)points2[i].y + 1);
		if (i != 0 && (i + 1) % 5 ==  0)
			printf("\n          ");
	}
	imwrite("harris.png", imgHarris);
}
