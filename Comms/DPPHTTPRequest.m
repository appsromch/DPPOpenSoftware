//
//  DPPHTTPRequest.m
//  Created by Lee Higgins on 15/04/2012.
//

#import "DPPHTTPRequest.h"
#import "DPPHTTPResponse.h"
#import "DPPStreamBuffer.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import "mach/mach.h"

NSString *const kDPPHTTPRequestQOSRatingDidChange = @"DPPHTTPRequestQOSRatingDidChange";
NSString *const kDPPHTTPRequestNetworkStatusDidChange = @"DPPHTTPRequestNetworkStatusDidChange";

static NSOperationQueue* lowPriorityNetworkQueue = nil;
static NSOperationQueue* defaultQueue = nil;
//static NSOperationQueue* cachedNetworkQueue=nil;

@interface DPPHTTPRequest()
{
    NSArray* _debugCreatedCallstack;
}
@property(nonatomic,strong) NSURLConnection* internalConnection;
@property(nonatomic,strong) NSMutableData* internalData;
@property(nonatomic,strong) NSMutableURLRequest* internalRequest;
@property(nonatomic,assign) long long expectedDataSize;
@property(nonatomic,strong) NSOutputStream* bodyOutputStream;
@property(nonatomic,strong) DPPStreamBuffer* bufferStream;
@property(nonatomic,strong) NSInputStream* bodyInputStream;

@property(nonatomic,strong) NSDate* startDate;
@property(nonatomic,strong) NSDate* responseDate;
@property(nonatomic,strong) NSDate* transferDate;
@property(nonatomic,strong) NSDate* startUploadDate;
@property(nonatomic,strong) NSDate* completionDate;
@property(nonatomic,assign) BOOL isUploadRequest;
@property(nonatomic,strong) NSTimer* networkQOSTimer;
@property(nonatomic,strong) NSMutableOrderedSet* dependents;

@property(nonatomic,assign) long long transferBytes;

-(void)setState:(DPPRequestState)state;

@end

static NSDate* startupDate=nil;
static double transferRateAvrValue = kEdgeBandwidthMB;
static NSMutableDictionary* allRequests = nil;
static double transferedMB = 0;
static BOOL _debugMode=NO;
static NSURL* baseURL=nil;
static SCNetworkReachabilityRef networkReachability=nil;

@implementation DPPHTTPRequest

@synthesize request;

@dynamic url;
@synthesize internalConnection;
@synthesize internalRequest;
@synthesize username;
@synthesize password;
@synthesize response;
@synthesize delegate;
@synthesize internalData;
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

@synthesize didRecieveResponseBlockOnBackground;
@synthesize didRecieveResponseBlockOnBackgroundCompletion;


@synthesize bodyInputStream;
@synthesize cached;

+(void)initialize
{
    [super initialize];
    startupDate = [NSDate date];
    allRequests = [NSMutableDictionary dictionary];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:[DPPHTTPRequest class] selector:@selector(watchdogTick) userInfo:nil repeats:YES];
     if(baseURL ==nil) baseURL = [NSURL URLWithString:@"http://www.google.com"];
    [self startMonitoringNetworkReachability];
}

+(void)setBaseURL:(NSURL*)url
{
    baseURL = url;
}

+(NSUInteger)requestCount
{
    return allRequests.count;
}

+(void)setupCacheWithMemorySizeMB:(float)memorySize diskSizeMB:(float)diskSize
{
    float cacheSizeMemory = memorySize*1024*1024; 
    float cacheSizeDisk = diskSize*1024*1024;
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:(int)cacheSizeMemory diskCapacity:(int)cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
}

+(id)httpGETRequestWithURL:(NSURL*)url
                onSuccess:(void(^)(DPPHTTPRequest* request))success
                onFailure:(void(^)(DPPHTTPRequest* request,NSError* error))failure
{
    DPPHTTPRequest* newRequest = [DPPHTTPRequest httpGETRequestWithURL:url];
    newRequest.didRecieveResponseBlock = success;
    newRequest.didFailToRecieveResponseBlock = failure;
    return newRequest;
}

+(id)httpGETRequestWithURL:(NSURL*)url
      responseInBackground:(void(^)(DPPHTTPRequest* request))background
                completion:(void(^)(DPPHTTPRequest* request))completion
{
    DPPHTTPRequest* newRequest = [DPPHTTPRequest httpGETRequestWithURL:url];
    newRequest.didRecieveResponseBlockOnBackground = background;
    newRequest.didRecieveResponseBlockOnBackgroundCompletion = completion;
    return newRequest;
}

+(DPPHTTPRequest*)httpGETRequestWithURL:(NSURL*)url
{
    return [DPPHTTPRequest httpRequestWithURL:url method:kHTTP_GET_METHOD_STRING];
}

+(id)httpRequestWithURL:(NSURL*)url method:(NSString*)method
{
    DPPHTTPRequest* newRequest = [[DPPHTTPRequest alloc] initWithURL:url];
    newRequest.internalRequest.HTTPMethod = method;
    return newRequest;
}

+(id)httpRequestWithURL:(NSURL*)url
                    method:(NSString*)httpMethod
                 onSuccess:(void(^)(DPPHTTPRequest* request))success
                 onFailure:(void(^)(DPPHTTPRequest* request,NSError* error))failure
{
    DPPHTTPRequest* newRequest = [DPPHTTPRequest httpRequestWithURL:url method:httpMethod];
    newRequest.didRecieveResponseBlock = success;
    newRequest.didFailToRecieveResponseBlock = failure;
    return newRequest;
}


