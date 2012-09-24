//
//  UIStretchableImageView.m
//  Stepwise
//
//  Created by Lee Higgins on 05/02/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "DPPStretchableImageView.h"

@implementation DPPStretchableImageView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.image = self.image; //invoke the setimage code
    }
    return self;
}

-(void)setImage:(UIImage *)image
{
    //TODO Do we need to round the below??
    [super setImage:[image stretchableImageWithLeftCapWidth:(image.size.width*0.5)-1.0 topCapHeight:(image.size.height*0.5)-1.0]];
}

@end
