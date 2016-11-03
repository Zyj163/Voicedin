//
//  NSDate+FormatterDate.h
//  Voicedin
//
//  Created by zhangyj on 15-10-15.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (FormatterDate)

- (NSString *)convertdateToFormatter:(NSString *)formatter;
+ (instancetype)dateFromFormatter:(NSString *)formatter WithDateStr:(NSString *)dateStr;
@end
