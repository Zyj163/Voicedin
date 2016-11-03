//
//  NetworkingManager.m
//  Voicedin
//
//  Created by zhangyj on 15-10-8.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "NetworkingManager.h"

@implementation NetworkingManager

ZJSingleton_m(NetworkingManager)

- (void)POST:(NSString *)urlStr parameters:(NSDictionary *)params constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))constructingBodyBlock success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    [mgr POST:urlStr parameters:params constructingBodyWithBlock:constructingBodyBlock success:success failure:failure];
}

- (void)POST:(NSString *)urlStr parameters:(id)params success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    [mgr POST:urlStr parameters:params success:success failure:failure];
}

- (void)GET:(NSString *)urlStr parameters:(NSDictionary *)params success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    [mgr GET:urlStr parameters:params success:success failure:failure];
}

- (AFNetworkReachabilityManager *)reachabilityMgr {
    if (!_reachabilityMgr) {
        _reachabilityMgr = [[AFHTTPRequestOperationManager manager] reachabilityManager];
    }
    return _reachabilityMgr;
}

@end
