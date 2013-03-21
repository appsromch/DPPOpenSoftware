//
//  NSDate+ISO8601.h
//
//  Created by Lee Higgins on 10/10/2012.
//

#import <Foundation/Foundation.h>

@interface NSDate (ISO8601)

+(NSDate *) dateFromISO8601:(NSString *) str;
+(NSString *)ISO8601FromDate:(NSDate *)date;

@end
