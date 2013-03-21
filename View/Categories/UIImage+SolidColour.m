//
//  UIImage+SolidColour.m
//  State
//
//  Created by Lee Higgins on 18/03/2013.
//  Copyright (c) 2013 State. All rights reserved.
//

#import "UIImage+SolidColour.h"

@implementation UIImage (SolidColour)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    return [self imageWithColor:color size:CGRectMake(0, 0, 1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGRect)rect {
    if(color && !CGRectIsEmpty(rect))
    {
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    return nil;
}

@end
