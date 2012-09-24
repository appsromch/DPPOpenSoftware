//
//  DPPStreamBuffer.m
//  ContactsTest
//
//  Created by Lee Higgins on 07/05/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "DPPStreamBuffer.h"
#import "DPPARCCompatibility.h"

@interface DPPStreamBuffer()

- (void)createBoundInputStream:(NSInputStream **)inputStreamPtr outputStream:(NSOutputStream **)outputStreamPtr bufferSize:(NSUInteger)bufferSize;

@end

@implementation DPPStreamBuffer

@synthesize bufferSize;
@synthesize input;
@synthesize output;

+(DPPStreamBuffer*)streamBufferWithSize:(NSUInteger)sizeBytes
{
    return ARC_AUTORELEASE([[DPPStreamBuffer alloc] initWithSize:sizeBytes]);
}

+(DPPStreamBuffer*)streamBufferWithSizeKB:(float)sizeKBytes
{
    return [self streamBufferWithSize:1024.0*sizeKBytes];
}

+(DPPStreamBuffer*)streamBufferWithSizeMB:(float)sizeMBytes
{
    return [self streamBufferWithSizeKB:1024.0*sizeMBytes];
}

-(DPPStreamBuffer*)initWithSize:(NSUInteger)sizeBytes
{
    self = [super init];
    if(self)
    {
        self.bufferSize = sizeBytes;
    }
    return self;
}

- (void)createBoundInputStream:(NSInputStream **)inputStreamPtr outputStream:(NSOutputStream **)outputStreamPtr bufferSize:(NSUInteger)newBufferSize
{
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    
    assert( (inputStreamPtr != NULL) || (outputStreamPtr != NULL) );
    
    readStream = NULL;
    writeStream = NULL;
    
    CFStreamCreateBoundPair(
                            NULL, 
                            ((inputStreamPtr  != nil) ? &readStream : NULL),
                            ((outputStreamPtr != nil) ? &writeStream : NULL), 
                            (CFIndex) newBufferSize);
    
    if (inputStreamPtr != NULL) {
        *inputStreamPtr  = (__bridge_transfer NSInputStream*)readStream;
        [*inputStreamPtr open];
    }
    if (outputStreamPtr != NULL) {
        *outputStreamPtr = (__bridge_transfer NSOutputStream*)writeStream;
        [*outputStreamPtr open];
    }
}

-(NSInputStream*)output
{//lazy load
    if(output==nil)
    {
        NSInputStream* inputStream = nil;
        NSOutputStream* outputStream = nil;
        
        [self createBoundInputStream:&inputStream outputStream:&outputStream bufferSize:bufferSize];
        
        self.output = inputStream;
        self.input = outputStream;
    }
    return output;
}

-(NSOutputStream*)input
{//lazy load
    if(input==nil)
    {
        NSInputStream* inputStream = nil;
        NSOutputStream* outputStream = nil;
        
        [self createBoundInputStream:&inputStream outputStream:&outputStream bufferSize:bufferSize];
        
        self.output = inputStream;
        self.input = outputStream;
    }
    return input;
}
-(void)dealloc
{
    [input close];
    [output close];
    ARC_RELEASE(input);
    ARC_RELEASE(output);
    ARC_SUPER_DEALLOC;
}

@end
