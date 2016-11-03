//
//  PersonInfoModel.h
//  Voicedin
//
//  Created by zhangyj on 15-10-29.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiseaseModel.h"

@interface PersonInfoModel : NSObject

@property (nonatomic, strong) NSArray *sex;
@property (nonatomic, strong) NSArray *provinces;
@property (nonatomic, strong) NSArray *educations;
@property (nonatomic, strong) NSArray *careers;
@property (nonatomic, strong) NSArray *diseases;

@end