+(DPPHTTPRequest*)httpPOSTRequestWithURL:(NSURL*)url postData:(NSData*)postData
                         withContentType:(NSString*)contentType
                    responseInBackground:(void(^)(DPPHTTPRequest* request))background
                              completion:(void(^)(DPPHTTPRequest* request))completion
{
    DPPHTTPRequest* newRequest = [DPPHTTPRequest httpPOSTRequestWithURL:url postData:postData withContentType:contentType];
    newRequest.didRecieveResponseBlockOnBackground = background;
    newRequest.didRecieveResponseBlockOnBackgroundCompletion = completion;
    return newRequest;
}

+(DPPHTTPRequest*)httpPOSTRequestWithURL:(NSURL*)url
                                postData:(NSData*)postData
                         withContentType:(NSString*)contentType
                               onSuccess:(void(^)(DPPHTTPRequest* request))success
                               onFailure:(void(^)(DPPHTTPRequest* request,NSError* error))failure
{
    DPPHTTPRequest* newRequest = [DPPHTTPRequest httpPOSTRequestWithURL:url postData:postData withContentType:contentType];
    newRequest.didRecieveResponseBlock = success;
    newRequest.didFailToRecieveResponseBlock = failure;
    return newRequest;
}

+(DPPHTTPRequest*)httpPOSTRequestWithURL:(NSURL*)url postData:(NSData*)postData withContentType:(NSString*)contentType
{
    NSMutableURLRequest* newRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [newRequest setHTTPMethod:kHTTP_POST_METHOD_STRING];
    [newRequest setHTTPBody:postData];
    [newRequest addValue:contentType forHTTPHeaderField:kHTTPContentTypeHeaderKey];
    return [[DPPHTTPRequest alloc] initWithRequest:newRequest];
}
+(DPPHTTPRequest*)httpPUTRequestWithURL:(NSURL*)url putData:(NSData*)putData withContentType:(NSString*)contentType
{
    NSMutableURLRequest* newRequest = [NSMutableURLRequest requestWithURL:url];
    
    [newRequest setHTTPMethod:kHTTP_PUT_METHOD_STRING];
    [newRequest setHTTPBody:putData];
    [newRequest addValue:contentType forHTTPHeaderField:kHTTPContentTypeHeaderKey];
    return [[DPPHTTPRequest alloc] initWithRequest:newRequest];
}

+(DPPHTTPRequest*)httpPOSTRequestWithURL:(NSURL*)url postStream:(NSInputStream*)inputStream withContentType:(NSString*)contentType contentLength:(NSInteger)length
{
    NSMutableURLRequest* newRequest = [NSMutableURLRequest requestWithURL:url];
    
    [newRequest setHTTPMethod:kHTTP_POST_METHOD_STRING];
    [newRequest setHTTPBodyStream:inputStream];
    [newRequest addValue:contentType forHTTPHeaderField:kHTTPContentTypeHeaderKey];
    if(length >0)
    {
        [newRequest addValue:[NSString stringWithFormat:@"%d",length] forHTTPHeaderField:kHTTPContentLengthHeaderKey];
    }
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
    [newRequest addValue:contentType forHTTPHeaderField:kHTTPContentTypeHeaderKey];
    return [[DPPHTTPRequest alloc] initWithRequest:newRequest];
}


+(DPPHTTPRequest*)httpPOSTRequestWithURL:(NSURL*)url postFile:(NSURL*)inputFile withContentType:(NSString*)contentType
{
    NSError* error=nil;
    NSDictionary* fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:inputFile.path error:&error];
    if(error ==nil)
    {
        NSInputStream* inputStream = [NSInputStream inputStreamWithFileAtPath:inputFile.path];
        if(inputStream)
        {
            return [self httpPOSTRequestWithURL:url postStream:inputStream withContentType:contentType contentLength:[[fileInfo objectForKey:NSFileSize] integerValue]];
        }
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

+(DPPHTTPRequest*)httpPATCHRequestWithURL:(NSURL*)url patchData:(NSData*)patchData withContentType:(NSString*)contentType
{
    NSMutableURLRequest* newRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [newRequest setHTTPMethod:kHTTP_PATCH_METHOD_STRING];
    [newRequest setHTTPBody:patchData];
    [newRequest addValue:contentType forHTTPHeaderField:kHTTPContentTypeHeaderKey];
    return [[DPPHTTPRequest alloc] initWithRequest:newRequest];
}

+(DPPHTTPRequest*)httpPATCHRequestWithURL:(NSURL*)url patchData:(NSData*)patchData withContentType:(NSString*)contentType
                     responseInBackground:(void(^)(DPPHTTPRequest* request))background
                               completion:(void(^)(DPPHTTPRequest* request))completion
{
    DPPHTTPRequest* newRequest = [DPPHTTPRequest httpPATCHRequestWithURL:url patchData:patchData withContentType:contentType];
    newRequest.didRecieveResponseBlockOnBackground = background;
    newRequest.didRecieveResponseBlockOnBackgroundCompletion = completion;
    return newRequest;
}

+(DPPHTTPRequest*)httpPATCHRequestWithURL:(NSURL*)url patchData:(NSData*)patchData withContentType:(NSString*)contentType
                                onSuccess:(void(^)(DPPHTTPRequest* request))success
                                onFailure:(void(^)(DPPHTTPRequest* request,NSError* error))failure
{
    DPPHTTPRequest* newRequest = [DPPHTTPRequest httpPATCHRequestWithURL:url patchData:patchData withContentType:contentType];
    newRequest.didRecieveResponseBlock = success;
    newRequest.didFailToRecieveResponseBlock = failure;
    return newRequest;
}

+(DPPHTTPRequest*)httpHEADERRequestWithURL:(NSURL*)url
{
    NSMutableURLRequest* newRequest = [NSMutableURLRequest requestWithURL:url];
    [newRequest setHTTPMethod:kHTTP_HEADER_METHOD_STRING];
    return [[DPPHTTPRequest alloc] initWithRequest:newRequest];
}

+(DPPHTTPRequest*)findRequestWithURL:(NSURL*)url
{
    @synchronized(self)
    {
        return [allRequests objectForKey:url.absoluteString];
    }
}

+(NSOperationQueue*)defaultNetworkQueue
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultQueue = [[NSOperationQueue alloc] init];
        [defaultQueue setMaxConcurrentOperationCount:kDefaultNetworkQueueMaxConcurrent];
    });
    return defaultQueue;
}

