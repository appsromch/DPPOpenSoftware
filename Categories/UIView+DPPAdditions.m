//
//  UIView+Additions.m
//
//  Created by Lee Higgins on 12/02/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "UIView+DPPAdditions.h"
#import <QuartzCore/QuartzCore.h>
@implementation UIView(DPPAdditions)

-(UIImage*)captureView
{
    UIImage* retImage = nil;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    return retImage;
}




@end
