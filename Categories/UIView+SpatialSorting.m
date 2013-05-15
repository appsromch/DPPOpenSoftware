//
//  UIView+SpatialSorting.m
//  State
//
//  Created by Lee Higgins on 27/03/2013.
//  Copyright (c) 2013 State. All rights reserved.
//

#import "UIView+SpatialSorting.h"

@implementation UIView (SpatialSorting)

+(NSArray*)sortLeftToRight:(NSArray*)views
{
    NSArray* sortedArray = [views sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
       
        UIView* aView = (UIView*)a;
        UIView* bView = (UIView*)b;
        
        if(aView.frame.origin.x < bView.frame.origin.x)
        {
            return NSOrderedAscending;
        }
        else if(aView.frame.origin.x == bView.frame.origin.x)
        {
            return NSOrderedSame;
        }
        return NSOrderedDescending;
    }];
    return sortedArray;
}

+(NSArray*)sortLeftToRightBasedOnSuperView:(NSArray*)views
{
    NSArray* sortedArray = [views sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        
        UIView* aView = (UIView*)a;
        UIView* bView = (UIView*)b;
        
        if(aView.superview.frame.origin.x < bView.superview.frame.origin.x)
        {
            return NSOrderedAscending;
        }
        else if(aView.superview.frame.origin.x == bView.superview.frame.origin.x)
        {
            return NSOrderedSame;
        }
        return NSOrderedDescending;
    }];
    return sortedArray;
}

+(NSArray*)sortTopToBottom:(NSArray*)views
{
    NSArray* sortedArray = [views sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        
        UIView* aView = (UIView*)a;
        UIView* bView = (UIView*)b;
        
        if(aView.frame.origin.y < bView.frame.origin.y)
        {
            return NSOrderedAscending;
        }
        else if(aView.frame.origin.y == bView.frame.origin.y)
        {
            return NSOrderedSame;
        }
        return NSOrderedDescending;
    }];
    return sortedArray;
}

@end