/*+(NSOperationQueue*)cachedNetworkQueue
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cachedNetworkQueue = [[NSOperationQueue alloc] init];
        [cachedNetworkQueue setMaxConcurrentOperationCount:kDefaultNetworkQueueMaxConcurrent];
    });
    return defaultQueue;
}*/

+(NSOperationQueue*)lowPriorityNetworkQueue
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            lowPriorityNetworkQueue = [[NSOperationQueue alloc] init];
            [lowPriorityNetworkQueue setMaxConcurrentOperationCount:kLowPriorityNetworkQueueMaxConcurrent];
            //[lowPriorityNetworkQueue setSuspended:YES];
    });
    return lowPriorityNetworkQueue;
}

+(void)setDefaultNetworkQueue:(NSOperationQueue*)operationQueue
{
    @synchronized(self)
    {
        defaultQueue = operationQueue;
    }
}

+(void)setLowPriorityNetworkQueue:(NSOperationQueue*)operationQueue
{
    @synchronized(self)
    {
        lowPriorityNetworkQueue = operationQueue;
    }
}

+(dispatch_queue_t)defaultDispatchQueue //queue used for didrecieveresponse in background
{
    static dispatch_queue_t defaultQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         defaultQueue = dispatch_queue_create("com.depthperpixel.dpphttprequest", DISPATCH_QUEUE_SERIAL);
    });
    return defaultQueue;
}

+(void)enqueueURLRequest:(NSURLRequest*)request
{
    DPPHTTPRequest* wrapper = [[DPPHTTPRequest alloc] initWithRequest:[request mutableCopy]];
    [wrapper enqueue];
}

+(void)enqueueURLRequest:(NSURLRequest*)request withPriority:(NSOperationQueuePriority)priority
{
    DPPHTTPRequest* wrapper = [[DPPHTTPRequest alloc] initWithRequest:[request mutableCopy]];
    [wrapper enqueueWithPriority:priority];
}

+(void)cancelQueue
{
    
    [self suspendLowPriority:YES cancelOperations:YES];
    [self cancelQueue:[DPPHTTPRequest defaultNetworkQueue]];
    [self suspendLowPriority:NO];
}

+(void)cancelQueue:(NSOperationQueue*)queue
{
    NSLog(@"DPPHTTPRequest Cancelled Queue");
    [queue setSuspended:YES];
    [queue cancelAllOperations];
    [queue setSuspended:NO];
}

+(void)suspendLowPriority:(BOOL)suspend
{
    [self suspendLowPriority:suspend cancelOperations:NO];
}

+(void)suspendLowPriority:(BOOL)suspend cancelOperations:(BOOL)cancel
{
    NSOperationQueue* lowPriorityQueue = [DPPHTTPRequest lowPriorityNetworkQueue];
    if(!lowPriorityQueue.isSuspended && suspend == YES)
    {//if we are moving to suspend, record the date so that we can unsuspend when default queue is idle..
        if(cancel)
        {
            [[self lowPriorityNetworkQueue] cancelAllOperations];
        }
        [[self lowPriorityNetworkQueue] setSuspended:YES];
    }
    else
    {
        [[self lowPriorityNetworkQueue] setSuspended:suspend];
    }
}

+(void)setDebugMode:(BOOL)debug
{
    _debugMode = debug;
}

+(NSArray*)allRequests
{
    return [allRequests allValues];
}

-(DPPHTTPRequest*)initWithURL:(NSURL*)newUrl
{
    NSAssert(newUrl!=nil,@"DPPHTTPRequest URL cannot be nil");
    return [self initWithRequest:[NSMutableURLRequest requestWithURL:newUrl]];
}

