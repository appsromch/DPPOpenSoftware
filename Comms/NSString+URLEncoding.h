//
//  NSString+URLEncoding.h
//  
//  Created by Lee Higgins on 27/07/2012.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncoding)
+(NSString*)urlEscapeString:(NSString *)unencodedString;
+(NSString*)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary;
@end
