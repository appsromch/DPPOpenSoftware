//
//  DPPHTTPResponse.m
//  Rovio
//
//  Created by Lee Higgins on 15/04/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "DPPHTTPResponse.h"

@implementation DPPHTTPResponse

@synthesize body;
@synthesize header;
@synthesize bodyStream;
@dynamic bodyString;


-(NSString*)bodyString
{
    if(body)
    {
        //TODO: detect string encoding.....
        return [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding]; 
    }
    return nil;
}


@end