-(DPPHTTPRequest*)initWithRequest:(NSMutableURLRequest*)newRequest
{
     NSAssert(newRequest.URL!=nil,@"DPPHTTPRequest URL cannot be nil");
    self = [super init];
    if(self)
    {
        if(_debugMode)
        {
            _debugCreatedCallstack = [NSThread callStackSymbols];
        }
        
        if(newRequest.HTTPBodyStream)
        {
            self.bodyInputStream = newRequest.HTTPBodyStream;
        }
        self.internalRequest = newRequest;
        @synchronized(self)
        {
            [allRequests setValue:self forKey:newRequest.URL.absoluteString];
        }
        [self setState:DPPCreated];
        self.didFailToRecieveResponseBlock = ^(DPPHTTPRequest* blockRequest,NSError* error)
        {
            NSLog(@"DPPHTTPRequest::Failed %@ %@ \n Add a handling block to remove this log.",error,blockRequest);
        };
    }
    return self;
}

-(NSOperation*)enqueueWithPriority:(NSOperationQueuePriority)priority
{
    return [self enqueueInOperationQueue:[DPPHTTPRequest defaultNetworkQueue] withPriority:priority];
}

-(NSOperation*)enqueue
{
    return [self enqueueInOperationQueue:[DPPHTTPRequest defaultNetworkQueue] withPriority:NSOperationQueuePriorityNormal];
}

-(NSOperation*)enqueueInOperationQueue:(NSOperationQueue*)queue withPriority:(NSOperationQueuePriority)priority
{
    
    [self setState:DPPQueued];
    
    
   /* if([[NSURLCache sharedURLCache] cachedResponseForRequest:self.internalRequest]!=nil)
    { //do cache request right now.... as they are quick....
        queue = [self.class cachedNetworkQueue];
    
    } //LH this was a bad idea as getting the cached response may lift it off disk using lots of memory
    
    */
    
    NSOperation* operation = [self createOperation];
    
    operation.queuePriority = priority;
    
    [self prepareToStart];
    
    for(DPPHTTPRequest* dependantRequest in self.dependencies)
    {
        if([dependantRequest isKindOfClass:[self class]])
        {
            NSOperation* dependantOp = [dependantRequest enqueueInOperationQueue:queue withPriority:priority];
            [operation addDependency:dependantOp];
            NSLog(@"DPPHTTPRequest adding dependant request %@ \nfor Request %@",dependantRequest,self);
        }
    }
    
    [queue addOperation:operation];
    return operation;
}

-(NSOperation*)createOperation
{
    NSBlockOperation* operation = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOperation = operation;
    
    [operation addExecutionBlock:^(){
    @autoreleasepool {
        if(!self.cancelled)
        {
            BOOL dependentFailed = NO;
            for(DPPHTTPRequest* dependentRequest in self.dependencies)
            {
                if([dependentRequest isKindOfClass:[self class]])
                {
                    if(dependentRequest.state ==DPPFailed || !dependentRequest.response.isValid)
                    {
                        dependentFailed =YES;
                        break;
                    }
                }
            }
            
            if(!dependentFailed)
            {
                UIApplication* app = [UIApplication sharedApplication];
                app.networkActivityIndicatorVisible = YES;
                
                if([[DPPHTTPRequest defaultNetworkQueue].operations containsObject:self])
                {
                    [DPPHTTPRequest suspendLowPriority:NO cancelOperations:([DPPHTTPRequest networkQOSRating] < kUsableQOSRating)];
                    if(_debugMode)
                    {
                        NSLog(@"Network QOS: suspending low priority queue while requesting on default queue (%d).",[DPPHTTPRequest defaultNetworkQueue].operationCount);
                    }
                }
                
                [self start];
                while (self.inProgress)
                {//LH stop the operation from completing until we are done, but pump the runloop...
                    @autoreleasepool {
                        
                        if(![weakOperation isCancelled])
                        {
                            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
                        }
                        else
                        { //LH if the NSOperation is cancelled - cancel the request.....
                            [self cancel];
                        }
                    }
                }
                
                if([[DPPHTTPRequest defaultNetworkQueue].operations containsObject:self])
                {
                    if([DPPHTTPRequest defaultNetworkQueue].operationCount <= 1)
                    {
                        [DPPHTTPRequest suspendLowPriority:NO];
                        if(_debugMode)
                        {
                            NSLog(@"Network QOS: Idle, resumed low priority queue (%d items).",[DPPHTTPRequest lowPriorityNetworkQueue].operationCount);
                        }
                    }
                    if(!self.cancelled)
                    {
                        if(_debugMode)
                        {
                            NSLog(@"\nRequest: %@ \nSize:\t\t\t%fMB \nTransfer:\t\t%fMBs \nTransferIncLat:\t%fMBs \nResponsTime:\t%fs \nTransferTime:\t%fs \nProcessingTime:\t%fs \nTotalTime:\t\t%f\n",
                                  
                                  self.url,
                                  (double)_transferBytes/1024./1024.,
                                  [self requestTransferRateMBs],
                                  [self requestRateMBs],
                                  [self responseTime],
                                  [self transferTime],
                                  [self processingTime],
                                  [self requestTime]);
                        }
                    }
                    
                }
                
                app.networkActivityIndicatorVisible = NO;
            }
            else
            {
                [self cancel];
                if(self.didFailToRecieveResponseBlock)
                {
                    NSError* error = [NSError errorWithDomain:@"Dependency failed" code:-1 userInfo:nil];
                    self.didFailToRecieveResponseBlock(self,error);
                }
            }
        }
        else
        {
            [self cancel];
            NSLog(@"cancelled before run..");
        }
        
        
    }
    }];
    
    return operation;
}

