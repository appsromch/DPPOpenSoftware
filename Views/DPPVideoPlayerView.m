//
//  DPPVideoPlayer.m
//  Stepwise
//
//  Created by Lee Higgins on 07/02/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "DPPVideoPlayerView.h"
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVSynchronizedLayer.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVUtilities.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVTime.h>
#import <AVFoundation/AVAudioMix.h>
#import <AVFoundation/AVAudioSettings.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPVolumeView.h>

#import "DPPARCCompatibility.h"

@interface DPPVideoPlayerView()

-(void)playerUpdate;
-(void)addTimeObserverToPlayer;
-(void)removeTimeObserverFromPlayer;

@property(nonatomic,retain) id timedObserver;
@property(nonatomic,assign) double restoreRate;
@property(nonatomic,assign) CGRect orignalFrame;
@property(nonatomic,assign) UIView* originalContainer;

@end

@implementation DPPVideoPlayerView

@synthesize airplayActive;
@synthesize airplayActiveView;
@synthesize playing;
@synthesize finished;
@synthesize fullscreen;
@synthesize updateDelegate;
@synthesize slider;
@synthesize restoreRate;
@synthesize timedObserver;
@synthesize delegate;
@synthesize videoURL;
@synthesize positionTime;
@synthesize position;
@synthesize volume;
@synthesize volumeView;
@synthesize playPauseButton;
@synthesize duration;
@synthesize fullscreenContainer;
@synthesize orignalFrame;
@synthesize originalContainer;
@synthesize fullscreenRootView;

-(void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    MPVolumeView *myVolumeView = [[MPVolumeView alloc] initWithFrame: volumeView.bounds];
    [volumeView addSubview: myVolumeView];
    CGSize fitSize = [myVolumeView sizeThatFits:volumeView.bounds.size];
    myVolumeView.bounds = CGRectMake(0,0,fitSize.width,fitSize.height);
    [myVolumeView setCenter:CGPointMake(volumeView.bounds.size.width*0.5, volumeView.bounds.size.height*0.5)];
    ARC_RELEASE(myVolumeView);
}

-(void)setDelegate:(id<DPPVideoPlayerViewDelegate>)newDelegate
{
    delegate = newDelegate;
    updateDelegate = YES;
}

-(void)setVideoURL:(NSURL *)newVideoURL
{
    newVideoURL = ARC_RETAIN(newVideoURL);
    ARC_RELEASE(videoURL);
    videoURL = newVideoURL;
    [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:videoURL]];
   
}

-(void)setSlider:(UISlider *)newSlider
{
    slider = newSlider;
    slider.maximumValue = 1.0;
    [slider addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
    [slider addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchCancel];
    [slider addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpInside];
    [slider addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpOutside];
}

-(void)seekToTime:(NSTimeInterval)time
{
    [self removeTimeObserverFromPlayer];
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) 
                  toleranceBefore:kCMTimeZero 
                   toleranceAfter:kCMTimeZero];
    [self addTimeObserverToPlayer];
}

-(AVPlayer*)player
{
    if([super player]==nil)
    {
        AVPlayer* newPlayer = [[AVPlayer alloc] init];
        [super setPlayer:newPlayer];
        [self addTimeObserverToPlayer];
        [[super player] addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
        ARC_RELEASE(newPlayer);
    }
    return [super player];
}

-(void)addTimeObserverToPlayer
{
    __unsafe_unretained id weakSelf = self;
    self.timedObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.25, NSEC_PER_SEC) 
                                                                   queue:dispatch_get_main_queue() 
                                                              usingBlock:
                          ^(CMTime time) {
                              @autoreleasepool {
                              [weakSelf playerUpdate];
                              }
                          }];
}

-(void)removeTimeObserverFromPlayer
{
    [self.player removeTimeObserver:self.timedObserver];
    self.timedObserver = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.player && object == self.player && [keyPath isEqualToString:@"rate"]) 
    {
		float newRate = [[change objectForKey:@"new"] floatValue];
		playing = newRate != 0.0;
        
        playPauseButton.selected = playing;
    }
}

