//
//  DPPUIViewCamera3D.h
//  DPPConnectedApp
//
//  Created by Lee Higgins on 01/05/2013.
//  Copyright (c) 2013 DepthPerPixel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DPPUIViewWorld3D.h"

@interface DPPUIViewCamera3D : NSObject

@property(nonatomic,weak) UIView* renderView;//the view which contains the 'world'
@property(nonatomic,weak) UIView* targetView; // the anchor point of the view is the target.
@property(nonatomic,weak) UIViewController* targetController;

@property(nonatomic,assign) CGPoint3D targetPoint; //the camera always looks at this, it is updated when view targets are used...
@property(nonatomic,assign) CGPoint3D eyePoint;
@property(nonatomic,assign) CATransform3D transform;

-(void)moveToTargetController:(UIViewController*)targetController animationDuration:(NSTimeInterval)duration;
-(void)moveToTargetView:(UIView*)targetView animationDuration:(NSTimeInterval)duration; //move camera to look at view
-(void)moveToCamera:(DPPUIViewCamera3D*)camera animationDuration:(NSTimeInterval)duration; //move camera to another cameras position

-(void)orbitView:(UIView*)targetView horizontalRotation:(float)horizontalRotation verticalRotation:(float)verticalRotation;
-(void)orbitPoint:(CGPoint)targetPoint horizontalRotation:(float)horizontalRotation verticalRotation:(float)verticalRotation;
-(void)animateCameraWithKeyFrames:(NSArray*)cameraKeyframes keyTimings:(NSArray*)keyTimings;

+(DPPUIViewCamera3D*)cameraForTargetView:(UIView*)view;

@end
