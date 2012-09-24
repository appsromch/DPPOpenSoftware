//
//  UIImage+DPPHTTPRequestResource.m
//  
//
//  Created by Lee Higgins on 18/08/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "UIImageView+DPPHTTPRequestResource.h"

#import "DPPHTTPRequest.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

static char const * const kUIImageView_offlineImage = "kUIImageView_offlineImage"; ///we just need a uid (memory address of this static)
static char const * const kUIImageView_placeholderImage = "kUIImageView_placeholderImage";
static char const * const kUIImageView_remoteresource = "kUIImageView_remoteresource";
static char const * const kUIImageView_remoteResourceRequest = "kUIImageView_remoteResourceRequest";

@implementation UIImageView (DPPHTTPRequestResource)


@dynamic remoteResourceURL;
@dynamic offlineImage;
@dynamic placeholderImage;


-(void)setOfflineImage:(UIImage *)offlineImage
{
    objc_setAssociatedObject(self, &kUIImageView_offlineImage,offlineImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setPlaceholderImage:(UIImage *)placeholderImage
{
    objc_setAssociatedObject(self, &kUIImageView_placeholderImage,placeholderImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIImage*)placeholderImage
{
    return objc_getAssociatedObject(self, &kUIImageView_placeholderImage);
}
-(UIImage*)offlineImage
{
    return objc_getAssociatedObject(self, &kUIImageView_offlineImage);
}

-(void)setRemoteResourceURL:(NSURL*)resourceURL
{
    if(![resourceURL isEqual:self.remoteResourceURL])
    {
        self.image = self.placeholderImage;
        DPPHTTPRequest* oldRequest = objc_getAssociatedObject(self, &kUIImageView_remoteResourceRequest);
        [oldRequest cancel];
        
        objc_setAssociatedObject(self, &kUIImageView_remoteresource,resourceURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        DPPHTTPRequest* imageDownload = [DPPHTTPRequest httpGETRequestWithURL:resourceURL];
        
        objc_setAssociatedObject(self, &kUIImageView_remoteResourceRequest,imageDownload, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
       
        imageDownload.didRecieveResponseBlockOnBackground = ^(DPPHTTPRequest* request)
        {
            if(request.response.header.statusCode == 200)
            {
                UIImage* image = [[UIImage alloc] initWithData:request.response.body];
                
                UIGraphicsBeginImageContext(CGSizeMake(10, 10)); // this isn't that important since you just want UIImage to decompress the image data before switching back to main thread
                [image drawAtPoint:CGPointZero];
                UIGraphicsEndImageContext();
                if(!request.cached)//no cached response so animate in....
                {
                    [self performSelectorOnMainThread:@selector(animateSetImage:)  withObject:image waitUntilDone:NO];
                }
                else
                {
                     [self performSelectorOnMainThread:@selector(setImage:)  withObject:image waitUntilDone:NO];
                }
            }
            else
            {
                
            }
        };
        
        imageDownload.didFailToRecieveResponseBlock = ^(DPPHTTPRequest* request,NSError* error)
        {
          if([error.domain isEqualToString:@"NSURLErrorDomain"])
          {
              if(error.code == -1009)
              {
                  UIImage* image = self.offlineImage;
                  [self animateSetImage:image];
              }
          }
        };
        [imageDownload start];
    }
}

-(void)animateSetImage:(UIImage*)image
{
    self.image = image;
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.layer addAnimation:transition forKey:nil];
}

-(UITextField*)remoteResourceURL
{
    return objc_getAssociatedObject(self, &kUIImageView_remoteresource);
}

@end
