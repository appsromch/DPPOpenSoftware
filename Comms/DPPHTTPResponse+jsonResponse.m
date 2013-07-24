//
//  DPPHTTPResponse+jsonResponse.m
//  
//
//  Created by Lee Higgins on 24/07/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "DPPHTTPResponse+jsonResponse.h"
#import "DPPHTTPRequest.h"
@implementation DPPHTTPResponse (JSONResponse)


+(NSString*)JSONcontentTypeString
{
    return kHTTPContentTypeJSON;
}

-(NSDictionary*)bodyJSON
{
    NSError* error=nil;
    if(self.processedBody == nil)
    {
        id jsonData = [NSJSONSerialization JSONObjectWithData:self.body options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments  error:&error];
                           
        NSDictionary*   jsonDict = nil;
        
        if(error)
        {
            return nil;
        }

        if([jsonData isKindOfClass:[NSArray class]])
        {//if we are an array put us in a root dictionary
           jsonDict = [NSMutableDictionary dictionaryWithObject:jsonData forKey:@"root"];
        }
        else 
        {
           jsonDict = jsonData;
        }
        self.processedBody = jsonDict;
    }
    return self.processedBody;
}

@end
