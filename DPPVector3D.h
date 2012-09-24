//
//  DPPVector3D.h
//  
//
//  Created by Lee Higgins on 19/07/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPPVector3D : NSObject

@property(nonatomic,assign) float x;
@property(nonatomic,assign) float y;
@property(nonatomic,assign) float z;

-(float)angleBetween:(DPPVector3D*)with;
-(DPPVector3D*)crossProduct:(DPPVector3D*)with;
-(float)dotProduct:(DPPVector3D*)with;
-(float)length;
-(float)lengthSquared;
-(float)unit;

@end
