//
//  NetworkingManager.h
//  Voicedin
//
//  Created by zhangyj on 15-10-8.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"

@interface NetworkingManager : NSObject

ZJSingleton_h(NetworkingManager);

/**
 *  文件上传
 *
 *  @param urlStr                上传地址
 *  @param params                请求参数
 *  @param constructingBodyBlock 文件拼接
 *  @param success               上传成功
 *  @param failure               上传失败
 */
- (void)POST:(NSString *)urlStr parameters:(NSDictionary *)params constructingBodyWithBlock:(void(^)(id<AFMultipartFormData> formData))constructingBodyBlock success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 *  非文件上传POST请求
 *
 *  @param urlStr  请求地址
 *  @param params  请求参数
 *  @param success 请求成功
 *  @param failure 请求失败
 */
- (void)POST:(NSString *)urlStr parameters:params success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 *  GET请求
 *
 *  @param urlStr  请求地址
 *  @param params  请求参数
 *  @param success 请求成功
 *  @param failure 请求失败
 */
- (void)GET:(NSString *)urlStr parameters:(NSDictionary *)params success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;


@property (readwrite, nonatomic, strong) AFNetworkReachabilityManager *reachabilityMgr;

@end















