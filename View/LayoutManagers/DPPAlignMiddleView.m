//
//  DPPAlignMiddleView.m
//  State
//
//  Created by Lee Higgins on 10/12/2012.
//  Copyright (c) 2012 State. All rights reserved.
//

#import "DPPAlignMiddleView.h"

@implementation DPPAlignMiddleView

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.alignMode = DPPAlignViewMiddle;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.alignMode = DPPAlignViewMiddle;
    }
    return self;
}

@end
