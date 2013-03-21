//
//  UIView+Nib.m
//  State
//
//  Created by Lee Higgins on 01/03/2013.
//  Copyright (c) 2013 State. All rights reserved.
//

#import "UIView+Nib.h"

@implementation UIView (Nib)

+(id)viewFromNibNamed:(NSString*)nibName ofClass:(Class)class
{
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    
    for (UIView* view in views)
    {
        if([view isKindOfClass:class])
        {
            return view;
        }
    }
    return nil;
}

@end
