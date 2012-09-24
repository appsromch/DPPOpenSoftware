//
//  NSString+URLEncoding.h
//  TalkTalkXfactor
//
//  Created by Lee Higgins on 27/07/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncoding)
+(NSString*)urlEscapeString:(NSString *)unencodedString;
+(NSString*)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary;
@end
