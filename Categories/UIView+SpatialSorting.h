//
//  UIView+SpatialSorting.h
//  State
//
//  Created by Lee Higgins on 27/03/2013.
//  Copyright (c) 2013 State. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SpatialSorting)


+(NSArray*)sortLeftToRight:(NSArray*)views;
+(NSArray*)sortLeftToRightBasedOnSuperView:(NSArray*)views;
+(NSArray*)sortTopToBottom:(NSArray*)views;
@end
