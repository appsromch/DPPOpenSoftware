//
//  UIImage+SolidColour.h
//  State
//
//  Created by Lee Higgins on 18/03/2013.
//  Copyright (c) 2013 State. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SolidColour)
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGRect)size;
@end
