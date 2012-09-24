//
//  DPPHTTPResponse+jsonResponse.h
//  TalkTalkXfactor
//
//  Created by Lee Higgins on 24/07/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "DPPHTTPResponse.h"


@interface DPPHTTPResponse (JSONResponse)

+(NSString*)JSONcontentTypeString;
-(NSDictionary*)bodyJSON;

@end
