//
//  DPPVector3D.m
//  
//
//  Created by Lee Higgins on 19/07/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "DPPVector3D.h"

@implementation DPPVector3D

@synthesize x;
@synthesize y;
@synthesize z;

-(float)angleBetween:(DPPVector3D*)with
{
	float vectorsMagnitude = [self length]* [with length];
	float angle = acos(  [self dotProduct:with] / vectorsMagnitude );
	return angle ;
}

-(DPPVector3D*)crossProduct:(DPPVector3D*)with
{
    DPPVector3D* vector = [[DPPVector3D alloc] init];
    
    vector.x =(y * with.z) - (z*with.y);
    vector.y = (z*with.x)- (x*with.z);
    vector.z =(x*with.y)-(y*with.x);
	return vector;
}

-(float)dotProduct:(DPPVector3D*)with
{
	return (x * with.x) + (y * with.y) + (z * with.z);
}

-(float)length
{
	return (float)sqrt((x*x)+(y*y)+(z*z));
}

-(float)lengthSquared
{
	return (x*x)+(y*y)+(z*z);
}

-(float)unit
{
	float len = [self length];
	if (len > 0)
	{
		x /= len;
		y /= len;
		z /= len;
	}
	return len;
}
@end
