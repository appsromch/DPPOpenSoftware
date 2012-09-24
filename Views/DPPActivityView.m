//
//  DPPActivityView.m
//  
//
//  Created by Lee Higgins on 20/08/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "DPPActivityView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DPPActivityView

@synthesize animating;
@synthesize spinnerView;

-(void)startAnimating
{
    if(self.hidden) return;
    if(self.spinnerView.layer.animationKeys.count > 0) return; //already animating

        animating = YES;
        self.spinnerView.transform = CGAffineTransformMakeRotation(0);
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear  animations:
         ^{
             self.spinnerView.transform = CGAffineTransformMakeRotation(M_PI*0.999);
         }
                         completion:^(BOOL finished)
         {
             if(finished && !self.hidden)
             {
                 self.spinnerView.transform = CGAffineTransformMakeRotation(M_PI);
                 [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:
                  ^{
                      self.spinnerView.transform = CGAffineTransformMakeRotation(M_PI*1.999);
                  } completion:^(BOOL finished)
                  {
                      
                      if(finished && !self.hidden) {
                          animating = NO;
                          [self startAnimating];
                      }
                  }];
             }
         }];

}

-(void)drawRect:(CGRect)rect
{
    [self startAnimating];
    [super drawRect:rect];
}




@end
