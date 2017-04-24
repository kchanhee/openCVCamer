//
//  ViewController.h
//  OpenCamera
//
//  Created by Chan on 4/16/17.
//  Copyright © 2017 Chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/videoio/cap_ios.h>
#import <TesseractOCR/TesseractOCR.h>

using namespace cv;

@interface ViewController : UIViewController <CvVideoCameraDelegate, G8TesseractDelegate>

@property (strong) CvVideoCamera *camera;
@end

