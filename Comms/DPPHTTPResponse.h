//
//  DPPHTTPResponse.h
//  Created by Lee Higgins on 15/04/2012.
//

#import <Foundation/Foundation.h>

@interface DPPHTTPResponse : NSObject

@property(nonatomic,retain)     NSHTTPURLResponse*  header;
@property(nonatomic,retain)     NSData*             body;
@property(nonatomic,readonly)   NSString*           bodyString;
@property(nonatomic,retain)     NSInputStream*      bodyStream;
@property(nonatomic,retain)     id                  processedBody;
@property(nonatomic,assign)     BOOL isValid;

@end
