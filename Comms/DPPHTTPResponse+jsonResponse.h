//
//  DPPHTTPResponse+jsonResponse.h
//  Created by Lee Higgins on 24/07/2012.
//

#import "DPPHTTPResponse.h"


@interface DPPHTTPResponse (JSONResponse)

+(NSString*)JSONcontentTypeString;
-(NSDictionary*)bodyJSON;

@end
