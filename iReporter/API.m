//
//  API.m
//  iReporter
//
//  Created by Sangwook Nam on 3/26/14.
//  Copyright (c) 2014 Marin Todorov. All rights reserved.
//

#import "API.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

//#define kAPIHost @"http://flowgrammer.com"
//#define kAPIPath @"iReporter/"

#if TARGET_IPHONE_SIMULATOR
    #define kAPIHost @"http://192.168.0.3:8080"
    #define kAPIHostHttps @"https://192.168.0.3:8443"
#else
    #define kAPIHost @"http://flowgrammer.com:8080"
    #define kAPIHostHttps @"https://flowgrammer.com:8443"
#endif

#define kAPIPath @"jReporter/main.do"
#define kPhotoPath @"jReporter/"
#define kAPIPathForFileUpload @"jReporter/UploadServlet"

@implementation API

+ (API *)sharedInstance
{
    static API *sharedInstance = nil;
    if (sharedInstance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAPIHost]];
        });
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.user = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)isAuthorized
{
    return [self.user[@"IdUser"] intValue] > 0;
}

- (void)commandWithParams:(NSMutableDictionary *)params onCompletion:(JSONResponseBlock)completionBlock
{
    [self commandWithParams:params isHttps:NO onCompletion:completionBlock];
}

- (void)commandWithParams:(NSMutableDictionary *)params isHttps:(BOOL)isHttps onCompletion:(JSONResponseBlock)completionBlock
{
    NSData* uploadFile = nil;
    if ([params objectForKey:@"file"]) {
        uploadFile = (NSData*)[params objectForKey:@"file"];
        [params removeObjectForKey:@"file"];
    }
    
    if (uploadFile != nil) {
        NSURL *requestUrl = [NSURL URLWithString:kAPIPath relativeToURL:self.baseURL];
        if (isHttps) {
            NSString *urlString = [NSString stringWithFormat:@"%@/%@", kAPIHostHttps, kAPIPath];
            requestUrl = [NSURL URLWithString:urlString];
        }
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager]; //initialize
        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        manager.securityPolicy = policy;
#if TARGET_IPHONE_SIMULATOR
        manager.securityPolicy.allowInvalidCertificates=YES;    //allow unsigned
#endif
        manager.responseSerializer = [AFJSONResponseSerializer serializer];   //set up for JSOn
        [manager POST:requestUrl.absoluteString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (uploadFile) {
                [formData appendPartWithFileData:uploadFile
                                            name:@"file"
                                        fileName:@"photo.jpg"
                                        mimeType:@"image/jpeg"];
            }
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
        }];
    }
    else {
        NSURL *requestUrl = [NSURL URLWithString:kAPIPath relativeToURL:self.baseURL];
        if (isHttps) {
            NSString *urlString = [NSString stringWithFormat:@"%@/%@", kAPIHostHttps, kAPIPath];
            requestUrl = [NSURL URLWithString:urlString];
//            [self setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition (NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential) {
//                return NSURLSessionAuthChallengePerformDefaultHandling;
//            }];
        }
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager]; //initialize
        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        manager.securityPolicy = policy;
#if TARGET_IPHONE_SIMULATOR
        manager.securityPolicy.allowInvalidCertificates=YES;    //allow unsigned
#endif
        manager.responseSerializer = [AFJSONResponseSerializer serializer];   //set up for JSOn
        [manager POST:requestUrl.absoluteString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
        }];
    }
}

-(NSURL*)urlForImageWithId:(NSNumber*)IdPhoto isThumb:(BOOL)isThumb
{
#if TARGET_IPHONE_SIMULATOR
    NSString* urlString = [NSString stringWithFormat:@"%@/%@jReporterUpload/%@%@.jpg",
                           kAPIHost, kPhotoPath, IdPhoto, (isThumb)?@"-thumb":@""
                           ];
#else
    NSString* urlString = [NSString stringWithFormat:@"http://flowgrammer.com/jReporterUpload/%@%@.jpg",
                           IdPhoto, (isThumb)?@"-thumb":@""
                           ];
#endif
    return [NSURL URLWithString:urlString];
}

@end
