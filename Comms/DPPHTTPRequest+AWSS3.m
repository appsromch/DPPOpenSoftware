//
//  DPPHTTPRequest+DPPHTTPRequest_AWSS3.m
//  
//
//  Created by Lee Higgins on 25/07/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "DPPHTTPRequest+AWSS3.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSDate+RFC822Format.h"
#import "NSString+Base64.h"
#import "NSData+Base64.h"

@implementation DPPHTTPRequest (AWSS3)




+(NSString *) HMACSign:(NSData *)data withKey:(NSString *)key usingAlgorithm:(CCHmacAlgorithm)algorithm
{
    CCHmacContext context;
    const char    *keyCString = [key cStringUsingEncoding:NSASCIIStringEncoding];
    
    CCHmacInit(&context, algorithm, keyCString, strlen(keyCString));
    CCHmacUpdate(&context, [data bytes], [data length]);
    
    // Both SHA1 and SHA256 will fit in here
    unsigned char digestRaw[CC_SHA256_DIGEST_LENGTH];
    
    int           digestLength;
    
    switch (algorithm) {
        case kCCHmacAlgSHA1:
            digestLength = CC_SHA1_DIGEST_LENGTH;
            break;
            
        case kCCHmacAlgSHA256:
            digestLength = CC_SHA256_DIGEST_LENGTH;
            break;
            
        default:
            digestLength = -1;
            break;
    }
    
    if (digestLength < 0) {
        return nil;
    }
    
    CCHmacFinal(&context, digestRaw);
    
    NSData *digestData = [NSData dataWithBytes:digestRaw length:digestLength];
    
    return [digestData base64EncodedString];
}

+(NSString*)fileMD5:(NSString*)path withChunkSize:(NSUInteger)chunkSize
{
     NSInputStream* inputStream = [NSInputStream inputStreamWithFileAtPath:path];
    [inputStream open];
	if ( [inputStream streamStatus] == NSStreamStatusOpen) {
        CC_MD5_CTX hashObject;
        CC_MD5_Init(&hashObject);
        
        uint8_t buffer[chunkSize];
        while ( [inputStream hasBytesAvailable]) {
            NSInteger result = [inputStream read:buffer maxLength:chunkSize];
            
            if (result == -1) {
                return nil;
            }
            
            CC_MD5_Update(&hashObject, (const void *)buffer, (CC_LONG)result);
        }
        
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5_Final(digest, &hashObject);
        
        NSData *md5 = [[NSData alloc] initWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
        return [md5 base64EncodedString];
    }
    
    return nil;
}

+(DPPHTTPRequest*)uploadFileToS3:(NSURL*)fileURL toURL:(NSURL*)url withKey:(NSString*)key secret:(NSString*)secret contentType:(NSString*)contentType
{
    //  NSLog(@"\n\nUpload URL %@ (%@)\n\n",url,fileURL);
    
    DPPHTTPRequest* uploadRequest = [DPPHTTPRequest httpPUTRequestWithURL:url putFile:fileURL withContentType:contentType];
    //NSString* fileMD5 = [self fileMD5:fileURL.path withChunkSize:32*1024]; //LH 32k
    
    NSUInteger fileLength = [[[[NSFileManager defaultManager] attributesOfItemAtPath:fileURL.path error:nil] valueForKey:NSFileSize] intValue];
    NSString* rfc822Date = [[NSDate date] stringWithRFC822Format];
    
    NSString* contentMd5 = @"";//[fileMD5 base64String];
    NSString* timestamp = rfc822Date;
    NSString* canonicalizedResource = [url relativePath];
    
    
    [uploadRequest.headerValues setObject:timestamp forKey:@"Date"];
    [uploadRequest.headerValues setObject:@"public-read" forKey:@"x-amz-acl"];
  //  [uploadRequest.headerValues setObject:contentMd5 forKey:@"Content-MD5"];
    [uploadRequest.headerValues setObject:[NSString stringWithFormat:@"%d",fileLength] forKey:@"Content-Length"];
    
    
    NSMutableString *canonicalizedAmzHeaders = [NSMutableString stringWithFormat:@""];
    
    NSArray         *sortedHeaders = [[uploadRequest.headerValues allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (id key in sortedHeaders)
    {
        NSString *keyName = [(NSString *) key lowercaseString];
        if ([keyName hasPrefix:@"x-amz-"]) {
            [canonicalizedAmzHeaders appendFormat:@"%@:%@\n", keyName, [uploadRequest.headerValues objectForKey:key]];
        }
    }
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@%@", kHTTP_PUT_METHOD_STRING, contentMd5, contentType, timestamp, canonicalizedAmzHeaders, canonicalizedResource];
    
    NSString* signature = [self HMACSign:[stringToSign dataUsingEncoding:NSASCIIStringEncoding] withKey:secret usingAlgorithm:kCCHmacAlgSHA1];
    
    [uploadRequest.headerValues setObject:[NSString stringWithFormat:@"AWS %@:%@",key,signature] forKey:@"Authorization"];
    return uploadRequest;
}

@end
