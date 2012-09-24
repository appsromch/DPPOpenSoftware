//
//  UIImage+imageResize.h
//  TalkTalkXfactor
//
//  Created by Lee Higgins on 02/08/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (imageResize)

+(UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize;

@end
