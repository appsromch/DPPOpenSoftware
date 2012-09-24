//
//  DPPActivityView.h
//  TalkTalkXfactor
//
//  Created by Lee Higgins on 20/08/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPPActivityView : UIView

@property(nonatomic,weak) IBOutlet UIView* spinnerView;

@property(nonatomic,assign) BOOL animating;

-(void)startAnimating;

@end
