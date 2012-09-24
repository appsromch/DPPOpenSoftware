//
//  DPPHTTPResponse.h
//  Rovio
//
//  Created by Lee Higgins on 15/04/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPPHTTPResponse : NSObject

@property(nonatomic,retain)     NSHTTPURLResponse*  header;
@property(nonatomic,retain)     NSData*             body;
@property(nonatomic,readonly)   NSString*           bodyString;
@property(nonatomic,retain)     NSInputStream*     bodyStream;

@end