-(void)play
{
    [self.player play];
}

-(void)pause
{
    [self.player pause];
}

-(void)playPause
{
    if(playing)
    {
        [self.player pause];
    }
    else
    {
        [self.player play];
    }
}

- (IBAction)beginScrubbing:(id)sender
{
    restoreRate = self.player.rate;
    
	[self.player setRate:0.0];
	
	[self removeTimeObserverFromPlayer];
}

-(double)duration
{
    AVAsset *asset = self.player.currentItem.asset;
    
    if (!asset)
        return 0.0;
    
    return CMTimeGetSeconds([asset duration]);
}

- (IBAction)scrub:(id)sender
{	
   
        AVAsset *asset = self.player.currentItem.asset;
        
        if (!asset)
            return;
        
        double localDuration = CMTimeGetSeconds([asset duration]);
        
        if (isfinite(localDuration))
        {
            CGFloat width = CGRectGetWidth([slider bounds]);
            
            float value = [slider value];
            double time = localDuration*value;
            double tolerance = 1.0f * localDuration / width;
            
            [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) 
               toleranceBefore:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) 
                toleranceAfter:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)];
        }
	
}

- (IBAction)endScrubbing:(id)sender
{
	[self.player setRate:restoreRate];
    [self addTimeObserverToPlayer];
    [self playerUpdate];
}

-(void)shutdown
{
    if(timedObserver)
    {
        [[super player] removeTimeObserver:timedObserver];
        self.timedObserver =nil;
         [[super player] removeObserver:self forKeyPath:@"rate"];
        self.player = nil;
    }
}

-(void)playerUpdate
{	
    if(self.superview == nil)
    {
        [self shutdown];
    }
    else
    {
        double localDuration = CMTimeGetSeconds([self.player.currentItem.asset duration]);
        
        if (isfinite(localDuration))
        {
            positionTime = CMTimeGetSeconds([self.player currentTime]);
            position = positionTime / localDuration;
            [slider setValue:position];
            finished = (position == 1.0);
            volume = [MPMusicPlayerController iPodMusicPlayer].volume;
            
            if([self.player respondsToSelector:@selector(isAirPlayVideoActive)])
            {
                airplayActive = self.player.airPlayVideoActive;
            }
            else
            {
                airplayActive = NO;
            }
            self.airplayActiveView.hidden = !airplayActive;
            if(updateDelegate)
            {
                [self.delegate playerUpdate:self];
            }
        }
    }
}

-(IBAction)playButtonTapped:(id)sender
{
    UIButton* senderButton = (UIButton*)sender;
    if(playing)
    {
        [self.player pause];
    }
    else
    {
        [self.player play];
    }
    senderButton.selected = playing;
}
-(void)restoreVideoView
{
    [originalContainer addSubview:fullscreenContainer];
    fullscreenContainer.frame = orignalFrame;
}

-(IBAction)toggleFullScreen:(id)sender
{
    fullscreen = !fullscreen;
    
    if(fullscreen)
    {
        originalContainer = fullscreenContainer.superview;
        orignalFrame = fullscreenContainer.frame;
        
        [fullscreenRootView addSubview:fullscreenContainer];
        fullscreenContainer.frame = [fullscreenRootView convertRect:fullscreenContainer.frame fromView:originalContainer];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.25];
        fullscreenContainer.frame = fullscreenRootView.bounds;
        [UIView commitAnimations]; 
    }
    else
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(restoreVideoView)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.25];
        fullscreenContainer.frame =  [fullscreenRootView convertRect:orignalFrame fromView:originalContainer];
        [UIView commitAnimations]; 
    }
}

-(void)dealloc
{
    if(timedObserver)
    {
        if([super player])
        {
            [[super player] removeTimeObserver:timedObserver];
        }
    }
    ARC_RELEASE(videoURL);
    if([super player])
    {
        [[super player] removeObserver:self forKeyPath:@"rate"];
    }
    ARC_SUPER_DEALLOC;
}

@end
