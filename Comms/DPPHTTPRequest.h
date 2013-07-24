//
//  DPPHTTPRequest.h
//  Created by Lee Higgins on 15/04/2012.
//

#import <Foundation/Foundation.h>
#import "DPPHTTPResponse.h"

#define kHTTP_PUT_METHOD_STRING @"PUT"
#define kHTTP_POST_METHOD_STRING @"POST"                //LH todo make these internal string constants
#define kHTTP_GET_METHOD_STRING @"GET"
#define kHTTP_HEADER_METHOD_STRING @"HEAD"
#define kHTTP_PATCH_METHOD_STRING @"PATCH"

#define kHTTPContentLengthHeaderKey @"Content-Length"
#define kHTTPContentTypeHeaderKey @"Content-Type"
#define kHTTPContentAcceptEncodingHeaderKey @"Accept-Encoding"

#define kHTTPContentURLEncodedHeaderValue @"application/x-www-form-urlencoded"
#define kHTTPContentTypeJPEG @"image/jpeg"
#define kHTTPContentTypeJSON @"application/json"

#define kHTTPStatusCodeOK 200
#define kHTTPStatusCodeCREATED 201
#define kHTTPStatusCodeNoContent 204
#define kHTTPStatusCodeClientError 400
#define kHTTPStatusCodeClientInvalidCredentials 401
#define kHTTPStatusCodeSeverError 500


#define kDefaultNetworkQueueMaxConcurrent 3
#define kLowPriorityNetworkQueueMaxConcurrent 3
#define kMaxLowPriorityItems 25

#define kDefaultQueueStartupExclusiveTime 0.5
#define kNormalQOSRating 0.5 //must be above this to be OK
#define kUsableQOSRating 0.25 //must be above this to be usable
#define kLowQOSRating 0.125 //must be above this to be poor (below is unusable)

#define kRateAvrSample 2.0 //LH how many samples to average over (higher number responds more slowly to network bandwidth changes) 

#define kEdgeBandwidthMB 0.029296875 //240kbps edge connection in MB
#define k3GBandwidthMB 0.09521484375 //780kbps 3G connection in MB
#define kWIFIBandwidthMB 2.5 //20Mbps WIFI connection in MB

#define kMaxUserWait 5.0


extern NSString *const kDPPHTTPRequestQOSRatingDidChange;
extern NSString *const kDPPHTTPRequestNetworkStatusDidChange;

@class DPPHTTPRequest;
@class NSManagedObject;

typedef enum {
    DPPQOSGood,
    DPPQOSAverage,
    DPPQOSPoor,
    DPPQOSVeryPoor} DPPHTTPRequestQOSRatingType;

typedef enum
{
	DPPNotReachable     = 0,
	DPPReachableViaWiFi = 2,
	DPPReachableViaWWAN = 1
} DPPHTTPRequestNetworkStatus;

typedef void(^(DPPHTTPResponseBlockType))(DPPHTTPRequest*);
typedef void(^(DPPHTTPResponseFailBlockType))(DPPHTTPRequest* request,NSError* error);

typedef enum {
    DPPUnknown,
    DPPCreated,     //waiting to be asked to connect or to be queued
    DPPQueued,
    DPPConnecting,  //just started, waiting for response
    DPPConnected,   //connected OK
    DPPComplete,    
    DPPCancelled,   
    DPPFailed} DPPRequestState;

@protocol DPPHTTPRequestDelegate <NSObject>

@optional

-(void)willRecieveResponse:(DPPHTTPRequest*)request;
-(void)didRecieveResponse:(DPPHTTPRequest*)request;
-(void)didFailToRecieveResponse:(DPPHTTPRequest*)request error:(NSError*)error;
-(void)didRecieveProgress:(DPPHTTPRequest*)request;

@end

@interface DPPHTTPRequest : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate>


@property(nonatomic,readonly) DPPRequestState state;
@property(nonatomic,readonly) BOOL cancelled;
@property(nonatomic,readonly) NSURLRequest* request;
@property(nonatomic,readonly) NSURL* url;
@property(nonatomic,strong) DPPHTTPResponse* response;
@property(nonatomic,weak) id<DPPHTTPRequestDelegate> delegate; //LH deprecated
@property(nonatomic,assign) NSTimeInterval connectiontTimeoutInterval;
@property(nonatomic,assign) NSTimeInterval networkQOSTimeoutInterval; //Quality of service timeout (entire request timeout not just connection)
@property(nonatomic,readonly) BOOL networkQOSTimeoutExpired;

