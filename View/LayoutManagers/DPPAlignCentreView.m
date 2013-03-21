//
//  DPPAlignCentreView.m
//  State
//
//  Created by Lee Higgins on 10/12/2012.
//  Copyright (c) 2012 State. All rights reserved.
//

#import "DPPAlignCentreView.h"

@implementation DPPAlignCentreView

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.alignMode = DPPAlignViewCentre;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.alignMode = DPPAlignViewCentre;
    }
    return self;
}

@end
