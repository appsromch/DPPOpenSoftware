//
//  DPPPulseButton.m
//
//  Created by Lee Higgins on 11/02/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "DPPPulseButton.h"
#import <QuartzCore/QuartzCore.h>
#import "DPPARCCompatibility.h"
#define DPPPulseButtonPauseNotification @"DPPPulseButtonPauseNotification"
#define DPPPulseButtonResumeNotification @"DPPPulseButtonResumeNotification"

@interface DPPPulseButton()
@property(nonatomic,assign) float originalAlpha;
@end

@implementation DPPPulseButton

@synthesize pulseView;
@synthesize speed;
@synthesize running;
@synthesize originalAlpha;
@synthesize maxScale;

+(void)initialize
{
    [super initialize];
    //OK so I see no other way of getting all animations to restart without having to call start whenever they are used...
    //So I have a timer which will call the resume methods to restart all label animation (if needed)
    //This is a class timer, ie one for all instances...
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:[DPPPulseButton class] selector:@selector(resumeALL) userInfo:nil repeats:YES];
}

-(float)maxScale
{
   if(maxScale ==0.0)
   {
       return 1.3; //default
   }
    return maxScale;
}

-(float)speed
{
    if(speed == 0)
    {
       return 2.0; //default
    }
    return speed;
}

-(void)setupView
{    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop) name:DPPPulseButtonPauseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:DPPPulseButtonResumeNotification object:nil];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self setupView];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setupView];
    }
    return self;
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    [self start];
     self.originalAlpha =self.pulseView.alpha;
}

+(void)pauseAll
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DPPPulseButtonPauseNotification object:nil];
}

+(void)resumeALL
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DPPPulseButtonResumeNotification object:nil];
}

-(void)animateView
{
    if(running)
    {
    pulseView.transform = CGAffineTransformMakeScale(1,1);
    pulseView.alpha = originalAlpha;
    
        [UIView animateWithDuration:self.speed delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        float scale = self.maxScale;
        pulseView.transform = CGAffineTransformMakeScale(scale,scale); 
        pulseView.alpha = 0.f;
        
    }
                     completion:nil
                     ];
    }
}

-(void)resetAnimation
{
   
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

-(void)start 
{
	// Set running
    [self stop];
	running = YES;
}

-(void)stop
{
    if(running)
    {
        running = NO;
        [self.pulseView.layer removeAllAnimations];
    }
}

-(void)resume 
{    
	// Check not running
    if(self.pulseView.layer.animationKeys.count == 0 && self.superview !=nil && running && !self.hidden)
    {//check to see if we already have an animation....
        if(self.window == nil)
        {
            [self resetAnimation];
        }
        else
        {
            [self animateView];
        }
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    ARC_RELEASE(pulseView);
    ARC_SUPER_DEALLOC;
}


@end
