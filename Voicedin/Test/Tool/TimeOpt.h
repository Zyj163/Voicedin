//
//  TimeOpt.h
//  Voicedin
//
//  Created by zhangyj on 15-11-3.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeOpt : NSObject

+ (void)setGlobalTime:(NSDate *)date;
+ (void)reset;
+ (NSString *)getGlobalTimeStr;

@end