-(BOOL)containedInCache:(NSURLCache*)cache
{
    if(self.internalRequest)
    {
        return ([cache cachedResponseForRequest:self.internalRequest]!=nil);
    }
    return NO;
}

-(NSMutableOrderedSet*)dependants
{
    if(_dependents == nil)
    {
        _dependents = [NSMutableOrderedSet orderedSet];
    }
    return _dependents;
}

-(NSArray*)dependencies
{
    return [[_dependents array] copy];
}

-(void)addDependencies:(NSArray*)requests
{
    [self.dependents addObjectsFromArray:requests];
}

-(void)addDependency:(DPPHTTPRequest*)dependant
{
    [self.dependents addObject:dependant];
}

-(void)removeDependency:(DPPHTTPRequest*)dependant
{
    [self.dependents removeObject:dependant];
}

-(void)removeDependencies:(NSArray*)requests
{
    [self.dependents removeObjectsInArray:requests];
}

-(void)prepareToStart
{
    inProgress = YES;
    self.completed = NO;
    cancelled = NO;
    self.internalData = nil;
    
    for(id key in self.headerValues.allKeys)
    {
        [self.internalRequest setValue:[headerValues objectForKey:key] forHTTPHeaderField:key];
    }
}

-(void)start
{
    if(_numberOfTries > 0) NSLog(@"retrying request...");
    _numberOfTries++;
    if(_debugMode)
    {
        if(self.didFailToRecieveResponseBlock == nil)
        {
            NSLog(@"DPPHTTPRRequest:: request not handling fail state %@",self);
        }
        if(self.didRecieveResponseBlock == nil && self.didRecieveResponseBlockOnBackground ==nil)
        {
             NSLog(@"DPPHTTPRRequest:: request has no handler %@",self);
        }
    }
    
    
    
    [self prepareToStart];
        if(self.connectiontTimeoutInterval == 0) self.connectiontTimeoutInterval = 30.0; //LH default to 30.0 if not set
        self.internalRequest.timeoutInterval = self.connectiontTimeoutInterval;

        self.internalConnection = [[NSURLConnection alloc]
                                   initWithRequest:internalRequest
                                   delegate:self
                                   startImmediately:NO];
        [internalConnection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                      forMode:NSRunLoopCommonModes];
    
        //LH if the QOS timeout is set, setup the expire timer
        if(self.networkQOSTimeoutInterval>0.0)
        {
            self.networkQOSTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:self.networkQOSTimeoutInterval] interval:0 target:self selector:@selector(expireQOSTimeout) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:_networkQOSTimer forMode:NSRunLoopCommonModes];
        }
        _startDate = [NSDate date];
        [internalConnection start];
    [self setState:DPPConnecting];
}

-(void)cancelIfNotInProgress
{
    if(self.state == DPPQueued)
    {
        [self cancel];
    }
}

-(void)cancel
{
    if(self.completed) return;
    if(_debugMode)
    {
        NSLog(@"Cancelled %@",self);
    }
    [self.networkQOSTimer invalidate];
    self.completed = YES;
     cancelled =YES;
    [self.internalConnection cancel];
    
    [self setState:DPPCancelled];
    
    __weak DPPHTTPRequest* weakSelf = self;
     dispatch_async(dispatch_get_main_queue(),^{
    if(weakSelf.didFailToRecieveResponseBlock)
    {
        weakSelf.didFailToRecieveResponseBlock(self,[NSError errorWithDomain:@"NSURLErrorDomain" code:kCFURLErrorCancelled userInfo:nil]);
    }});
}

-(void)setState:(DPPRequestState)state
{
        if(_state !=state)
        {
            if(state == DPPQueued)
            {
                inProgress = YES;
            }
            _state = state;
            [self sendProgressUpdate];
        }
}

-(NSString*)stateDescription
{
   switch(_state)
    {
        case DPPCreated:
        {
            return NSLocalizedString(@"Created", nil );
        }
        break;
        case DPPQueued:
        {
            return NSLocalizedString(@"Queued", nil );
        }
            break;
        case DPPConnecting:
        {
            return NSLocalizedString(@"Connecting", nil );
        }
            break;
        case DPPConnected:
        {
            return NSLocalizedString(@"Connected", nil );
        }
            break;
        case DPPComplete:
        {
            return NSLocalizedString(@"Complete", nil );
        }
            break;
        case DPPCancelled:
        {
            return NSLocalizedString(@"Cancelled", nil );
        }
            break;
        case DPPFailed:
        {
            return NSLocalizedString(@"Failed", nil );
        }
            break;
        default:
            return NSLocalizedString(@"Unknown", nil );
    }
}

-(void)waitUntilDone
{
    while (inProgress)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
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
        @synchronized(self)
        {
            [allRequests removeObjectForKey:self.url.absoluteString];
        }
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
    _responseDate = [NSDate date];
     [self setState:DPPFailed];
    self.response = nil;
    self.internalData = nil;
    dispatch_async(dispatch_get_main_queue(),^{
        if([delegate respondsToSelector:@selector(didFailToRecieveResponse:error:)])
        {
            [delegate didFailToRecieveResponse:self error:error];
        }
        
        if(self.didFailToRecieveResponseBlock)
        {
            self.didFailToRecieveResponseBlock(self,error);
        }
        
        self.completed=YES;
    });
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0) {
       // NSLog(@"received authentication challenge");
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:self.username
                                                                    password:self.password
                                                                 persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
    }
    else {
        if(_debugMode)
        {
            NSLog(@"previous authentication failure");
        }
    }
}

