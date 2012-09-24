//
//  DPPPulseButton.h
//  Stepwise
//
//  Created by Lee Higgins on 11/02/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPPPulseButton : UIControl

@property(nonatomic,retain) IBOutlet UIView* pulseView;


@property(nonatomic,assign) float speed;
@property(nonatomic,assign) float maxScale;
@property(nonatomic,assign) BOOL running;

-(void)start;
-(void)stop;
-(void)resume;

+(void)pauseAll;
+(void)resumeALL;

@end
