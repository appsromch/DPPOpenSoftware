//
//  WeakReference.m
//  State
//
//  Created by Lee Higgins on 25/02/2013.
//  Copyright (c) 2013 State. All rights reserved.
//
// code from here.....
// http://stackoverflow.com/questions/14209070/collections-of-zeroing-weak-references-under-arc/14219598#14219598
#import "WeakReference.h"

@implementation WeakReference

- (id) initWithObject:(id) object {
    if (self = [super init]) {
        nonretainedObjectValue = originalObjectValue = object;
    }
    return self;
}

+ (WeakReference *) weakReferenceWithObject:(id) object {
    return [[self alloc] initWithObject:object];
}

- (id) nonretainedObjectValue { return nonretainedObjectValue; }
- (void *) originalObjectValue { return (__bridge void *) originalObjectValue; }

// To work appropriately with NSSet
- (BOOL) isEqual:(WeakReference *) object {
    if (![object isKindOfClass:[WeakReference class]]) return NO;
    return object.originalObjectValue == self.originalObjectValue;
}

-(NSUInteger)hash
{
    return (NSUInteger)nonretainedObjectValue;
}

@end