#pragma mark NSURLConnectionDataDelegate


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)urlResponse
{
    if(internalConnection!= connection) return; //not ours??!!
    self.internalData = nil;
    _responseDate = [NSDate date];
    DPPHTTPResponse* newResponse = [[DPPHTTPResponse alloc] init];
    newResponse.header = (NSHTTPURLResponse *)urlResponse;
    
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
    
    //NSURLCache *sharedCache = [NSURLCache sharedURLCache];
    //cached = ([sharedCache cachedResponseForRequest:internalRequest]!=nil);
    [self setState:DPPConnected];
    dispatch_async(dispatch_get_main_queue(),^{
        
        if([delegate respondsToSelector:@selector(willRecieveResponse:)])
        {
            [delegate willRecieveResponse:self];
        }
        
        if(self.willRecieveResponseBlock)
        {
            self.willRecieveResponseBlock(self);
        }
    });
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(internalConnection!= connection) return; //not ours??!!
    BOOL firstCall = (_transferBytes ==0);

    _transferBytes += data.length;
    
    
    if(self.bodyStreamBufferSize>0)
    {
        [self.bodyOutputStream write:[data bytes] maxLength:data.length];
    }
    else 
    {
        [self.internalData appendData:data];
    }
    
    if(self.response.header.expectedContentLength > 0)
    {
        progress = (float)_transferBytes / (float)self.response.header.expectedContentLength;
    }
    
    if(!firstCall)
    {//LH the first call is sent at the same time as the didRecieveresponse, so we've already sent an update...
        [DPPHTTPRequest addTransferRateToWeightedSum:[self requestTransferRateMBs]];
       
        [self sendProgressUpdate];
    }
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if(internalConnection!= connection) return; //not ours??!!
    progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;

    _transferBytes +=bytesWritten;

    _isUploadRequest = YES;
    [self sendProgressUpdate];
}

-(void)sendProgressUpdate
{
    dispatch_async(dispatch_get_main_queue(),^{
       /* if(_debugMode)
        {
            if(_state == DPPConnected)
            {
                NSLog(@"Request update: %@ %@ %fMB (%fMBs)",self.url,[self stateDescription],(double)_transferBytes/1024./1024., [self requestTransferRateMBs]);
            }
            else
            {
                NSLog(@"Request update: %@ %@",self.url,[self stateDescription]);
            }
        }*/
        if([delegate respondsToSelector:@selector(didRecieveProgress:)])
        {
            [delegate didRecieveProgress:self];
        }
        
        if(didRecieveProgressBlock)
        {
            self.didRecieveProgressBlock(self);
        }
    });
}

-(void)callCompletion
{
    if(didRecieveResponseBlockOnBackgroundCompletion !=nil)
    {
        self.didRecieveResponseBlockOnBackgroundCompletion(self);
    }
    _completionDate = [NSDate date];
    self.completed=YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(internalConnection!= connection) return; //not ours??!!
    _transferDate = [NSDate date];
    [self.networkQOSTimer invalidate];

   
    self.response.isValid = YES;
    [self setState:DPPComplete];
    
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
    if(!self.cancelled && _transferBytes > 0)
    {
        [DPPHTTPRequest addTransferRateToWeightedSum:[self requestTransferRateMBs]];
        [DPPHTTPRequest addBytesTransfered:_transferBytes];
    }
   // NSLog(@"completed request");
    dispatch_async(dispatch_get_main_queue(),^{
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
            dispatch_async([DPPHTTPRequest defaultDispatchQueue],
                           ^{
                               @autoreleasepool {  //LH this is to garantee any created objects are released right away, GCD may release after several ops
                                   if(self.didRecieveResponseBlockOnBackground)
                                   {
                                       self.didRecieveResponseBlockOnBackground(self);
                                   }
                                   if(!self.cancelled)
                                   {
                                        dispatch_async(dispatch_get_main_queue(),^{
                                            [self callCompletion];
                                        });
                                   }
                               }
                           });
        }
        else
        {
         self.completed=YES;
        }
    });
}

-(void)clearCompletionCallbacks
{
    //LH clear all callbacks except background process......
    self.delegate =nil;
    self.willRecieveResponseBlock = nil;
    self.didFailToRecieveResponseBlock =nil;
    self.didRecieveResponseBlock =nil;
    self.didRecieveProgressBlock =nil;
    self.didRecieveResponseBlockOnBackgroundCompletion = nil;
}

-(void)clearALLCallbacks
{
    //LH clear all callbacking including background......
    [self clearCompletionCallbacks];
    self.didRecieveResponseBlockOnBackground = nil;
}

#pragma mark QOS metrics

-(void)expireQOSTimeout
{
    //LH send an update showing the timeout expired (up to the reciever to decide what to do)
    _networkQOSTimeoutExpired = YES;
    if(_debugMode)
    {
        NSLog(@"QOSTimeout expired for %@",self.url);
    }
    if(self.networkQOSDidTimeout)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           _networkQOSDidTimeout(self);
                       });
    }
}

-(NSArray*)debugCreatedCallstack
{
    if(_debugMode)
    {
        return _debugCreatedCallstack;
    }
    else
    {
        return @[@"debug mode needed for output"];
    }
}

