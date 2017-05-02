//
//  ViewController.m
//  openCVTest
//
//  Created by Chan-Hee Koh on 4/17/17.
//  Copyright © 2017 Chan-Hee Koh. All rights reserved.
//

#import "ViewController.h"
#import <opencv2/opencv.hpp>
#import "UIImage+operation.h"
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
@property (strong) NSMutableArray *bounding;
@property (assign) int boundcount;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello World" message:@"welcome to opencv" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    //    [alert show];
    // Do any additional setup after loading the view, typically from a nib.
//    self.image = [UIImage imageNamed:@"skyknight"];
    self.image = [UIImage imageNamed:@"pen_spider_white_bg"];

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
    self.bounding = [[NSMutableArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.contain setBounds:CGRectMake(0, 0, 375, 667)];
    [self.button setBounds:CGRectMake(0, 0, 100, 45)];
    [self.button setFrame:CGRectMake(30, 50, 100, 45)];
    [self.recogLabel setBounds:CGRectMake(0, 0, 100, 45)];
    [self.recogLabel setFrame:CGRectMake(150, 50, 100, 45)];
    self.contain.contentMode = UIViewContentModeCenter;
    self.contain.contentMode = UIViewContentModeScaleAspectFit;
    self.textRect = CGRectMake(85, 84, 550, 58);
    self.subImage.image = [self imageByCropping:self.image toRect:self.textRect];
    [self.subImage setBounds:CGRectMake(0, 0, 400, 300)];
    self.subImage.contentMode = UIViewContentModeCenter;
    self.subImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.textBound setFrame:CGRectMake(0, 30, 534, 58)];
    [self.view addSubview:self.contain];
    
    self.contain.center = self.view.center;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    [self.subImage setFrame:CGRectMake((screenWidth - 400) / 2, screenHeight - 300 , 400, 300)];
    self.subImage.layer.borderColor = [UIColor blueColor].CGColor;
    self.subImage.layer.borderWidth = 1.0;
    [self.view addSubview:self.subImage];
    [self.view addSubview:self.button];
    [self.view addSubview:self.recogLabel];
//    [self.view addSubview:self.textBound];
    [self.view bringSubviewToFront:self.button];
    
    self.ts.rect = self.textRect;
    [self.ts recognize];
    self.recogLabel.text = [self.ts recognizedText];
    self.boundcount = 0;
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
//    self.recogLabel.hidden = YES;
//    self.textBound.hidden = YES;
//    self.subImage.hidden = YES;

    cv::Mat sdfs = [self cvMatFromUIImage:self.image];
    cv::Mat greyMat;
    cv::cvtColor(sdfs, greyMat, CV_BGRA2GRAY);
//    cv::Mat outImg;
//    cv::threshold(greyMat, outImg, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
    
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
    
//    switch (self.count) {
//        case 0: {
//            processedImg = [self otsuThreshold:greyMat];
//            self.count++;
//            break;
//        }
//        case 1: {
//            processedImg = [self UIImageFromCVMat:greyMat];
//            self.count++;
//            break;
//        }
//        default: {
//            processedImg = [[self detectText:sdfs] firstObject];
//            self.count = 0;
//            break;
//        }
//            
//    }
    
    if (self.count == 0) {
        NSArray *arr = [[NSArray alloc] initWithArray:[self detectText:sdfs]];
        processedImg = [arr firstObject];
        self.bounding = [arr lastObject];
        self.count++;
    } else {
        NSLog(@"Current image: %d", self.boundcount);
        if (self.boundcount == self.bounding.count - 1) {
            self.subImage.image = self.bounding[self.boundcount];
            self.boundcount = 0;
            self.count = 0;
        } else {
            self.subImage.image = self.bounding[self.boundcount];
            self.boundcount++;
            self.ts.image = self.subImage.image;
            [self.ts recognize];
            self.recogLabel.text = [self.ts recognizedText];
            [self.recogLabel sizeToFit];
        }
//        Mat threshImg = [self doAdaptThreshold:greyMat];
//        
//        
//        
//        processedImg = [self UIImageFromCVMat:threshImg];
//        self.count = 0;

        return;
    }
    
//    self.ts.image = processedImg;
//    self.ts.rect = self.textRect;
//    [self.ts recognize];
//
//    [self.recogLabel sizeToFit];
//    self.subImage.image = [self imageByCropping:processedImg toRect:self.textRect];
    
    self.contain.image = processedImg;
    //    [self.contain setImage:[self UIImageFromCVMat:[self cvMatGrayFromUIImage:self.image]]];
}