@property(nonatomic,copy) NSString* username;
@property(nonatomic,copy) NSString* password;

@property(nonatomic,assign) NSUInteger  bodyStreamBufferSize;
@property(nonatomic,assign) BOOL    completed;
@property(nonatomic,readonly) BOOL inProgress;
@property(nonatomic,readonly) float progress;
@property(nonatomic,assign) BOOL cached;
@property(nonatomic,strong) NSMutableDictionary* headerValues;
@property(nonatomic,readonly) NSArray* dependencies;
@property(nonatomic,readonly) int numberOfTries;

@property(nonatomic,readonly) NSArray* debugCreatedCallstack; //LH this holds the call stack for when the socket was created (for debugging)

@property(nonatomic,copy) void(^willRecieveResponseBlock)(DPPHTTPRequest* request);
@property(nonatomic,copy) void(^didRecieveResponseBlock)(DPPHTTPRequest* request);
@property(nonatomic,copy) void(^didFailToRecieveResponseBlock)(DPPHTTPRequest* request,NSError* error);
@property(nonatomic,copy) void(^didRecieveProgressBlock)(DPPHTTPRequest* request);
@property(nonatomic,copy) void(^networkQOSDidTimeout)(DPPHTTPRequest* request);

@property(nonatomic,copy) void(^didRecieveResponseBlockOnBackground)(DPPHTTPRequest* request);
@property(nonatomic,copy) void(^didRecieveResponseBlockOnBackgroundCompletion)(DPPHTTPRequest* request);


+(void)setupCacheWithMemorySizeMB:(float)memorySize diskSizeMB:(float)diskSize;
+(DPPHTTPRequest*)httpRequestWithURL:(NSURL*)url method:(NSString*)method;

+(DPPHTTPRequest*)httpGETRequestWithURL:(NSURL*)url;

+(id)httpRequestWithURL:(NSURL*)url
                 method:(NSString*)httpMethod
                 onSuccess:(void(^)(DPPHTTPRequest* request))success
                 onFailure:(void(^)(DPPHTTPRequest* request,NSError* error))failure;

+(id)httpGETRequestWithURL:(NSURL*)url
                 onSuccess:(void(^)(DPPHTTPRequest* request))success
                 onFailure:(void(^)(DPPHTTPRequest* request,NSError* error))failure;

+(DPPHTTPRequest*)httpGETRequestWithURL:(NSURL*)url
                   responseInBackground:(void(^)(DPPHTTPRequest* request))background
                             completion:(void(^)(DPPHTTPRequest* request))completion;

+(DPPHTTPRequest*)httpHEADERRequestWithURL:(NSURL*)url;

+(DPPHTTPRequest*)httpPOSTRequestWithURL:(NSURL*)url postData:(NSData*)postData
                         withContentType:(NSString*)contentType
                    responseInBackground:(void(^)(DPPHTTPRequest* request))background
                              completion:(void(^)(DPPHTTPRequest* request))completion;

+(DPPHTTPRequest*)httpPOSTRequestWithURL:(NSURL*)url
                                postData:(NSData*)postData
                         withContentType:(NSString*)contentType
                               onSuccess:(void(^)(DPPHTTPRequest* request))success
                               onFailure:(void(^)(DPPHTTPRequest* request,NSError* error))failure;

+(DPPHTTPRequest*)httpPOSTRequestWithURL:(NSURL*)url postData:(NSData*)postData withContentType:(NSString*)contentType;
+(DPPHTTPRequest*)httpPOSTRequestWithURL:(NSURL*)url postStream:(NSInputStream*)inputStream withContentType:(NSString*)contentType contentLength:(NSInteger)length;
+(DPPHTTPRequest*)httpPOSTRequestWithURL:(NSURL*)url postFile:(NSURL*)inputFile withContentType:(NSString*)contentType;
+(DPPHTTPRequest*)httpPUTRequestWithURL:(NSURL*)url putData:(NSData*)postData withContentType:(NSString*)contentType;
+(DPPHTTPRequest*)httpPUTRequestWithURL:(NSURL*)url putStream:(NSInputStream*)inputStream withContentType:(NSString*)contentType;
+(DPPHTTPRequest*)httpPUTRequestWithURL:(NSURL*)url putFile:(NSURL*)inputFile withContentType:(NSString*)contentType;
+(DPPHTTPRequest*)httpPUTFormFile:(NSURL*)url putData:(NSData*)data forFormField:(NSString*)formField;
+(DPPHTTPRequest*)httpPATCHRequestWithURL:(NSURL*)url patchData:(NSData*)patchData withContentType:(NSString*)contentType;