-(NSString*)description
{
    int maxLength = 200;
    NSString* trimedBody = [self.response.bodyString substringToIndex: MIN(maxLength, [self.response.bodyString length])];
    if([self.response.bodyString length] >maxLength)
    {
        trimedBody = [NSString stringWithFormat:@"%@...", trimedBody];
    }
    NSString* requestDescription = [NSString stringWithFormat:@"\nDPPHTTPRequest (%@)\n\t %@ \n\t URL %@ \n\tHeader:\n %@ \n\t \n\t created bt: %@  \n Response: \n\t(response status %d) \n %@",
                                    [self stateDescription],
                                    [DPPHTTPRequest networkQOSRatingDescription],
                                    self.url,
                                    self.headerValues,
                                    self.debugCreatedCallstack,
                                    self.response.header.statusCode,
                                    trimedBody];
    return requestDescription;
}


#pragma mark - start reachability
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
    NSLog(@"ReachabilityCallback");
    [[NSNotificationCenter defaultCenter] postNotificationName:kDPPHTTPRequestNetworkStatusDidChange object:[DPPHTTPRequest class]];
}

+(void)startMonitoringNetworkReachability {
    [self stopMonitoringNetworkReachability];
    @synchronized(self)
    {
        if (!baseURL) {
            return;
        }
        
        networkReachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [[baseURL host] UTF8String]);
        
        if (!networkReachability) {
            return;
        }
        
        SCNetworkReachabilitySetCallback(networkReachability, ReachabilityCallback , nil);
        
        SCNetworkReachabilityScheduleWithRunLoop(networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    }
}

