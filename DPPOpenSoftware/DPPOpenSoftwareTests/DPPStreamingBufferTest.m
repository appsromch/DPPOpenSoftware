//
//  DPPStreamingBufferTest.m
//  DPPOpenSoftware
//
//  Created by Lee Higgins on 09/06/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "DPPStreamingBufferTest.h"
#import "DPPStreamBuffer.h"

@implementation DPPStreamingBufferTest

@synthesize testBuffer;

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    
    self.testBuffer = [DPPStreamBuffer streamBufferWithSizeMB:1];
}

- (void)tearDown
{
    // Tear-down code here.
    self.testBuffer = nil;
    [super tearDown];
}

-(void)testWriteData:(NSNumber*)blockingObj
{
     NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSUInteger byteCount = 0;
    uint8_t byte =0;
    BOOL blocking = [blockingObj boolValue];
    
    while(([testBuffer.input hasSpaceAvailable] || blocking) && byteCount < testBuffer.bufferSize)
    {
        byte = byteCount % 255;
        
        byteCount+=[testBuffer.input write:&byte maxLength:1];
    }
    
    if(byteCount != testBuffer.bufferSize)
    {
        STFail(@"Less bytes added than expected!");
    }
    [pool drain];
}

-(void)testReadData:(NSNumber*)blockingObj
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSUInteger byteCount = 0;
    uint8_t byte =0;
     BOOL blocking = [blockingObj boolValue];
    
    byteCount = 0;
    
    NSInteger readCount;
    
    while(([testBuffer.output hasBytesAvailable] || blocking) && byteCount < testBuffer.bufferSize)
    {
        readCount = [testBuffer.output read:&byte maxLength:1];
        if(readCount>0)
        {
            if(byte != byteCount % 255)
            {
                STFail(@"Unexpected Data! Got %d instead of %d",byte,byteCount % 255);
            }
            byteCount+=readCount;
        }
    }
    
    if(byteCount != testBuffer.bufferSize)
    {
        STFail(@"Less bytes added than expected!");
    } 
    [pool drain];
}

- (void)testBufferFullSingleThread
{
    
    [self testWriteData:NO];
    [self testReadData:NO];
    
    NSLog(@"testBufferFullSingleThread Complete.");
    
}

- (void)testBufferFullMultiThread
{
    
    NSThread* threadOne = [[NSThread alloc] initWithTarget:self selector:@selector(testWriteData:) object:[NSNumber numberWithBool:YES]];
    NSThread* threadTwo = [[NSThread alloc] initWithTarget:self selector:@selector(testReadData:) object:[NSNumber numberWithBool:YES]];

    
    [threadTwo start];
    [threadOne start];
    
    
    while(![threadTwo isFinished])
    {
        NSLog(@"Waiting for Threads to finish");
        [[NSRunLoop mainRunLoop] runUntilDate:[[NSDate date] dateByAddingTimeInterval:0.5]];
    }

    NSLog(@"testBufferFullMultiThread Complete.");
    
    
    [threadOne release];
    [threadTwo release];
}

@end
