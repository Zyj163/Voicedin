//
//  NSObject+LogWithIvar.m
//  Voicedin
//
//  Created by zhangyj on 15-11-2.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "NSObject+LogWithIvar.h"

@implementation NSObject (LogWithIvar)

- (void)logWithIvar {
    
    unsigned int outCount = 0;
    
    Ivar *ivarList = class_copyIvarList([self class], &outCount);
    
    for (unsigned int i = 0; i < outCount; i ++) {
        Ivar ivar = ivarList[i];
        
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
//        id value = objc_getAssociatedObject(self, (__bridge const void *)(name));
        
        ZJLog(@"%@ = %@", [name substringFromIndex:1], [self valueForKeyPath:name]);
        
    }
    
}

@end
