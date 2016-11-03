//
//  PersonTool.h
//  Voicedin
//
//  Created by zhangyj on 15-9-24.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Person;
@class Author;

@interface PersonTool : NSObject

ZJSingleton_h(PersonTool);

- (void)sendPersonInfo:(Person *)person ofAuthor:(Author *)author WithSuccess:(void(^)())success failure:(void(^)())failure;
- (Person *)getCurrentPerson;
- (void)setCurrentPerson:(Person *)person;

- (void)getDiseaseWithSuccess:(void(^)(NSArray *disease))success failure:(void(^)(NSError *error))failure;
- (void)getGrade:(NSString *)diseaseID WithSuccess:(void(^)(NSArray *grades))success failure:(void(^)(NSError *error))failure;
- (void)judgeNewAddPersonUseName:(NSString *)name kid:(NSString *)kid andAuthID:(NSString *)auth_id WithSuccess:(void(^)(NSDictionary *personDic))success failure:(void(^)(NSError *error))failure;

@end
