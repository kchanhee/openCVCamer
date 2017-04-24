//
//  ViewController.m
//  openCVTest
//
//  Created by Chan-Hee Koh on 4/17/17.
//  Copyright © 2017 Chan-Hee Koh. All rights reserved.
//

#import "ViewController.h"
#import <opencv2/opencv.hpp>

//#import "ImageUtils.h"
//#import "GeometryUtil.h"
//#import "MSERManager.h"
//#import "MLManager.h"

//this two values are dependant on defaultAVCaptureSessionPreset
#define W (480)
#define H (640)




@interface ViewController ()
@property (strong, nonatomic) UIImageView *contain;
@property (strong, nonatomic) UIImageView *subImage;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UILabel *recogLabel;
@property (strong, nonatomic) UIView *textBound;

@property (strong) G8Tesseract *ts;
@property (assign) BOOL gray;
@property (assign) int count;
@property (assign) BOOL started;
@property (assign) CGRect textRect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello World" message:@"welcome to opencv" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    //    [alert show];
    // Do any additional setup after loading the view, typically from a nib.
    self.image = [UIImage imageNamed:@"skyknight_bw"];
    self.recogLabel = [[UILabel alloc] init];
    self.recogLabel.textColor = [UIColor whiteColor];
    self.recogLabel.shadowColor = [UIColor whiteColor];
    self.recogLabel.shadowOffset = CGSizeMake(0, -1.0);
    self.recogLabel.text = @"OCR Recog";
    self.recogLabel.backgroundColor = [UIColor blackColor];
    
    self.textBound = [[UIView alloc] init];
    self.textBound.layer.borderColor = [UIColor redColor].CGColor;
    self.textBound.layer.borderWidth = 1.0;
    self.textBound.backgroundColor = [UIColor clearColor];
    
    self.contain = [[UIImageView alloc] initWithImage:self.image];
    self.subImage = [[UIImageView alloc] init];
    [self initCamera];
    self.button = [[UIButton alloc] init];
    //    self.button.titleLabel.text = @"Next";
    [self.button setTitle:@"Next" forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button.backgroundColor = [UIColor blackColor];
    
    [self.button addTarget:self action:@selector(doTap:) forControlEvents:UIControlEventTouchUpInside];
    self.gray = NO;
    self.count = 0;
    self.ts = [[G8Tesseract alloc] initWithLanguage:@"eng"];
    self.ts.delegate = self;
    self.ts.charWhitelist = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    self.ts.image = self.image;
    self.ts.maximumRecognitionTime = 2.0;
}

-(void)viewWillAppear:(BOOL)animated {
    [self.contain setBounds:CGRectMake(0, 0, 375, 667)];
    [self.button setBounds:CGRectMake(0, 0, 100, 45)];
    [self.button setFrame:CGRectMake(30, 200, 100, 45)];
    [self.recogLabel setBounds:CGRectMake(0, 0, 100, 45)];
    [self.recogLabel setFrame:CGRectMake(150, 200, 100, 45)];
    self.contain.contentMode = UIViewContentModeCenter;
    self.contain.contentMode = UIViewContentModeScaleAspectFill;
    self.textRect = CGRectMake(85, 84, 550, 58);
    self.subImage.image = [self imageByCropping:self.image toRect:self.textRect];
    [self.subImage setBounds:CGRectMake(0, 0, 400, self.textRect.size.height)];
    self.subImage.contentMode = UIViewContentModeCenter;
    self.subImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.textBound setFrame:CGRectMake(0, 30, 534, 58)];
    [self.view addSubview:self.contain];
    
    self.contain.center = self.view.center;
    self.subImage.center = self.view.center;
    self.subImage.layer.borderColor = [UIColor greenColor].CGColor;
    self.subImage.layer.borderWidth = 1.0;
    [self.view addSubview:self.subImage];
    [self.view addSubview:self.button];
    [self.view addSubview:self.recogLabel];
    [self.view addSubview:self.textBound];
    [self.view bringSubviewToFront:self.button];
    
    self.ts.rect = self.textRect;
    [self.ts recognize];
    self.recogLabel.text = [self.ts recognizedText];

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self.camera start];
}


-(void)initCamera {
    self.camera = [[CvVideoCamera alloc] initWithParentView:self.contain];
    self.camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.camera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.camera.defaultFPS = 30;
    self.camera.grayscaleMode = NO;
    self.camera.delegate = self;
    
}

-(void)doTap:(UIButton *)sender {
    
    cv::Mat sdfs = [self cvMatFromUIImage:self.image];
    cv::Mat greyMat;
    cv::cvtColor(sdfs, greyMat, CV_RGBA2GRAY);
    cv::Mat outImg;
    cv::threshold(greyMat, outImg, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
    
    //    if (self.gray) {
    //
    //        self.contain.image = [self UIImageFromCVMat:sdfs];
    //    } else{
    //        self.contain.image = [self UIImageFromCVMat:greyMat];
    //    }
    //    self.gray = ! self.gray;
    UIImage *processedImg = [[UIImage alloc] init];
//    if (self.count == 0) {
//        processedImg = [self UIImageFromCVMat:sdfs];
//        self.count++;
//    } else if (self.count == 1) {
//        processedImg = [self UIImageFromCVMat:greyMat];
//        self.count++;
//    } else if (self.count == 2) {
//        processedImg = [self otsuThreshold:greyMat];
//        self.count++;
//    } else if (self.count == 3) {
//        processedImg = [self imageErode:outImg];
//        self.count = 0;
//    }
    
    switch (self.count) {
        case 0: {
            processedImg = [self otsuThreshold:greyMat];
            self.count++;
            break;
        }
        case 1: {
            processedImg = [self UIImageFromCVMat:greyMat];
            self.count++;
            break;
        }
        default: {
            processedImg = [self imageErode:outImg];
            self.count = 0;
            break;
        }
            
    }
    self.ts.image = processedImg;
    self.ts.rect = self.textRect;
    [self.ts recognize];
    self.recogLabel.text = [self.ts recognizedText];
    [self.recogLabel sizeToFit];
    self.subImage.image = [self imageByCropping:processedImg toRect:self.textRect];
    self.contain.image = processedImg;
    //    [self.contain setImage:[self UIImageFromCVMat:[self cvMatGrayFromUIImage:self.image]]];
}

- (UIImage *)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}


- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    {
        CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
        CGFloat cols = image.size.width;
        CGFloat rows = image.size.height;
        cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
        CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                        cols,                       // Width of bitmap
                                                        rows,                       // Height of bitmap
                                                        8,                          // Bits per component
                                                        cvMat.step[0],              // Bytes per row
                                                        colorSpace,                 // Colorspace
                                                        kCGImageAlphaNoneSkipLast |
                                                        kCGBitmapByteOrderDefault); // Bitmap info flags
        CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
        CGContextRelease(contextRef);
        return cvMat;
    }
}

//- (cv::Mat)cvMatGrayFromImage:(UIImage *)image {
//    cv::Mat imageMat;
//    return [self UIImageToMat(image, imageMat) ];
//}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return finalImage;
}

-(UIImage *)otsuThreshold:(cv::Mat)cvMat {
    cv::Mat outImg;
    cv::threshold(cvMat, outImg, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
    return [self UIImageFromCVMat:outImg];
}
-(UIImage *)imageErode:(cv::Mat)cvMat {
    cv::Mat bw2;
    cv::Mat erodedBW2;
    cv::Mat se = getStructuringElement(0, cv::Size(3,3));
    cv::dilate(cvMat, bw2, se);
    return [self UIImageFromCVMat:bw2];
}

@end
