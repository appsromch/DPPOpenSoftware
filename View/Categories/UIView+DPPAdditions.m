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

-(void)insertSubview:(UIView *)view belowSubviews:(NSArray *)siblingSubviews
{
    NSUInteger lowestIndex = INT32_MAX;
    UIView* lowestSibling = nil;
    for(UIView* sibling in siblingSubviews)
    {
        if(sibling.superview == self)
        {
            NSUInteger index = [[self subviews] indexOfObject:sibling];
            if(index < lowestIndex && index!=NSNotFound)
            {
                lowestSibling = sibling;
                lowestIndex = index;
            }
        }
    }
    if(lowestSibling)
    {
        [self insertSubview:view belowSubview:lowestSibling];
    }
}

-(void)insertSubview:(UIView *)view aboveSubviews:(NSArray *)siblingSubviews
{
    NSUInteger highestIndex = NSNotFound;
    UIView* highestSibling = nil;
    for(UIView* sibling in siblingSubviews)
    {
        if(sibling.superview == self)
        {
            NSUInteger index = [[self subviews] indexOfObject:sibling];
            if(index > highestIndex)
            {
                highestSibling = sibling;
                highestIndex = index;
            }
        }
    }
    if(highestSibling)
    {
        [self insertSubview:view aboveSubview:highestSibling];
    }
}

@end
