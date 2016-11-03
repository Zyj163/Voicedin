//
//  RecroderManager.h
//  Voicedin
//
//  Created by zhangyongjun on 15/9/27.
//  Copyright © 2015年 xitong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class Person;
@class Author;

@interface RecroderManager : NSObject

/**
 *  根据录音名获取阶段录音对象
 *
 *  @param name 录音名
 *
 *  @return 阶段录音对象
 */
+ (AVAudioRecorder *)getCourseRecorderWithName:(NSString *)name;
/**
 *  根据录音名记录录音开始时间
 *
 *  @param name 录音名
 *
 *  @param date 开始时间
 */
+ (void)setRecordWithName:(NSString *)name startTime:(NSTimeInterval)time;
/**
 *  根据录音名记录录音结束时间
 *
 *  @param name 录音名
 *
 *  @param date 结束时间
 */
+ (void)setRecordWithName:(NSString *)name endTime:(NSTimeInterval)time;

+ (void)setRecordTimeFlagPart:(NSString *)part;

+ (void)setRecordTimeFlagPerson:(Person *)person;

/**
 *  上传录音
 *
 *  @param name         录音名
 *  @param successBlock 上传成功回调方法
 *  @param failureBlock 上传失败回调方法
 */
+ (void)uploadRecorderWithName:(NSString *)name success:(void(^)(id responseObj))successBlock failure:(void(^)())failureBlock;
/**
 *  根据录音名删除录音
 *
 *  @param name 录音名
 */
+ (void)deleteRecordWithName:(NSString *)name;
/**
 *  根据病人删除其所有录音
 *
 *  @param person 病人对象
 */
+ (void)deleteRecordsOfPerson:(Person *)person;
/**
 *  根据名称删除时间戳
 *
 *  @param name 时间戳名称
 */
+ (void)deleteRecordTimeFlagWithName:(NSString *)name;
/**
 *  根据病人删除其所有时间戳
 *
 *  @param person 病人对象
 */
+ (void)deleteRecordTimeFlagsOfPerson:(Person *)person;

+ (void)stopRecord;

@end







