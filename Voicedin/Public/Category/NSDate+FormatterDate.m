//
//  NSDate+FormatterDate.m
//  Voicedin
//
//  Created by zhangyj on 15-10-15.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "NSDate+FormatterDate.h"

@implementation NSDate (FormatterDate)

- (NSString *)convertdateToFormatter:(NSString *)formatter {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = formatter;
    
    return [format stringFromDate:self];
}

+ (instancetype)dateFromFormatter:(NSString *)formatter WithDateStr:(NSString *)dateStr {
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    format.dateFormat = formatter;
    [format setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"]];
    NSDate *date = [[self alloc]init];
    date = [format dateFromString:dateStr];
    return date;
}

@end
