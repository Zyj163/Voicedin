//
//  PersonInfoModel.m
//  Voicedin
//
//  Created by zhangyj on 15-10-29.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "PersonInfoModel.h"

@implementation PersonInfoModel

- (NSDictionary *)objectClassInArray {
    return @{@"diseases" : [DiseaseModel class]};
}

@end
