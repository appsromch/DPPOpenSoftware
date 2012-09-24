//
//  DPPStreamBuffer.h
//  ContactsTest
//
//  Created by Lee Higgins on 07/05/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPPStreamBuffer : NSObject

@property(nonatomic,strong) NSInputStream* output;
@property(nonatomic,strong) NSOutputStream* input;
@property(nonatomic,assign) NSUInteger bufferSize;


+(DPPStreamBuffer*)streamBufferWithSize:(NSUInteger)sizeBytes;
+(DPPStreamBuffer*)streamBufferWithSizeKB:(float)sizeKBytes;
+(DPPStreamBuffer*)streamBufferWithSizeMB:(float)sizeMBytes;

-(DPPStreamBuffer*)initWithSize:(NSUInteger)sizeBytes;

@end
