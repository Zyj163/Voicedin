//
//  Person.h
//  Voicedin
//
//  Created by zhangyj on 15-9-22.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject
/**
 *  唯一标示
 */
@property (nonatomic, copy) NSString *uuid;
/**
 *  就诊卡号
 */
@property (nonatomic, copy) NSString *kid;
/**
 *  姓名
 */
@property (nonatomic, copy) NSString *name;
/**
 *  性别
 */
@property (nonatomic, copy) NSString *sex;
/**
 *  职业
 */
@property (nonatomic, copy) NSString *career;
/**
 *  病症
 */
@property (nonatomic, copy) NSString *disease;
/**
 *  病症程度
 */
@property (nonatomic, copy) NSString *grade;
/**
 *  录音医生
 */
@property (nonatomic, copy) NSString *doctor;
/**
 *  年龄
 */
@property (nonatomic, copy) NSString *age;
/**
 *  籍贯
 */
@property (nonatomic, copy) NSString *province;
/**
 *  文化程度
 */
@property (nonatomic, copy) NSString *education;


/**
 *  新增病人
 */
@property (nonatomic, assign, getter=isNewAdd) BOOL newAdd;
/**
 *  所有检测报告
 */
@property (strong, nonatomic) NSMutableArray *reports;
/**
 *  当前检测阶段
 */
@property (strong, nonatomic) NSString *part;

@end













