//
//  DPPHTTPRequest.m
//
//  Created by Lee Higgins on 15/04/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "DPPHTTPRequest.h"
#import "DPPStreamBuffer.h"
@interface DPPHTTPRequest()

@property(nonatomic,strong) NSURLConnection* internalConnection;
@property(nonatomic,strong) NSMutableData* internalData;
@property(nonatomic,strong) NSMutableURLRequest* internalRequest;
@property(nonatomic,strong) DPPHTTPRequest* internalHeaderRequest;
@property(nonatomic,assign) long long expectedDataSize;
@property(nonatomic,strong) NSOutputStream* bodyOutputStream;
@property(nonatomic,strong) DPPStreamBuffer* bufferStream;
@property(nonatomic,strong) NSInputStream* bodyInputStream;
@end

@implementation DPPHTTPRequest

@synthesize request;

@synthesize url;
@synthesize internalConnection;
@synthesize internalRequest;
@synthesize internalHeaderRequest;
@synthesize username;
@synthesize password;
@synthesize response;
@synthesize delegate;
@synthesize internalData;
@synthesize progressEnabled;
@synthesize expectedDataSize;
@synthesize bodyStreamBufferSize;
@synthesize bodyOutputStream;
@synthesize bufferStream;
@synthesize completed;
@synthesize inProgress;
@synthesize headerValues;
@synthesize progress;
@synthesize cancelled;

@synthesize willRecieveResponseBlock;
@synthesize didRecieveResponseBlock;
@synthesize didFailToRecieveResponseBlock;
@synthesize didRecieveProgressBlock;

@synthesize willRecieveResponseBlockOnBackground;
@synthesize didRecieveResponseBlockOnBackground;
@synthesize didRecieveResponseBlockOnBackgroundCompletion;
@synthesize didFailToRecieveResponseBlockOnBackground;

@synthesize bodyInputStream;
@synthesize cached;

+(DPPHTTPRequest*)httpGETRequestWithURL:(NSURL*)url;
{
    return [[DPPHTTPRequest alloc] initWithURL:url];
}

+(DPPHTTPRequest*)httpPOSTRequestWithURL:(NSURL*)url postData:(NSData*)postData withContentType:(NSString*)contentType
{
    NSMutableURLRequest* newRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [newRequest setHTTPMethod:kHTTP_POST_METHOD_STRING];
    [newRequest setHTTPBody:postData];
    [newRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];
    return [[DPPHTTPRequest alloc] initWithRequest:newRequest];
}
+(DPPHTTPRequest*)httpPUTRequestWithURL:(NSURL*)url putData:(NSData*)putData withContentType:(NSString*)contentType
{
    // NSMutableString* urlString = [NSMutableString stringWithString:url.path];
    
    // [urlString appendString:[[NSString alloc] initWithData:putData encoding:NSASCIIStringEncoding]];
    
    
    NSMutableURLRequest* newRequest = [NSMutableURLRequest requestWithURL:url];
    
    [newRequest setHTTPMethod:kHTTP_PUT_METHOD_STRING];
    [newRequest setHTTPBody:putData];
    [newRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];
    return [[DPPHTTPRequest alloc] initWithRequest:newRequest];
}

+(DPPHTTPRequest*)httpPOSTRequestWithURL:(NSURL*)url postStream:(NSInputStream*)inputStream withContentType:(NSString*)contentType
{
    NSMutableURLRequest* newRequest = [NSMutableURLRequest requestWithURL:url];
    
    [newRequest setHTTPMethod:kHTTP_POST_METHOD_STRING];
    [newRequest setHTTPBodyStream:inputStream];
    [newRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];
    return [[DPPHTTPRequest alloc] initWithRequest:newRequest];
}

