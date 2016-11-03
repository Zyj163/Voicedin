//
//  Report.h
//  Voicedin
//
//  Created by zhangyongjun on 15/9/26.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Report : NSObject

/**
 *  时间
 */
@property (strong, nonatomic) NSDate *date;
/**
 *  总分
 */
@property (strong, nonatomic) NSNumber *totalScore;
/**
 *  构音系统得分
 */
@property (strong, nonatomic) NSNumber *constructScore;
/**
 *  发音系统得分
 */
@property (strong, nonatomic) NSNumber *pronounceScore;
/**
 *  语音主观感知自动评分
 */
@property (strong, nonatomic) NSNumber *subjectiveScore;
/**
 *  详细评分
 */
@property (strong, nonatomic) UIImage *detailImage;

@end






