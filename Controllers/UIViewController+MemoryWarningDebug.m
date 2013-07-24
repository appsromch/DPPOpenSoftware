//
//  UIViewController+MemoryWarningDebug.m
//  State
//
//  Created by Lee Higgins on 02/04/2013.
//  Copyright (c) 2013 State. All rights reserved.
//

#import "UIViewController+MemoryWarningDebug.h"
#import <objc/runtime.h>
#import <objc/message.h>
//....

void Swizzle(Class c, SEL orig, SEL new)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

@implementation UIViewController (MemoryWarningDebug)


+(void)load
{
    Swizzle(self, @selector(viewDidUnload),  @selector(swizzleViewDidUnload));
     Swizzle(self, @selector(viewDidLoad),  @selector(swizzleViewDidLoad));
     Swizzle(self, @selector(didReceiveMemoryWarning),  @selector(swizzleMemory));
}

-(void)swizzleViewDidLoad
{
     [self swizzleViewDidLoad];
    NSLog(@"%@ class viewDidLoad",[self class]);
   
    
}

-(void)swizzleViewDidUnLoad
{
      [self swizzleViewDidUnLoad];
    NSLog(@"%@ class viewDidUnload",[self class]);
  
}

-(void)swizzleMemory
{
     
    [self swizzleMemory];
    NSLog(@"%@ class MemoryWarning",[self class]);
   
   
}


@end