+(DPPHTTPRequest*)httpPUTFormFile:(NSURL*)url putData:(NSData*)data forFormField:(NSString*)formField
{
    NSString *filename = @"filename";
     NSMutableURLRequest* newRequest = [NSMutableURLRequest requestWithURL:url];
    [newRequest setHTTPMethod:@"PUT"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    [newRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.png\"\r\n",formField,filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:data]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [newRequest setHTTPBody:postbody];
    return [[DPPHTTPRequest alloc] initWithRequest:newRequest];
}




+(DPPHTTPRequest*)httpPUTRequestWithURL:(NSURL*)url putStream:(NSInputStream*)inputStream withContentType:(NSString*)contentType
{
    NSMutableURLRequest* newRequest = [NSMutableURLRequest requestWithURL:url];
    
    [newRequest setHTTPMethod:kHTTP_PUT_METHOD_STRING];
    [newRequest setHTTPBodyStream:inputStream];
    [newRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];
    return [[DPPHTTPRequest alloc] initWithRequest:newRequest];
}


+(DPPHTTPRequest*)httpPOSTRequestWithURL:(NSURL*)url postFile:(NSURL*)inputFile withContentType:(NSString*)contentType
{
    NSInputStream* inputStream = [NSInputStream inputStreamWithFileAtPath:inputFile.path];
    if(inputStream)
    {
        return [self httpPOSTRequestWithURL:url postStream:inputStream withContentType:contentType];
    }
    return nil;
}

+(DPPHTTPRequest*)httpPUTRequestWithURL:(NSURL*)url putFile:(NSURL*)inputFile withContentType:(NSString*)contentType
{
    NSInputStream* inputStream = [NSInputStream inputStreamWithFileAtPath:inputFile.path];
    if(inputStream)
    {
        return [self httpPUTRequestWithURL:url putStream:inputStream withContentType:contentType];
    }
    return nil;
}

+(DPPHTTPRequest*)httpHEADERRequestWithURL:(NSURL*)url
{
    NSMutableURLRequest* newRequest = [NSMutableURLRequest requestWithURL:url];
    [newRequest setHTTPMethod:kHTTP_HEADER_METHOD_STRING];
    return [[DPPHTTPRequest alloc] initWithRequest:newRequest];
}

-(DPPHTTPRequest*)initWithURL:(NSURL*)newUrl
{
    self = [super init];
    if(self)
    {
        self.internalRequest = [NSMutableURLRequest requestWithURL:newUrl];
    }
    return self;
}

-(DPPHTTPRequest*)initWithRequest:(NSMutableURLRequest*)newRequest
{
    self = [super init];
    if(self)
    {
        if(newRequest.HTTPBodyStream)
        {
            self.bodyInputStream = newRequest.HTTPBodyStream;
        }
        self.internalRequest = newRequest;
    }
    return self;
}

-(void)start
{
    inProgress = YES;
    self.completed = NO;
    cancelled = NO;
    self.internalData = nil;
    
    
    for(id key in self.headerValues.allKeys)
    {
        [self.internalRequest setValue:[headerValues objectForKey:key] forHTTPHeaderField:key];
    }
    
   // NSLog(@"URL %@ ",self.url);
 //   NSLog(@"Headers====== \n%@\n",self.internalRequest.allHTTPHeaderFields);
    
    if(progressEnabled)
    {
        self.internalHeaderRequest = [DPPHTTPRequest httpHEADERRequestWithURL:self.url];
        internalHeaderRequest.delegate = self;
        [internalHeaderRequest start];
    }
    else
    {
         self.internalConnection = [[NSURLConnection alloc]
                                       initWithRequest:internalRequest
                                       delegate:self
                                       startImmediately:NO];
        [internalConnection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSRunLoopCommonModes];
        [internalConnection start];
    }
}

-(void)cancel
{
    self.completed = YES;
     cancelled =YES;
    [self.internalHeaderRequest cancel];
    [self.internalConnection cancel];
    [self connection:internalConnection didFailWithError:[NSError errorWithDomain:@"Cancelled" code:-1 userInfo:nil]];
   
}

-(void)waitUntilDone
{
    while (inProgress) 
    {
        [NSThread sleepForTimeInterval:0.1];
    }
}

-(NSURL*)url
{
    return self.internalRequest.URL;
}

-(NSMutableDictionary*)headerValues
{
    if(headerValues ==nil)
    {
        headerValues = [[NSMutableDictionary alloc] init];
    }
    return headerValues;
}

-(void)setCompleted:(BOOL)newCompleted
{
    completed = newCompleted;
    if(completed)
    {
        self.bodyInputStream=nil;
        inProgress = NO;
    }
}

-(NSURLRequest*)request
{
    return internalRequest;
}

-(NSMutableData*)internalData
{
    if(internalData==nil)
    {
        internalData = [[NSMutableData alloc] init];
    }
    return internalData;
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if([delegate respondsToSelector:@selector(didFailToRecieveResponse:error:)])
    {
        self.response = nil;
        self.internalData = nil;
        [delegate didFailToRecieveResponse:self error:error];
    }
    
    if(self.didFailToRecieveResponseBlock)
    {
        self.didFailToRecieveResponseBlock(self,error);
    }
    
    if(self.didFailToRecieveResponseBlockOnBackground)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{self.didFailToRecieveResponseBlockOnBackground(self,error);});
    }
    self.completed=YES;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0) {
       // NSLog(@"received authentication challenge");
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:self.username
                                                                    password:self.password
                                                                 persistence:NSURLCredentialPersistenceForSession];
      //  NSLog(@"credential created");
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
       // NSLog(@"responded to authentication challenge");
    }
    else {
        NSLog(@"previous authentication failure");
    }
}

