//
//  DPPHTTPRequest+DPPHTTPRequest_AWSS3.h
//  
//
//  Created by Lee Higgins on 25/07/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "DPPHTTPRequest.h"

@interface DPPHTTPRequest (AWSS3)

+(NSString*)fileMD5:(NSString*)path withChunkSize:(NSUInteger)chunkSize;

+(DPPHTTPRequest*)uploadFileToS3:(NSURL*)fileURL toURL:(NSURL*)url withKey:(NSString*)key secret:(NSString*)secret contentType:(NSString*)contentType;

@end
