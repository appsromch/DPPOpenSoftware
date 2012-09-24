//
//  NSObject+WhenIdle.h
//  TalkTalkXfactor
//
//  Created by Lee Higgins on 03/08/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (WhenIdle)


-(void)performSelectorWhenIdle:(SEL)aSelector withObject:(id)anArgument;

@end
