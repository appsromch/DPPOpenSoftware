//
//  NSObject+RateLimitedPerform.m
//  State
//
//  Created by Lee Higgins on 08/11/2012.
//  Copyright (c) 2012 State. All rights reserved.
//

#import "NSObject+RateLimitedPerform.h"
#import <objc/runtime.h>

static NSString* kSelectorLastSentLookup = @"selectorLastSentLookup";

@implementation NSObject (RateLimitedPerform)


-(void)performSelector:(SEL)selector withObject:(id)object limitingRate:(float)minTimeBetweenInSec
{
    if(-[[self lastPerformedSelector:selector] timeIntervalSinceNow] > minTimeBetweenInSec)
    {
        [[self selectorLastSentLookup] setObject:[NSDate date] forKey:NSStringFromSelector(selector)];
        //Fix to get rid of the warning
        // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
               [self performSelector:selector withObject:object];
        #pragma clang diagnostic pop
    }
}

-(void)resetPerformSelectorLimitingRate:(SEL)selector
{
   [[self selectorLastSentLookup] setObject:[NSDate distantPast] forKey:NSStringFromSelector(selector)];
}

-(NSMutableDictionary*)selectorLastSentLookup
{
    NSMutableDictionary* lookup = objc_getAssociatedObject(self, &kSelectorLastSentLookup);
    if(lookup ==nil)
    {
        lookup = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &kSelectorLastSentLookup,lookup, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return lookup;
}

-(NSDate*)lastPerformedSelector:(SEL)selector
{
    NSDate* lastPerformed = [[self selectorLastSentLookup] valueForKey:NSStringFromSelector(selector)];
    if(lastPerformed ==nil)
    {
        return [NSDate distantPast];
    }
    return lastPerformed;
}

@end