-(std::vector< std::vector<cv::Point> >)findContours:(Mat)thresholdImg minPts:(int)minContourPointsAllowed {
    std::vector< std::vector<cv::Point> > allContours;
    std::vector< std::vector<cv::Point> > contours;
    findContours(thresholdImg, allContours, CV_RETR_LIST, CV_CHAIN_APPROX_NONE);
    contours.clear();
    for (size_t i=0; i < allContours.size(); i++) {
        unsigned long contourSize = allContours[i].size();
        NSLog(@"contour size: %ld", contourSize);
        if (contourSize > minContourPointsAllowed) {
            contours.push_back(allContours[i]);
        }
    }
    return contours;
    
}

-(Mat)doAdaptThreshold:(Mat) grayscale {
    Mat thresholdImg;
    adaptiveThreshold(grayscale, thresholdImg, 255, ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY_INV, 7, 7);
    return thresholdImg;
}

-(NSArray *)detectText:(cv::Mat)cvMat {
    Mat rgb = cvMat;
    // Downsample and use for processing
//    pyrDown(cvMat, rgb);
//    pyrDown(rgb, rgb);
    Mat small;
    cvtColor(rgb, small, CV_BGRA2GRAY);
//    Mat small = cvMat;
    // Morphological Gradient
    Mat grad;
    Mat morphKernel = getStructuringElement(MORPH_ELLIPSE, cv::Size(2.5, 2.5));
    morphologyEx(small, grad, MORPH_GRADIENT, morphKernel);
    // TODO: UNCOMMENT THIS
    // binarize
    Mat bw = [self doAdaptThreshold:small];
//    threshold(grad, bw, 0.0, 255.0, THRESH_BINARY | THRESH_OTSU);
    
    // connect horizontally oriented regions
    // TODO: Replace grad with bw
    Mat connected;
    morphKernel = getStructuringElement(MORPH_RECT, cv::Size(9, 1));
    morphologyEx(bw, connected, MORPH_CLOSE, morphKernel);
    // find contours
    Mat mask = Mat::zeros(bw.size(), CV_8UC1);
    std::vector<std::vector<cv::Point>> contours = [self findContours:bw minPts:200];
//    std::vector<Vec4i> hierarchy;
//    findContours(connected, contours, hierarchy, CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
    NSMutableArray *boundingRects = [[NSMutableArray alloc] init];
    // filter contours
//    for(int idx = 0; idx >= 0; idx = hierarchy[idx][0]){
    for (int idx = 0; idx < contours.size(); idx++) {
        cv::Rect rect = boundingRect(contours[idx]);
        Mat maskROI(mask, rect);
        maskROI = Scalar(0, 0, 0);
        // fill the contour
        drawContours(mask, contours, idx, Scalar(255, 255, 255), CV_FILLED);
        
        RotatedRect rrect = minAreaRect(contours[idx]);
        double r = (double)countNonZero(maskROI) / (rrect.size.width * rrect.size.height);
        
        Scalar color;
        int thickness = 1;
        // assume at least 25% of the area is filled if it contains text
        if (r > 0.25 &&
            (rrect.size.height > 8 && rrect.size.width > 8) // constraints on region size
            // these two conditions alone are not very robust. better to use something
            // like the number of significant peaks in a horizontal projection as a third condition
            ){
            thickness = 2;
            color = Scalar(0, 255, 0);
        }
        else
        {
            thickness = 1;
            color = Scalar(0, 0, 255);
        }
        
        Point2f pts[4];
        rrect.points(pts);
        if (thickness == 2) {
            Mat M,rot,crop;
            float angle = rrect.angle;
            cv::Size rrect_size = rrect.size;
            if (rrect.angle < -45) {
                angle += 90.0;
                swap(rrect_size.width, rrect_size.height);
            }
            M = getRotationMatrix2D(rrect.center, angle, 1);
            warpAffine(bw, rot, M, rgb.size(), INTER_CUBIC);
            getRectSubPix(rot, rrect_size, rrect.center, crop);
            [boundingRects addObject:[self UIImageFromCVMat:crop]];
//            [boundingRects addObject:M];;
        }
        
        for (int i = 0; i < 4; i++)
        {
            line(bw, cv::Point((int)pts[i].x, (int)pts[i].y), cv::Point((int)pts[(i+1)%4].x, (int)pts[(i+1)%4].y), color, thickness);
            
            
        }
    }
    return @[[self UIImageFromCVMat:bw], boundingRects];
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
