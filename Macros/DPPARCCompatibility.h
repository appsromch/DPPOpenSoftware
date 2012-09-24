//
//  DPPARCCompatibility.h
//  DPPOpenSoftware
//
//  Created by Lee Higgins on 09/06/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#if __has_feature(objc_arc)
#define ARC_RETAIN(x) x
#define ARC_RELEASE(x)
#define ARC_AUTORELEASE(x) x
#define ARC_SUPER_DEALLOC
#else
#define ARC_WEAK assign
#define ARC_RETAIN(x) [x retain]
#define ARC_RELEASE(x) [x release]
#define ARC_AUTORELEASE(x) [x autorelease]
#define ARC_SUPER_DEALLOC [super dealloc]
#endif