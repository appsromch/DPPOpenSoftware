//
//  DPPAlignFlowFromLeftView.m
//  State
//
//  Created by Lee Higgins on 10/12/2012.
//  Copyright (c) 2012 State. All rights reserved.
//

#import "DPPAlignFlowFromLeftView.h"

@implementation DPPAlignFlowFromLeftView

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.alignMode = DPPAlignViewFlowFromLeft;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.alignMode = DPPAlignViewFlowFromLeft;
    }
    return self;
}


@end
