//
//  DPPTouchExtenderView.m
//  TalkTalkXfactor
//
//  Created by Lee Higgins on 08/08/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "DPPTouchExtenderView.h"

@implementation DPPTouchExtenderView

@synthesize viewToExtend;


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if (view == self)
        return self.viewToExtend;
    
    return view;
}

@end
