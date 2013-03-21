//
//  WeakReference.h
//  State
//
//  Created by Lee Higgins on 25/02/2013.
//  Copyright (c) 2013 State. All rights reserved.
//
// code from here.....
// http://stackoverflow.com/questions/14209070/collections-of-zeroing-weak-references-under-arc/14219598#14219598


#import <Foundation/Foundation.h>

@interface WeakReference : NSObject {
    __weak id nonretainedObjectValue;
    __unsafe_unretained id originalObjectValue;
}

+ (WeakReference *) weakReferenceWithObject:(id) object;

- (id) nonretainedObjectValue;
- (void *) originalObjectValue;

@end
