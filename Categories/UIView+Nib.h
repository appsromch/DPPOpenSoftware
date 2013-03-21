//
//  UIView+Nib.h
//  State
//
//  Created by Lee Higgins on 01/03/2013.
//  Copyright (c) 2013 State. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Nib)
+(id)viewFromNibNamed:(NSString*)nibName ofClass:(Class)class;
@end
