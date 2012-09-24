//
//  PlayerView.m
//  Stepwise
//
//  Created by Lee Higgins on 29/01/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "PlayerView.h"

#import <AVFoundation/AVFoundation.h>


@implementation PlayerView


+ (Class)layerClass
{
	return [AVPlayerLayer class];
}


- (AVPlayer*)player
{
	return [(AVPlayerLayer*)[self layer] player];
}


- (void)setPlayer:(AVPlayer*)player
{
	[(AVPlayerLayer*)[self layer] setPlayer:player];
}


@end