//
//  CATextLayer+Extension.m
//  Voicedin
//
//  Created by zhangyj on 15-9-24.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "CATextLayer+Extension.h"

@implementation CATextLayer (Extension)

+ (instancetype)textLayerWithStr:(NSString *)str color:(UIColor *)color fontSize:(CGFloat)size alimentMode:(NSString *)mode {
    
    CATextLayer *textLayer = [[self alloc]init];
    textLayer.string = str;
    textLayer.fontSize = size;
    textLayer.foregroundColor = color.CGColor;
    textLayer.alignmentMode = mode;
    return textLayer;
    
}

+ (instancetype)textLayerWithStr:(NSString *)str attrs:(NSDictionary*)attrs {
    CATextLayer *textLayer = [[self alloc]init];
    textLayer.string = str;
    textLayer.fontSize = [attrs[@"fontSize"] floatValue];
    textLayer.foregroundColor = [attrs[@"color"] CGColor];
    textLayer.alignmentMode = attrs[@"mode"];
    return textLayer;
}

@end
