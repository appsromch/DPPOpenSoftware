//
//  NSString+Base64.m
//  TalkTalkXfactor
//
//  Created by Lee Higgins on 26/07/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "NSString+Base64.h"

static unsigned char base64EncodeLookup[65] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation NSString (Base64)




-(NSString*)base64String
{
//
// Inner loop: turn 3 bytes into 4 base64 characters
//
    
    const char* inputBuffer = [self UTF8String];
    char* outputBuffer = malloc([self length]);
    int j=0;
    for(int i=0;i<[self length];i+=3)
    {
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
                                       | ((inputBuffer[i + 1] & 0xF0) >> 4)];
        outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i + 1] & 0x0F) << 2)
                                       | ((inputBuffer[i + 2] & 0xC0) >> 6)];
        outputBuffer[j++] = base64EncodeLookup[inputBuffer[i + 2] & 0x3F];
    }
    outputBuffer[[self length]-1] = '\0';
    NSString* base64String=[NSString stringWithUTF8String:outputBuffer];
    free(outputBuffer);
    return base64String; 
}

@end
