//
//  API.h
//  iReporter
//
//  Created by Sangwook Nam on 3/26/14.
//  Copyright (c) 2014 Marin Todorov. All rights reserved.
//

#import "AFHTTPSessionManager.h"

typedef void (^JSONResponseBlock)(NSDictionary *json);

@interface API : AFHTTPSessionManager

@property (strong, nonatomic) NSDictionary *user;

+ (API *)sharedInstance;

- (BOOL)isAuthorized;

- (void)commandWithParams:(NSMutableDictionary *)params onCompletion:(JSONResponseBlock)completionBlock;

- (void)commandWithParams:(NSMutableDictionary *)params isHttps:(BOOL)isHttps onCompletion:(JSONResponseBlock)completionBlock;

-(NSURL*)urlForImageWithId:(NSNumber*)IdPhoto isThumb:(BOOL)isThumb;

@end
