//
//  UIToolbar+UIToolbar_RemovedEdgeInsets.m
//  
//
//  Created by Lee Higgins on 23/07/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "UIToolbar+RemovedEdgeInsets.h"

@implementation UIToolbar (RemovedEdgeInsets)

+(NSArray*)itemsRemovingEdgeInsets:(NSArray*)items
{
    UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSeperator.width = -12;
    
    NSMutableArray* removeEdgeSpacing = [NSMutableArray array];
    
    [removeEdgeSpacing addObject:negativeSeperator];
    
    for(UIBarButtonItem* item in items)
    {
        [removeEdgeSpacing addObject:item];
    }
    
    [removeEdgeSpacing addObject:negativeSeperator];
    return removeEdgeSpacing;
}

-(void)setItemsRemovingEdgeInsets:(NSArray *)items
{
    self.items = [UIToolbar itemsRemovingEdgeInsets:items];
}

-(void)setItemsRemovingEdgeInsets:(NSArray *)items animated:(BOOL)animated
{
    [self setItems:[UIToolbar itemsRemovingEdgeInsets:items] animated:animated];
}
@end
