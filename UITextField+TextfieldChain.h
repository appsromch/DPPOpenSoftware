//
//  UITextField+TextfieldChain.h
//  TalkTalkXfactor
//
//  Created by Lee Higgins on 02/08/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (TextfieldChain)

@property(nonatomic,strong) IBOutlet UITextField* nextTextField;

@end
