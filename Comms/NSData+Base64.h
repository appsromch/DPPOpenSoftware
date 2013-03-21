//
//  NSData+Base64.h
//  
//  Created by Lee Higgins on 26/07/2012.
//

#import <Foundation/Foundation.h>
#import "Base64Lookup.h"

@interface NSData (Base64)

-(NSString *) base64EncodedString;
+(NSData *) dataWithBase64EncodedString:(NSString *)encodedString;

@end
