//
//  NSObject+RateLimitedPerform.h
//  State
//
//  Created by Lee Higgins on 08/11/2012.
//  Copyright (c) 2012 State. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (RateLimitedPerform)

//only perform this selector if its not been performed in the last minTimeBetweenInSec seconds

-(void)performSelector:(SEL)selector withObject:(id)object limitingRate:(float)minTimeBetween;
-(void)resetPerformSelectorLimitingRate:(SEL)selector;
@end
