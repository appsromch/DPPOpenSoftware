//
//  NSDate+ISO8601.m
//
//  Created by Lee Higgins on 10/10/2012.
//

#import "NSDate+ISO8601.h"

@implementation NSDate (ISO8601)

+(NSDate *) dateFromISO8601:(NSString *) str {
    if(str ==nil) return nil;
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [df setLocale:[NSLocale currentLocale]];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSDate *parsedDate = [df dateFromString:str];
    df=nil;
    return parsedDate;
}

+(NSString *)ISO8601FromDate:(NSDate *)date
{
    if (date == nil)
        return nil;
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [df setLocale:[NSLocale currentLocale]];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSString *string = [df stringFromDate:date];
    df=nil;
    return string;
}

@end
