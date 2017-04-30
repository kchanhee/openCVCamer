//
//  UIImage+operation.h
//  infojobOCR
//
//  Created by Paolo Tagliani on 09/06/12.
//  Copyright (c) 2012 26775. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
using namespace cv;

@interface UIImage (UKImage)

//-(UIImage*)rotate:(UIImageOrientation)orient;
+(double)computeSkew:(cv::Mat)cvMat;
+(UIImage *)deSkew:(cv::Mat)cvMat;

@end

