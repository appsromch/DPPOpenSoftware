//
//  DPPQuadTree3D.h
//  DPPConnectedApp
//
//  Created by Lee Higgins on 01/05/2013.
//  Copyright (c) 2013 DepthPerPixel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPP3D.h"

@interface DPPQuadTree3D : NSObject

-(void)addObject:(id)object position:(CGPoint3D)position;
-(void)removeObject:(id)object;

-(void)moveObject:(id)object position:(CGPoint3D)position;

-(NSArray*)objectsAtPoint:(CGPoint3D)position;

@end