+(DPPHTTPRequest*)httpPATCHRequestWithURL:(NSURL*)url patchData:(NSData*)patchData withContentType:(NSString*)contentType
                     responseInBackground:(void(^)(DPPHTTPRequest* request))background
                               completion:(void(^)(DPPHTTPRequest* request))completion;

+(DPPHTTPRequest*)httpPATCHRequestWithURL:(NSURL*)url patchData:(NSData*)patchData withContentType:(NSString*)contentType
                                onSuccess:(void(^)(DPPHTTPRequest* request))success
                                onFailure:(void(^)(DPPHTTPRequest* request,NSError* error))failure;


+(DPPHTTPRequest*)findRequestWithURL:(NSURL*)url;

-(DPPHTTPRequest*)initWithRequest:(NSMutableURLRequest*)newRequest;
-(DPPHTTPRequest*)initWithURL:(NSURL*)url;

+(BOOL)isOfflineError:(NSError *)error;

//LH cancel all operation in the default queues, including the lowPriority queue....
+(void)cancelQueue;
+(void)cancelQueue:(NSOperationQueue*)queue;

+(void)setDebugMode:(BOOL)debug;

-(void)cancel;
-(void)cancelIfNotInProgress;
-(void)start;

#pragma mark Queue system

+(NSOperationQueue*)defaultNetworkQueue; //LH main data queue (use for data i.e json/xml)
+(NSOperationQueue*)lowPriorityNetworkQueue; //LH this queue will be suspended in low bandwidth conditions and may even cancel operations (use for images)

+(void)setDefaultNetworkQueue:(NSOperationQueue*)operationQueue;
+(void)setLowPriorityNetworkQueue:(NSOperationQueue*)operationQueue;

+(void)enqueueURLRequest:(NSURLRequest*)request; //Used to add external requests to the system, will use the default queue
+(void)enqueueURLRequest:(NSURLRequest*)request withPriority:(NSOperationQueuePriority)priority;

+(void)suspendLowPriority:(BOOL)suspend; //suspend/resume the low priority queue
+(void)suspendLowPriority:(BOOL)suspend cancelOperations:(BOOL)cancel; //same as above but also cancel all operation in the queue

-(NSOperation*)enqueue; //add the request to the default queue
-(NSOperation*)enqueueWithPriority:(NSOperationQueuePriority)priority; //add the request to the default queue with a priority
-(NSOperation*)enqueueInOperationQueue:(NSOperationQueue*)queue withPriority:(NSOperationQueuePriority)priority;
-(NSOperation*)createOperation;

#warning LH dependencies untested for now.....
//LH add dependent requests, supports trees.. 
-(void)addDependencies:(NSArray*)requests;
-(void)addDependency:(DPPHTTPRequest*)dependant;
-(void)removeDependencies:(NSArray*)objects;
-(void)removeDependency:(DPPHTTPRequest*)request;

-(BOOL)containedInCache:(NSURLCache*)cache;

-(void)waitUntilDone;

-(void)clearCompletionCallbacks;
-(void)clearALLCallbacks;

-(void)addDidRecieveResponseBlock:(DPPHTTPResponseBlockType)responseBlock;
-(void)addDidRecieveResponseBlockOnBackground:(DPPHTTPResponseBlockType)reponseBlock;
-(void)addDidFailToRecieveResponseBlock:(void(^)(DPPHTTPRequest* request,NSError* error))responseBlock;

#pragma mark QOS metrics

+(BOOL)networkReachable;
+(DPPHTTPRequestNetworkStatus)networkStatus;
+(NSString*)networkQOSRatingDescription;
+(float)networkQOSRating;
+(float)networkQOSMBs;
+(DPPHTTPRequestQOSRatingType)networkQOSRatingType;
+(void)addBytesTransfered:(NSUInteger)bytes;
+(float)totalTransferedMB;

+(NSArray*)allRequests;

-(NSTimeInterval)requestTime;
-(NSTimeInterval)responseTime;
-(NSTimeInterval)transferTime;
-(NSTimeInterval)processingTime;

-(float)requestRateMBs; //MegaBytes per sec for entire request time (including response time)
-(float)requestTransferRateMBs; //MegaBytes per sec for transfer only (not including response time)


@end
