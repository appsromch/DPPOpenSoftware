//
//  NSObject+WhenIdle.m
//  
//
//  Created by Lee Higgins on 03/08/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "NSObject+WhenIdle.h"

#import <objc/runtime.h>
#define kPerformNotificationName @"performSelectorWhenIdleName"

@implementation NSObject (WhenIdle)

//LH broken do not use


-(void)performSelectorWhenIdle:(SEL)aSelector withObject:(id)anArgument
{
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[NSInvocation instanceMethodSignatureForSelector:aSelector]];
    invocation.target = self;
    if(anArgument)
    {
        [invocation setArgument:&anArgument atIndex:0];
    }
                                
    NSNotification* performNotification = [NSNotification notificationWithName:kPerformNotificationName object:self userInfo:[NSDictionary dictionaryWithObject:invocation forKey:@"invocation"]];
    [[NSNotificationCenter defaultCenter] enqueueNotification:performNotification postingStyle:NSPostWhenIdle]; 
}

-(void)didReceivePerformWheIdle:(NSNotification*)notification
{
    NSInvocation* invocation = [notification.userInfo objectForKey:@"invocation"];
    [invocation invoke];
}



@end
