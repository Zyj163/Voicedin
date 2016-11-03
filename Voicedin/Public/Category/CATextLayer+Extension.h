//
//  CATextLayer+Extension.h
//  Voicedin
//
//  Created by zhangyj on 15-9-24.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CATextLayer (Extension)

+ (instancetype)textLayerWithStr:(NSString *)str color:(UIColor *)color fontSize:(CGFloat)size alimentMode:(NSString *)mode;

+ (instancetype)textLayerWithStr:(NSString *)str attrs:(NSDictionary*)attrs;

@end
