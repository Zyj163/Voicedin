//
//  PersonTool.m
//  Voicedin
//
//  Created by zhangyj on 15-9-24.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "PersonTool.h"
#import "Person.h"
#import "NetworkingManager.h"
#import "Author.h"

static Person *_person;

@interface PersonTool ()
@end

@implementation PersonTool

ZJSingleton_m(PersonTool)

+ (void)initialize {
    _person = [[Person alloc]init];
}

- (void)sendPersonInfo:(Person *)person ofAuthor:(Author *)author WithSuccess:(void(^)())success failure:(void(^)())failure {
    
    NetworkingManager *mgr = [NetworkingManager sharedNetworkingManager];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"auth_id"] = author.auth_id;
    params[@"kid"] = person.kid;
    params[@"name"] = person.name;
    params[@"sex"] = person.sex;
    params[@"province"] = person.province;
    params[@"career"] = person.career;
    params[@"education"] = person.education;
    params[@"disease"] = person.disease;
    params[@"grade"] = person.grade;
    params[@"doctor"] = person.doctor;
    params[@"age"] = person.age;
    
    [mgr POST:uploadPersonInfoUrlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) {
            success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ZJLog(@"%@",error);
        if (failure) {
            failure();
        }
    }];
}

- (Person *)getCurrentPerson {
    return _person;
}

- (void)setCurrentPerson:(Person *)person {
    _person = person;
}

- (void)getDiseaseWithSuccess:(void(^)(NSArray *disease))success failure:(void(^)(NSError *error))failure {
    NetworkingManager *mgr = [NetworkingManager sharedNetworkingManager];
    
    [mgr POST:getDiseaseUrlStr parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"message"] isEqualToString:@"successful"]) {
            
            ZJLog(@"获取病症列表成功");
            success(responseObject[@"data"]);
        }else {
            ZJLog(@"没有对应病症列表");
            failure(nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
        ZJLog(@"获取病症列表失败：%@", error);
    }];
}

- (void)getGrade:(NSString *)diseaseID WithSuccess:(void(^)(NSArray *grades))success failure:(void(^)(NSError *error))failure {
    NetworkingManager *mgr = [NetworkingManager sharedNetworkingManager];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"id"] = diseaseID;
    
    [mgr POST:getGradeUrlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        ZJLog(@"病症程度列表:%@",responseObject);
        
        if ([responseObject[@"message"] isEqualToString:@"successful"]) {
            
            ZJLog(@"获取病症程度列表成功");
            success(responseObject[@"data"]);
        }else {
            ZJLog(@"没有对应病症得病症程度列表");
            failure(nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
        ZJLog(@"获取病症程度列表失败：%@", error);
    }];
}

- (void)judgeNewAddPersonUseName:(NSString *)name kid:(NSString *)kid andAuthID:(NSString *)auth_id WithSuccess:(void(^)(NSDictionary *personDic))success failure:(void(^)(NSError *error))failure {
    NetworkingManager *mgr = [NetworkingManager sharedNetworkingManager];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"auth_id"] = auth_id;
    params[@"name"] = name;
    params[@"kid"] = kid;
    
    [mgr POST:judgeNewPerson parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject[@"message"] isEqualToString:@"successful"]) {
            if ([responseObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                success(responseObject[@"data"]);
            }
            else {
                failure(nil);
            }
        }else {
            failure(nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

@end
