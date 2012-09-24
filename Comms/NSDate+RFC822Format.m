//
//  NSDate+RFC822Format.m
//  
//
//  Created by Lee Higgins on 26/07/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "NSDate+RFC822Format.h"

#define kRFC822DateFormat            @"EEE, dd MMM yyyy HH:mm:ss z"

@implementation NSDate (RFC822Format)

-(NSString *)stringWithRFC822Format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormatter setDateFormat:kRFC822DateFormat];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSString *formatted = [dateFormatter stringFromDate:self];
    
    return formatted;
}

@end
