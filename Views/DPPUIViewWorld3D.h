//
//  DPPUIViewWorld3D.h
//  DPPConnectedApp
//
//  Created by Lee Higgins on 01/05/2013.
//  Copyright (c) 2013 DepthPerPixel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DPP3D.h"

@class DPPUIViewCamera3D;

@interface DPPUIViewWorld3D : NSObject

@property(nonatomic,strong) UIView* worldView;
@property(nonatomic,strong) DPPUIViewCamera3D* camera;

-(void)addView:(UIView*)view;
-(void)addController:(UIViewController*)controller atPosition:(CGPoint3D)position;

-(void)removeView:(UIView*)view;
-(void)removeController:(UIViewController*)controller;

@end
