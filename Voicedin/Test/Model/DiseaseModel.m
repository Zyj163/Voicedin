//
//  DiseaseModel.m
//  Voicedin
//
//  Created by zhangyj on 15-10-29.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "DiseaseModel.h"
#import "PersonTool.h"

@implementation DiseaseModel

- (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"ID" : @"id"};
}

- (NSDictionary *)objectClassInArray {
    return @{@"grades" : [GradesModel class]};
}

@end
