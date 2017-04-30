

#import "UIImage+operation.h"

static CGRect swapWidthAndHeight(CGRect rect)
{
    CGFloat  swap = rect.size.width;
    
    rect.size.width  = rect.size.height;
    rect.size.height = swap;
    
    return rect;
}

@implementation UIImage (UKImage)

//-(UIImage*)rotate:(UIImageOrientation)orient
//{
//    CGRect             bounds = CGRectZero;
//    UIImage*           copy = nil;
//    CGContextRef       ctxt = nil;
//    CGImageRef         image = self.CGImage;
//    CGRect             rect = CGRectZero;
//    CGAffineTransform  trans = CGAffineTransformIdentity;
//    
//    rect.size.width  = CGImageGetWidth(image);
//    rect.size.height = CGImageGetHeight(image);
//    
//    bounds = rect;
//    
//    switch (orient)
//    {
//        case UIImageOrientationUp:
//            // would get you an exact copy of the original
//            assert(false);
//            return nil;
//            
//        case UIImageOrientationUpMirrored:
//            trans = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
//            trans = CGAffineTransformScale(trans, -1.0, 1.0);
//            break;
//            
//        case UIImageOrientationDown:
//            trans = CGAffineTransformMakeTranslation(rect.size.width,
//                                                    rect.size.height);
//            trans = CGAffineTransformRotate(trans, M_PI);
//            break;
//            
//        case UIImageOrientationDownMirrored:
//            trans = CGAffineTransformMakeTranslation(0.0, rect.size.height);
//            trans = CGAffineTransformScale(trans, 1.0, -1.0);
//            break;
//            
//        case UIImageOrientationLeft:
//            bounds = swapWidthAndHeight(bounds);
//            trans = CGAffineTransformMakeTranslation(0.0, rect.size.width);
//            trans = CGAffineTransformRotate(trans, 3.0 * M_PI / 2.0);
//            break;
//            
//        case UIImageOrientationLeftMirrored:
//            bounds = swapWidthAndHeight(bounds);
//            trans = CGAffineTransformMakeTranslation(rect.size.height,
//                                                    rect.size.width);
//            trans = CGAffineTransformScale(trans, -1.0, 1.0);
//            trans = CGAffineTransformRotate(trans, 3.0 * M_PI / 2.0);
//            break;
//            
//        case UIImageOrientationRight:
//            bounds = swapWidthAndHeight(bounds);
//            trans = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
//            trans = CGAffineTransformRotate(trans, M_PI / 2.0);
//            break;
//            
//        case UIImageOrientationRightMirrored:
//            bounds = swapWidthAndHeight(bounds);
//            trans = CGAffineTransformMakeScale(-1.0, 1.0);
//            trans = CGAffineTransformRotate(trans, M_PI / 2.0);
//            break;
//            
//        default:
//            // orientation value supplied is invalid
//            assert(false);
//            return nil;
//    }
//    
//    UIGraphicsBeginImageContext(bounds.size);
//    ctxt = UIGraphicsGetCurrentContext();
//    
//    switch (orient)
//    {
//        case UIImageOrientationLeft:
//        case UIImageOrientationLeftMirrored:
//        case UIImageOrientationRight:
//        case UIImageOrientationRightMirrored:
//            CGContextScaleCTM(ctxt, -1.0, 1.0);
//            CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
//            break;
//            
//        default:
//            CGContextScaleCTM(ctxt, 1.0, -1.0);
//            CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
//            break;
//    }
//    
//    CGContextConcatCTM(ctxt, trans);
//    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, image);
//    
//    copy = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return copy;
//}


// cvMat is grayscale
+(double)computeSkew:(cv::Mat)cvMat {
//    UIImage    *copy = nil;
//    CGImageRef image = self.CGImage;
    cv::Size size = cvMat.size();
    cv::bitwise_not(cvMat, cvMat);
    cv::Vec2f lines2;
    std::vector<cv::Vec2f> lines;
    cv::HoughLines(cvMat, lines, 1, CV_PI/180, 300);
    
//    size_t sizeOfLine = lines.size();
    cv::Mat disp_lines(size, CV_8UC1, cv::Scalar(0, 0, 0));
    double angle = 0.;
    unsigned long nb_lines = lines.size();
    for (unsigned i = 0; i < nb_lines; ++i)
    {
        cv::line(disp_lines, cv::Point(lines[i][0], lines[i][1]),
                 cv::Point(lines[i][2], lines[i][3]), cv::Scalar(255, 0 ,0));
        angle += atan2((double)lines[i][3] - lines[i][1],
                       (double)lines[i][2] - lines[i][0]);
    }
    angle /= nb_lines; // mean angle, in radians.
    return angle;
}

+(UIImage *)deSkew:(cv::Mat)cvMat{
    UIImage *copy = nil;
    double angle = [UIImage computeSkew:cvMat];
    std::vector<cv::Point> points;
    cv::Mat_<uchar>::iterator it = cvMat.begin<uchar>();
    cv::Mat_<uchar>::iterator end = cvMat.end<uchar>();
    for (; it != end; ++it)
        if (*it)
            points.push_back(it.pos());
    
    cv::RotatedRect box = cv::minAreaRect(cv::Mat(points));
    cv::Mat rot_mat = cv::getRotationMatrix2D(box.center, angle, 1);
    cv::Mat rotated;
    cv::warpAffine(cvMat, rotated, rot_mat, cvMat.size(), cv::INTER_CUBIC);
    cv::Size box_size = box.size;
    if (box.angle < -45.)
        std::swap(box_size.width, box_size.height);
    cv::Mat cropped;
    cv::getRectSubPix(rotated, box_size, box.center, cropped);
    copy = [UIImage UIImageFromCVMat:rotated];
    return copy;
}

+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    CGBitmapInfo bitmapInfo;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        bitmapInfo = kCGBitmapByteOrder32Little | (
                                                   cvMat.elemSize() == 3? kCGImageAlphaNone : kCGImageAlphaNoneSkipFirst
                                                   );
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(
                                        cvMat.cols,                 //width
                                        cvMat.rows,                 //height
                                        8,                          //bits per component
                                        8 * cvMat.elemSize(),       //bits per pixel
                                        cvMat.step[0],              //bytesPerRow
                                        colorSpace,                 //colorspace
                                        bitmapInfo,                 // bitmap info
                                        provider,                   //CGDataProviderRef
                                        NULL,                       //decode
                                        false,                      //should interpolate
                                        kCGRenderingIntentDefault   //intent
                                        );
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage; 
}

@end
