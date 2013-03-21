//
//  DPPHTTPResponse.m
//  Created by Lee Higgins on 15/04/2012.
//

#import "DPPHTTPResponse.h"

@implementation DPPHTTPResponse

@synthesize body;
@synthesize header;
@synthesize bodyStream;
@synthesize processedBody;
@synthesize isValid;

@dynamic bodyString;


-(NSString*)bodyString
{
    if(body)
    {
        NSStringEncoding stringEncoding = NSUTF8StringEncoding;
        if (self.header.textEncodingName) {
            CFStringEncoding IANAEncoding = CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef)self.header.textEncodingName);
            if (IANAEncoding != kCFStringEncodingInvalidId) {
                stringEncoding = CFStringConvertEncodingToNSStringEncoding(IANAEncoding);
            }
        }
        return [[NSString alloc] initWithData:body encoding:stringEncoding]; 
    }
    return nil;
}


@end
