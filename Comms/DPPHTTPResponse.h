//
//  DPPHTTPResponse.h
//  Created by Lee Higgins on 15/04/2012.
//

#import <Foundation/Foundation.h>

@interface DPPHTTPResponse : NSObject

@property(nonatomic,strong)     NSHTTPURLResponse*  header;
@property(nonatomic,strong)     NSData*             body;
@property(nonatomic,readonly)   NSString*           bodyString;
@property(nonatomic,strong)     NSInputStream*      bodyStream;
@property(nonatomic,strong)     id                  processedBody;
@property(nonatomic,assign)     BOOL                isValid;
@property(nonatomic,strong)     NSError*            error;          //can store parsing errors etc eher... 

@end
