//
//  RecordTimeFlag.h
//  Voicedin
//
//  Created by zhangyj on 15-10-16.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Person;

@interface RecordTimeFlag : NSObject

@property (nonatomic, copy) NSString *personID;
@property (nonatomic, copy) NSString *part;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSTimeInterval start;
@property (nonatomic, assign) NSTimeInterval end;

@property (nonatomic, copy, readonly) NSMutableDictionary *timeFlagDic;

- (void)deleteFileWithName:(NSString *)name;
- (void)deleteOneFlag:(NSString *)flagName;
- (void)deleteFileWithPerson:(Person *)person;

@end
