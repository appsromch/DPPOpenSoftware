//
//  NSObject+Runtime.m
//
//  Created by Lee Higgins on 11/04/2013.
//  Copyright (c) 2013 DepthPerPixel. All rights reserved.
//

#import "NSObject+Runtime.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (Runtime)

-(NSArray*)allSubclasses
{//LH grab all the subclasses of this class.
        Class parentClass = [self class];
        int numClasses = objc_getClassList(NULL, 0);
        Class *classes = NULL;
        
        classes =  (Class*)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        
        NSMutableArray *result = [NSMutableArray array];
        for (NSInteger i = 0; i < numClasses; i++)
        {
            Class superClass = classes[i];
            do
            {
                superClass = (Class)class_getSuperclass(superClass);
            } while(superClass && superClass != parentClass);
            
            if (superClass == nil)
            {
                continue;
            }
            
            [result addObject:classes[i]];
        }
        
        free(classes);
        
        return result;
}

@end
