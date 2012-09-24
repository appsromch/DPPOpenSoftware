//
//  DPPHTTPRequest.h
//  Rovio
//
//  Created by Lee Higgins on 15/04/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPPHTTPResponse.h"

#define kHTTP_PUT_METHOD_STRING @"PUT"
#define kHTTP_POST_METHOD_STRING @"POST"
#define kHTTP_GET_METHOD_STRING @"GET"
#define kHTTP_HEADER_METHOD_STRING @"HEAD"

@class DPPHTTPRequest;

@protocol DPPHTTPRequestDelegate <NSObject>

@optional

-(void)willRecieveResponse:(DPPHTTPRequest*)request;
-(void)didRecieveResponse:(DPPHTTPRequest*)request;
-(void)didFailToRecieveResponse:(DPPHTTPRequest*)request error:(NSError*)error;
-(void)didRecieveProgress:(DPPHTTPRequest*)request;

@end

@interface DPPHTTPRequest : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate,DPPHTTPRequestDelegate>


@property(nonatomic,readonly) NSURLRequest* request;
@property(nonatomic,readonly) BOOL cancelled;
@property(nonatomic,retain) DPPHTTPResponse* response;
@property(nonatomic,assign) id<DPPHTTPRequestDelegate> delegate;

@property(nonatomic,readonly) NSURL* url;

@property(nonatomic,assign) BOOL    progressEnabled;    //enable download progress tracking (does header request first)
@property(nonatomic,copy) NSString* username;
@property(nonatomic,copy) NSString* password;
@property(nonatomic,assign) NSUInteger  bodyStreamBufferSize; 
@property(nonatomic,assign) BOOL    completed;
@property(nonatomic,readonly) BOOL inProgress;
@property(nonatomic,readonly) float progress;
@property(nonatomic,assign) BOOL cached;

@property(nonatomic,retain) NSMutableDictionary* headerValues;

@property(nonatomic,copy) void(^willRecieveResponseBlock)(DPPHTTPRequest*);
@property(nonatomic,copy) void(^didRecieveResponseBlock)(DPPHTTPRequest*);
@property(nonatomic,copy) void(^didFailToRecieveResponseBlock)(DPPHTTPRequest*,NSError* error);
@property(nonatomic,copy) void(^didRecieveProgressBlock)(DPPHTTPRequest*);

@property(nonatomic,copy) void(^willRecieveResponseBlockOnBackground)(DPPHTTPRequest*);
@property(nonatomic,copy) void(^didRecieveResponseBlockOnBackground)(DPPHTTPRequest*);
@property(nonatomic,copy) void(^didRecieveResponseBlockOnBackgroundCompletion)(DPPHTTPRequest*);
@property(nonatomic,copy) void(^didFailToRecieveResponseBlockOnBackground)(DPPHTTPRequest*,NSError* error);

+(DPPHTTPRequest*)httpGETRequestWithURL:(NSURL*)url;
+(DPPHTTPRequest*)httpHEADERRequestWithURL:(NSURL*)url;

+(DPPHTTPRequest*)httpPOSTRequestWithURL:(NSURL*)url postData:(NSData*)postData withContentType:(NSString*)contentType;
+(DPPHTTPRequest*)httpPOSTRequestWithURL:(NSURL*)url postStream:(NSInputStream*)inputStream withContentType:(NSString*)contentType;
+(DPPHTTPRequest*)httpPOSTRequestWithURL:(NSURL*)url postFile:(NSURL*)inputFile withContentType:(NSString*)contentType;

+(DPPHTTPRequest*)httpPUTRequestWithURL:(NSURL*)url putData:(NSData*)postData withContentType:(NSString*)contentType;
+(DPPHTTPRequest*)httpPUTRequestWithURL:(NSURL*)url putStream:(NSInputStream*)inputStream withContentType:(NSString*)contentType;
+(DPPHTTPRequest*)httpPUTRequestWithURL:(NSURL*)url putFile:(NSURL*)inputFile withContentType:(NSString*)contentType;


+(DPPHTTPRequest*)httpPUTFormFile:(NSURL*)url putData:(NSData*)data forFormField:(NSString*)formField;

-(DPPHTTPRequest*)initWithRequest:(NSMutableURLRequest*)newRequest;
-(DPPHTTPRequest*)initWithURL:(NSURL*)url;

-(void)cancel;
-(void)start;

-(void)waitUntilDone;


@end