+(void)stopMonitoringNetworkReachability {
    if (networkReachability) {
        SCNetworkReachabilityUnscheduleFromRunLoop(networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
        CFRelease(networkReachability);
        networkReachability = NULL;
    }
}

+(BOOL)networkReachable
{
    return [self networkStatus] != DPPNotReachable;
}

+(DPPHTTPRequestNetworkStatus)networkStatus
{
    @synchronized(self)
    {
        SCNetworkReachabilityFlags flags;
        
        if(SCNetworkReachabilityGetFlags(networkReachability, &flags))
        {
            if((flags & kSCNetworkReachabilityFlagsReachable))
            {
                if(flags & kSCNetworkReachabilityFlagsIsWWAN)
                {
                     return DPPReachableViaWWAN;//3G
                }
                return DPPReachableViaWiFi;//WIFI
            }
            if((flags & kSCNetworkFlagsReachable))
            {
                return DPPReachableViaWiFi;
            }
        }
    }
    return DPPNotReachable;
}

+(void) report_memory {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use: %fMB", (float)info.resident_size/1024./1024.);
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
}

+(void)watchdogTick
{
   // static dispatch_once_t onceToken;
    static DPPHTTPRequestQOSRatingType lastQOSRating = DPPQOSGood;
    
    //LH this will check performance and suspend the low priority queue if needed..
    //also handles reachability
    @synchronized(self)
    {
        @autoreleasepool {
            NSOperationQueue* lowPriorityQueue = [DPPHTTPRequest lowPriorityNetworkQueue];
            
            if(lastQOSRating != [self networkQOSRatingType])
            {//LH send out a QOS notification
                [[NSNotificationCenter defaultCenter] postNotificationName:kDPPHTTPRequestQOSRatingDidChange object:self];
            }
            lastQOSRating = [self networkQOSRatingType];
            static int reduceTick = 0;
            if(reduceTick%5 == 0)
            {
                NSLog(@"DPPHTTPRequest %f MBs (total %fMB) (%d) Main q %d secondary q %d",[DPPHTTPRequest networkQOSMBs],[DPPHTTPRequest totalTransferedMB],[DPPHTTPRequest requestCount],[DPPHTTPRequest defaultNetworkQueue].operationCount,lowPriorityQueue.operationCount);
                [self report_memory];
            }
            reduceTick++;

           /* int liveOperations=0;
            int cancelledOperations =0;
            for(NSOperation* operation in lowPriorityQueue.operations.reverseObjectEnumerator)
            {
                if(!operation.isCancelled && !operation.isFinished)
                {
                    liveOperations++;
                    if(liveOperations > kMaxLowPriorityItems)
                    {
                        [operation cancel];
                        cancelledOperations++;
                    }
                }
            }*/
        }
    }
}

+(float)networkQOSMBs
{
    return transferRateAvrValue;
}

+(float)networkQOSRating
{//1.0 = 3G
    return MIN(2.0,transferRateAvrValue / k3GBandwidthMB); //max out at 2 as we don't care
}

+(DPPHTTPRequestQOSRatingType)networkQOSRatingType
{
    float rating = [self networkQOSRating];
    if(rating > kNormalQOSRating)
    {
        return DPPQOSGood;
    }
    else if(rating > kUsableQOSRating)
    {
        return DPPQOSAverage;
    }
    else if (rating > kLowQOSRating)
    {
        return DPPQOSPoor;
    }

    return DPPQOSVeryPoor;
}

+(NSString*)networkQOSRatingDescription
{
   switch([self networkQOSRatingType])
    {
        case DPPQOSGood:
            return NSLocalizedString(@"Good connection",nil); 
        case DPPQOSAverage:
          return NSLocalizedString(@"Average connection",nil);
        case DPPQOSPoor:
            return NSLocalizedString(@"Slow connection",nil);
        case DPPQOSVeryPoor:
            return NSLocalizedString(@"Very poor connection",nil); 
    }
}

+(void)addTransferRateToWeightedSum:(double)newRate
{
    if(newRate == 0.0) return;
    @synchronized(self)
    {
        newRate = MIN(kWIFIBandwidthMB,newRate); //cap it at WIFI rates as we're not iterested in QOS in high bandwidth case.
        transferRateAvrValue -= (transferRateAvrValue/kRateAvrSample);
        transferRateAvrValue += (newRate/kRateAvrSample);
    }
}

+(void)addBytesTransfered:(NSUInteger)bytes
{
    transferedMB += ((double)bytes / 1024.0/1024.0);
}

+(float)totalTransferedMB
{
    return transferedMB;
}

-(NSTimeInterval)responseTime
{
        if(_responseDate == nil || _startDate ==nil)
        {
            return [[NSDate distantFuture] timeIntervalSince1970];
        }
        return [_responseDate timeIntervalSinceDate:_startDate];
}

-(NSTimeInterval)transferTime
{
        if(_responseDate == nil)
        {
            return [[NSDate distantFuture] timeIntervalSince1970];
        }
        else if(_transferBytes > 0 && _transferDate ==nil)
        {//LH if we've not finished but have had some data, give time so far....
            return [[NSDate date] timeIntervalSinceDate:_responseDate];
        }
        return [_transferDate timeIntervalSinceDate:_responseDate];
}

-(NSTimeInterval)processingTime
{
        if(_transferDate ==nil || _completionDate ==nil)
        {
            return [[NSDate distantFuture] timeIntervalSince1970];
        }
        return [_completionDate timeIntervalSinceDate:_transferDate];
}

-(NSTimeInterval)requestTime
{

        if(_startDate ==nil ||  _completionDate ==nil)
        {
            return [[NSDate distantFuture] timeIntervalSince1970];
        }
        return [_completionDate timeIntervalSinceDate:_startDate];
   
}

-(float)requestTransferRateMBs
{
    float transferTimeSec = [self transferTime];
    if(transferTimeSec != [[NSDate distantFuture] timeIntervalSince1970] && transferTimeSec > 0)
    {
        return (((double)_transferBytes)/1024./1024.) / transferTimeSec;
    }
    return 0;
}

-(float)requestRateMBs
{
    float transferTimeSec = [self requestTime];
    if(transferTimeSec != [[NSDate distantFuture] timeIntervalSince1970])
    {
        return (((double)_transferBytes)/1024./1024.) / transferTimeSec;
    }
    return 0;
}

-(void)addDidRecieveResponseBlockOnBackground:(DPPHTTPResponseBlockType)responseBlock
{
    if(self.completed)
    {
        if(self.state == DPPComplete)
        {
            dispatch_async([DPPHTTPRequest defaultDispatchQueue],^()
                           {
                               @autoreleasepool {  //LH this is to garantee any created objects are released right away, GCD may release after several ops
                                   responseBlock(self);
                               }
                           });
        }
    }
    else
    {
        if(self.didRecieveResponseBlockOnBackground)
        {
            DPPHTTPResponseBlockType oldBlock = self.didRecieveResponseBlockOnBackground;
            self.didRecieveResponseBlockOnBackground = ^(DPPHTTPRequest* blockRequest)
            {
                oldBlock(blockRequest);
                responseBlock(blockRequest);
            };
        }
        else
        {
            self.didRecieveResponseBlockOnBackground = responseBlock;
        }
    }
}

-(void)addDidRecieveResponseBlock:(DPPHTTPResponseBlockType)responseBlock
{
    if(self.completed)
    {
        if(self.state == DPPComplete)
        {
                responseBlock(self);
        }
    }
    else
    {
        if(self.didRecieveResponseBlock)
        {
            DPPHTTPResponseBlockType oldBlock = self.didRecieveResponseBlock;
            self.didRecieveResponseBlock = ^(DPPHTTPRequest* blockRequest)
            {
                oldBlock(blockRequest);
                responseBlock(blockRequest);
            };
        }
        else
        {
            self.didRecieveResponseBlock = responseBlock;
        }
    }
}

-(void)addDidFailToRecieveResponseBlock:(void(^)(DPPHTTPRequest* request,NSError* error))responseBlock
{
    if(self.completed)
    {
        if(self.state == DPPComplete)
        {
                responseBlock(self,nil);
        }
    }
    else
    {
        if(self.didRecieveResponseBlock)
        {
            DPPHTTPResponseFailBlockType oldBlock = self.didFailToRecieveResponseBlock;
            self.didFailToRecieveResponseBlock = ^(DPPHTTPRequest* blockRequest,NSError* error)
            {
                oldBlock(blockRequest,error);
                responseBlock(blockRequest,error);
            };
        }
        else
        {
            self.didFailToRecieveResponseBlock = responseBlock;
        }
    }
}

-(void)dealloc
{
   // NSLog(@"dealloc'd request");
    self.internalConnection = nil;
    self.internalData = nil;
    self.internalRequest = nil;
    self.response = nil;
    _debugCreatedCallstack =nil;
}

+ (BOOL)isOfflineError:(NSError *)error
{
    if ([error.domain isEqualToString:@"NSURLErrorDomain"])
    {
        if(error.code == kCFURLErrorNotConnectedToInternet)
        {
            return YES;
        }
    }
    return NO;
}

@end
