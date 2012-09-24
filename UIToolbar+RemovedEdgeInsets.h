//
//  UIToolbar+UIToolbar_RemovedEdgeInsets.h
//  TalkTalkXfactor
//
//  Created by Lee Higgins on 23/07/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIToolbar (RemovedEdgeInsets)

-(void)setItemsRemovingEdgeInsets:(NSArray *)items;
-(void)setItemsRemovingEdgeInsets:(NSArray *)items animated:(BOOL)animated;
+(NSArray*)itemsRemovingEdgeInsets:(NSArray*)items;
@end
