//
//  RecordTimeFlag.m
//  Voicedin
//
//  Created by zhangyj on 15-10-16.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "RecordTimeFlag.h"
#import "Person.h"
#import "PersonTool.h"
#import "Author.h"
#import "NSString+Extension.h"
#import <AVFoundation/AVFoundation.h>
#import "RecroderManager.h"
#import "TimeOpt.h"

@interface RecordTimeFlag ()

@property (nonatomic, copy) NSMutableDictionary *timeFlagDic;
@property (nonatomic, strong) Author *author;
@property (nonatomic, copy) NSMutableDictionary *tempDic;
@property (nonatomic, assign) NSTimeInterval preTime;

@property (nonatomic, strong) NSArray *pngNameArr;
@property (nonatomic, strong) NSArray *pngTextArr;

@end

@implementation RecordTimeFlag

- (NSArray *)pngNameArr {
    if (!_pngNameArr) {
        _pngNameArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testPngs" ofType:@"plist"]];
    }
    return _pngNameArr;
}

- (NSArray *)pngTextArr {
    if (!_pngTextArr) {
        _pngTextArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testText" ofType:@"plist"]];
    }
    return _pngTextArr;
}

- (NSString *)replaceNameToText:(NSString *)name {
    NSInteger part = 0;
    if ([self.part isEqualToString:shengmuPart]) {
        part = 0;
    }else if ([self.part isEqualToString:yunmuPart]) {
        part = 1;
    }else if ([self.part isEqualToString:cizuPart]) {
        part = 2;
    }else if ([self.part isEqualToString:duanjuPart]) {
        part = 3;
    }
    NSInteger idx = [self.pngNameArr[part] indexOfObject:name];
    return [self.pngTextArr[part] objectAtIndex:idx];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _tempDic = [NSMutableDictionary dictionary];
        _author = [NSKeyedUnarchiver unarchiveObjectWithFile:authorFile];
        
    }
    return self;
}

- (NSMutableDictionary *)timeFlagDic {
    Person *person = [[PersonTool sharedPersonTool] getCurrentPerson];
    _timeFlagDic = [NSMutableDictionary dictionaryWithContentsOfFile:timeFlagFile(self.author.auth_id, person.uuid, person.part, [TimeOpt getGlobalTimeStr])];
    if (!_timeFlagDic) {
        _timeFlagDic = [NSMutableDictionary dictionary];
    }
    return _timeFlagDic;
}

- (void)setPersonID:(NSString *)personID {
    _personID = personID;
    
    Person *person = [[PersonTool sharedPersonTool] getCurrentPerson];
    
    self.timeFlagDic[@"uid"] = personID;
    _timeFlagDic[@"auth_id"] = _author.auth_id;
    _timeFlagDic[@"time"] = [TimeOpt getGlobalTimeStr];
    
    [_timeFlagDic writeToFile:timeFlagFile(self.author.auth_id, person.uuid, person.part, [TimeOpt getGlobalTimeStr]) atomically:YES];
}

- (void)setPart:(NSString *)part {
    _part = part;
    Person *person = [[PersonTool sharedPersonTool] getCurrentPerson];
    
    self.timeFlagDic[part] = [NSMutableArray array];
    
    [_timeFlagDic writeToFile:timeFlagFile(self.author.auth_id, person.uuid, person.part, [TimeOpt getGlobalTimeStr]) atomically:YES];
}

- (void)setName:(NSString *)name {
    if ([name isEqualToString:personInfoPart]) {
        _name = name;
    }else {
        _name = [self replaceNameToText:name];
    }
    _tempDic[@"name"] = _name;
}

- (void)setStart:(NSTimeInterval)start {
    _start = start;
    Person *person = [[PersonTool sharedPersonTool] getCurrentPerson];
    //判断文件个数
    
    if ([NSFM fileExistsAtPath:RecordFilePath(self.author.auth_id, person.uuid, nil, nil)]) {
        NSArray *paths = [NSFM subpathsAtPath:RecordFilePath(self.author.auth_id, person.uuid, nil, nil)];
        
        for (NSString *path in paths) {
            if ([path hasSuffix:[NSString stringWithFormat:@"%@.aac",person.part]]) {
                NSString *fileName = [path stringByDeletingPathExtension];
                NSURL *url = RecordFile(self.author.auth_id, person.uuid, fileName, @"aac");
                NSURL *recordUrl = [[RecroderManager getCourseRecorderWithName:person.part] url];
                if ([[url absoluteString] isEqualToString:[recordUrl absoluteString]]) {
                    continue;
                }
                AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
                _preTime += player.duration;
                player = nil;
            }
        }
    }
    
    _tempDic[@"start"] = [NSString stringWithFormat:@"%02d:%02d",
                          (int)(start + _preTime)/60,
                          (int)(start + _preTime)%60];
}

- (void)setEnd:(NSTimeInterval)end {
    _end = end;
    Person *person = [[PersonTool sharedPersonTool] getCurrentPerson];
    _tempDic[@"end"] = [NSString stringWithFormat:@"%02d:%02d",
                        (int)(end + _preTime)/60,
                        (int)(end + _preTime)%60];
    
    [self.timeFlagDic[_part] addObject:[_tempDic copy]];
    
    [_timeFlagDic writeToFile:timeFlagFile(self.author.auth_id, person.uuid, person.part, [TimeOpt getGlobalTimeStr]) atomically:YES];
    
    [_tempDic removeAllObjects];
    _preTime = 0;
}

- (void)deleteFileWithPerson:(Person *)person {
    [_timeFlagDic removeAllObjects];
    [_tempDic removeAllObjects];
    
    NSString *path = [timeFlagFile(self.author.auth_id, person.uuid, nil, nil) stringByDeletingLastPathComponent];
    [path clearCaches:nil forFileType:@".plist"];
}

- (void)deleteFileWithName:(NSString *)name {
    
    Person *person = [[PersonTool sharedPersonTool] getCurrentPerson];
    NSString *path = timeFlagFile(self.author.auth_id, person.uuid, name, [TimeOpt getGlobalTimeStr]);
    if (![NSFM fileExistsAtPath:path]) return;
    
    [_timeFlagDic removeAllObjects];
    [_tempDic removeAllObjects];
    
    NSError *error;
    [NSFM removeItemAtPath:path error:&error];
    if (error) {
        ZJLog(@"删除时间戳文件失败：%@",error);
    }
}

- (void)deleteOneFlag:(NSString *)flagName {
    NSArray *arr = self.timeFlagDic[self.part];
    NSString *name = flagName;
    if (![flagName isEqualToString:personInfoPart]) {
        name = [self replaceNameToText:flagName];
    }
    [arr enumerateObjectsUsingBlock:^(NSMutableDictionary *dic, NSUInteger idx, BOOL *stop) {
        NSArray *arr = [dic allKeys];
        [arr enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL *stop) {
            if ([str isEqualToString:name]) {
                [_timeFlagDic[self.part] removeObject:dic];
                Person *person = [[PersonTool sharedPersonTool] getCurrentPerson];
                [_timeFlagDic writeToFile:timeFlagFile(self.author.auth_id, person.uuid, person.part, [TimeOpt getGlobalTimeStr]) atomically:YES];
                return ;
            }
        }];
    }];
}


@end
