//
//  LoginOrOut.m
//  Voicedin
//
//  Created by zhangyj on 15-11-5.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "LoginOrOut.h"
#import "Author.h"
#import "NetworkingManager.h"

@implementation LoginOrOut

+ (void)loginWithAuth_id:(NSString *)auth_id andRegistID:(NSString *)regist_id callBack:(void(^)(id responseObj, NSError *error))callBack {
    
    //发送登录请求
    NetworkingManager *mgr = [NetworkingManager sharedNetworkingManager];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"auth_id"] = auth_id;
    params[@"registration_id"] = regist_id;
//    params[@"registration_id"] = @"001f5d462e2";
    
    [mgr POST:loginUrlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (callBack) {
            callBack(responseObject, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (callBack) {
            callBack(nil, error);
        }
    }];
    
}


+ (void)logoutWithAuthor:(Author *)author callBack:(void(^)(id responseObj, NSError *error))callBack {
    
    //发送注销请求
    NetworkingManager *mgr = [NetworkingManager sharedNetworkingManager];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"auth_id"] = author.auth_id;
    
    [mgr POST:logoutUrlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject[@"message"] isEqualToString:@"successful"]) {
            
            [mgr.reachabilityMgr stopMonitoring];
        }
        if (callBack) {
            callBack(responseObject, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //网络状态变化时
        [mgr.reachabilityMgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
                [self logoutWithAuthor:author callBack:^(id responseObj, NSError *error) {
                    if ([responseObj[@"message"] isEqualToString:@"successful"]) {
                        ZJLog(@"重新注销成功----------%@",author.auth_id);
                    }else {
                        ZJLog(@"重新注销失败");
                    }
                }];
            }
        }];
        [mgr.reachabilityMgr startMonitoring];
        if (callBack) {
            callBack(nil, error);
        }
        
    }];
}

@end
