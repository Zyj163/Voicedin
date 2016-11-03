//
//  TimeOpt.m
//  Voicedin
//
//  Created by zhangyj on 15-11-3.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "TimeOpt.h"
#import "NSDate+FormatterDate.h"

static NSString *_globalDateStr;

@implementation TimeOpt

+ (void)setGlobalTime:(NSDate *)date {
    if (date) {
        _globalDateStr = [date convertdateToFormatter:@"yyyy-MM-dd_HH-mm"];
    }else {
        _globalDateStr = @"";
    }
    NSError *error;
    [_globalDateStr writeToFile:timeOptFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        ZJLog(@"记录全局时间失败");
    }
}

+ (void)reset {
    _globalDateStr = nil;
}

+ (NSString *)getGlobalTimeStr {
    if (!_globalDateStr || _globalDateStr.length == 0) {
        NSError *error;
        _globalDateStr = [NSString stringWithContentsOfFile:timeOptFile encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            ZJLog(@"获取全局时间失败");
        }
    }
    return _globalDateStr;
}

@end









