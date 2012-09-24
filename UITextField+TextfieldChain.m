//
//  UITextField+TextfieldChain.m
//  TalkTalkXfactor
//
//  Created by Lee Higgins on 02/08/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "UITextField+TextfieldChain.h"
#import <objc/runtime.h>

static NSString* kTextfieldChain_nextTextField = @"TextfieldChain_nextTextField";

@implementation UITextField (TextfieldChain)

@dynamic nextTextField;


-(void)setNextTextField:(UITextField *)nextTextField
{
    objc_setAssociatedObject(self, &kTextfieldChain_nextTextField,nextTextField, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UITextField*)nextTextField
{
    return objc_getAssociatedObject(self, &kTextfieldChain_nextTextField);
}

@end
