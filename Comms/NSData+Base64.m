//
//  NSData+Base64.m
//  TalkTalkXfactor
//
//  Created by Lee Higgins on 26/07/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "NSData+Base64.h"

@implementation NSData (Base64)

-(NSString *) base64EncodedString
{
NSMutableString *result;
unsigned char   *raw;
unsigned long   length;
short           i, nCharsToWrite;
long            cursor;
unsigned char   inbytes[3], outbytes[4];

length = [self length];

if (length < 1) {
    return @"";
}

result = [NSMutableString stringWithCapacity:length];
raw    = (unsigned char *)[self bytes];
// Take 3 chars at a time, and encode to 4
for (cursor = 0; cursor < length; cursor += 3) {
    for (i = 0; i < 3; i++) {
        if (cursor + i < length) {
            inbytes[i] = raw[cursor + i];
        }
        else{
            inbytes[i] = 0;
        }
    }
    
    outbytes[0] = (inbytes[0] & 0xFC) >> 2;
    outbytes[1] = ((inbytes[0] & 0x03) << 4) | ((inbytes[1] & 0xF0) >> 4);
    outbytes[2] = ((inbytes[1] & 0x0F) << 2) | ((inbytes[2] & 0xC0) >> 6);
    outbytes[3] = inbytes[2] & 0x3F;
    
    nCharsToWrite = 4;
    
    switch (length - cursor) {
        case 1:
            nCharsToWrite = 2;
            break;
            
        case 2:
            nCharsToWrite = 3;
            break;
    }
    for (i = 0; i < nCharsToWrite; i++) {
        [result appendFormat:@"%c", base64EncodingTable[outbytes[i]]];
    }
    for (i = nCharsToWrite; i < 4; i++) {
        [result appendString:@"="];
    }
}

return [NSString stringWithString:result]; // convert to immutable string
}

+(NSData *) dataWithBase64EncodedString:(NSString *)encodedString
{
    if (nil == encodedString || [encodedString length] < 1) {
        return [NSData data];
    }
    
    const char    *inputPtr;
    unsigned char *buffer;
    
    int           length;
    
    inputPtr = [encodedString cStringUsingEncoding:NSASCIIStringEncoding];
    length   = strlen(inputPtr);
    char ch;
    int  inputIdx = 0, outputIdx = 0, padIdx;
    
    buffer = (unsigned char*)calloc(length, sizeof(unsigned char));
    
    while (((ch = *inputPtr++) != '\0') && (length-- > 0)) {
        if (ch == '=') {
            if (*inputPtr != '=' && ((inputIdx % 4) == 1)) {
                free(buffer);
                return nil;
            }
            continue;
        }
        
        ch = base64DecodingTable[ch];
        
        if (ch < 0) { // whitespace or other invalid character
            continue;
        }
        
        switch (inputIdx % 4) {
            case 0:
                buffer[outputIdx] = ch << 2;
                break;
                
            case 1:
                buffer[outputIdx++] |= ch >> 4;
                buffer[outputIdx]    = (ch & 0x0f) << 4;
                break;
                
            case 2:
                buffer[outputIdx++] |= ch >> 2;
                buffer[outputIdx]    = (ch & 0x03) << 6;
                break;
                
            case 3:
                buffer[outputIdx++] |= ch;
                break;
        }
        
        inputIdx++;
    }
    
    padIdx = outputIdx;
    
    if (ch == '=') {
        switch (inputIdx % 4) {
            case 1:
                free(buffer);
                return nil;
                
            case 2:
                padIdx++;
                
            case 3:
                buffer[padIdx] = 0;
        }
    }
    
    NSData *objData = [[NSData alloc] initWithBytes:buffer length:outputIdx];
    free(buffer);
    return objData;
}

@end
