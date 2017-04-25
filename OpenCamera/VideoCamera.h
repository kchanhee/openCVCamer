//
//  VideoCamera.h
//  OpenCamera
//
//  Created by Chan on 4/24/17.
//  Copyright © 2017 Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/videoio/cap_ios.h>

@interface VideoCamera : CvVideoCamera
@property BOOL letterboxPreview;
- (void)setPointOfInterestInParentViewSpace:(CGPoint)point;

@end
