//
//  LoginOrOut.h
//  Voicedin
//
//  Created by zhangyj on 15-11-5.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Author;

@interface LoginOrOut : NSObject

+ (void)loginWithAuth_id:(NSString *)auth_id andRegistID:(NSString *)regist_id callBack:(void(^)(id responseObj, NSError *error))callBack;
+ (void)logoutWithAuthor:(Author *)author callBack:(void(^)(id responseObj, NSError *error))callBack;

@end