#pragma mark NSURLConnectionDataDelegate


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)urlResponse
{
    if(internalConnection!= connection) return; //not ours??!!
    self.internalData = nil;
    
    DPPHTTPResponse* newResponse = [[DPPHTTPResponse alloc] init];
    newResponse.header = (NSHTTPURLResponse *)urlResponse;
    
   // NSLog(@"%@",self.internalRequest.HTTPBodyStream);
    
    if(bodyStreamBufferSize >0)
    {
        if(bufferStream ==nil)
        {
            self.bufferStream = [[DPPStreamBuffer alloc] init];
        }
        bufferStream.bufferSize = bodyStreamBufferSize;
        
        self.bodyOutputStream = bufferStream.input;
        newResponse.bodyStream = bufferStream.output;
    }
    
    self.response = newResponse;
    
    NSURLCache *sharedCache = [NSURLCache sharedURLCache];
    cached = ([sharedCache cachedResponseForRequest:internalRequest]!=nil);
    
    if([delegate respondsToSelector:@selector(willRecieveResponse:)])
    {
        [delegate willRecieveResponse:self];
    }
    
    if(self.willRecieveResponseBlock)
    {
        self.willRecieveResponseBlock(self);
    }
    
    if(self.willRecieveResponseBlockOnBackground)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{self.willRecieveResponseBlockOnBackground(self);});
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(internalConnection!= connection) return; //not ours??!!
    if(self.bodyStreamBufferSize>0)
    {
        [self.bodyOutputStream write:[data bytes] maxLength:data.length];
    }
    else 
    {
        [self.internalData appendData:data];
    }
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    
    
    if([delegate respondsToSelector:@selector(didRecieveProgress:)])
    {
        [delegate didRecieveProgress:self];
    }
    
    if(didRecieveProgressBlock)
    {
        self.didRecieveProgressBlock(self);
    }
   // NSLog(@"uploading.... %d",(int)(progress*100.0));
}
-(void)callCompletion
{
    if(didRecieveResponseBlockOnBackgroundCompletion !=nil)
    {
        self.didRecieveResponseBlockOnBackgroundCompletion(self);
    }
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(internalConnection!= connection) return; //not ours??!!
    if(self.bodyStreamBufferSize>0)
    {
        [self.bodyOutputStream close];
        self.bodyOutputStream = nil;
    }
    else 
    {
        self.response.body = self.internalData;
        self.internalData = nil;
    }
   
    if([delegate respondsToSelector:@selector(didRecieveResponse:)])
    {
        [delegate didRecieveResponse:self];
    }
    if(self.didRecieveResponseBlock)
    {
        self.didRecieveResponseBlock(self);
    }
    if(self.didRecieveResponseBlockOnBackground)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),
                       ^{
                           
                           self.didRecieveResponseBlockOnBackground(self);
                       
                           [self performSelectorOnMainThread:@selector(callCompletion) withObject:nil waitUntilDone:NO];
                       
                       });
    }
     self.completed=YES;
}

#pragma HEADER Request delegate for progress

-(void)didRecieveResponse:(DPPHTTPRequest*)headerRequest
{
    if(headerRequest != internalHeaderRequest) return;
    self.internalConnection = [NSURLConnection connectionWithRequest:internalRequest delegate:self];
    [internalConnection start];
}

-(void)didFailToRecieveResponse:(DPPHTTPRequest*)headerRequest error:(NSError *)error
{
    if(headerRequest != internalHeaderRequest) return;

    if([delegate respondsToSelector:@selector(didFailToRecieveResponse:error:)])
    {
        self.response = nil;
        self.internalData = nil;
        [delegate didFailToRecieveResponse:self error:error];
    }
}
-(void)dealloc
{
   // NSLog(@"dealloced request %@",self.url);
}


@end
