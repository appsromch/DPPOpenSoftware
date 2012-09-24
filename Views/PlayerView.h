//
//  PlayerView.h
//  Stepwise
//
//  Created by Lee Higgins on 29/01/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;

@interface PlayerView : UIView

@property (nonatomic, retain) AVPlayer* player;

@end