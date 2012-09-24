//
//  UIImage+DPPHTTPRequestResource.h
//  
//
//  Created by Lee Higgins on 18/08/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (DPPHTTPRequestResource)


@property(nonatomic,strong)  NSURL* remoteResourceURL;
@property(nonatomic,strong)  UIImage* offlineImage;
@property(nonatomic,strong)  UIImage* placeholderImage;



@end
