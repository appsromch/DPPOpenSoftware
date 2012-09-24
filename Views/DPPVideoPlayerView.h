//
//  DPPVideoPlayer.h
//  Stepwise
//
//  Created by Lee Higgins on 07/02/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerView.h"

@class AVPlayer;
@class DPPVideoPlayerView;

@protocol DPPVideoPlayerViewDelegate <NSObject>

-(void)playerUpdate:(DPPVideoPlayerView*)sender;

@end

@interface DPPVideoPlayerView : PlayerView

@property(nonatomic,assign) IBOutlet UIView*                airplayActiveView;
@property(nonatomic,assign) BOOL                            airplayActive;
@property(nonatomic,retain) NSURL*                          videoURL;
@property(nonatomic,assign) BOOL                            playing;
@property(nonatomic,assign) BOOL                            finished;
@property(nonatomic,assign) BOOL                            fullscreen;
@property(nonatomic,assign) BOOL                            updateDelegate;
@property(nonatomic,assign) NSTimeInterval                  positionTime;
@property(nonatomic,assign) double                          position;
@property(nonatomic,assign) double                          volume;
@property(nonatomic,assign) double                          duration;
@property(nonatomic,assign) IBOutlet UISlider*              slider;
@property(nonatomic,assign) IBOutlet UIView*                volumeView;
@property(nonatomic,assign) IBOutlet UIButton*              playPauseButton;
@property(nonatomic,assign) IBOutlet id<DPPVideoPlayerViewDelegate>      delegate;

@property(nonatomic,assign) IBOutlet UIView*                fullscreenContainer;
@property(nonatomic,assign) IBOutlet UIView*                fullscreenRootView;

-(IBAction)playButtonTapped:(id)sender;

-(void)play;
-(void)pause;
-(void)playPause;
-(void)seekToTime:(NSTimeInterval)time;
-(void)shutdown;

@end
