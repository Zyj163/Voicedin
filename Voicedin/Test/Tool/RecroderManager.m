//
//  RecroderManager.m
//  Voicedin
//
//  Created by zhangyongjun on 15/9/27.
//  Copyright © 2015年 xitong. All rights reserved.
//

#import "RecroderManager.h"
#import "NetworkingManager.h"
#import "PersonTool.h"
#import "Person.h"
#import "NSDate+FormatterDate.h"
#import "RecordTimeFlag.h"
#import "NSString+Extension.h"
#import "Author.h"
#import "JSONKit.h"
#import "TimeOpt.h"

/**
 *  录音设置字典
 */
static NSDictionary *_settings;
/**
 *  阶段录音字典
 */
static NSMutableDictionary *_courseRecorders;
/**
 *  录音时间戳
 */
static RecordTimeFlag *_recordTimeFlag;
/**
 *  扫描失败文件定时器
 */
static NSTimer *_timer;

/**
 *  扫描频率
 */
#define frequency 60.0

/**
 *  失败标示
 */
static NSString * const failure = @"failure";

@implementation RecroderManager
//录音上传地址
#define recordUploadUrlStr @"http://api.fluvoice.com/uploads/upFile"

////录音时间戳上传地址
//#define recordTimeFlagUploadUrlStr @"http://api.fluvoice.com/index/up"

//初始化录音设置
+ (void)initialize {
    _settings = @{AVSampleRateKey:          @16000.0,
                  AVFormatIDKey:            @(kAudioFormatMPEG4AAC),
                  AVNumberOfChannelsKey:    @1,
                  AVEncoderAudioQualityKey: @(AVAudioQualityHigh),
                  AVLinearPCMBitDepthKey:   @8,
                  AVLinearPCMIsFloatKey:    @(YES)};
    
    _courseRecorders = [NSMutableDictionary dictionary];
    _recordTimeFlag = [RecordTimeFlag new];
}

//按照名称创建录音
+ (AVAudioRecorder *)recorderWithName:(NSString *)name {
    NSError *error;
    
    Person *person = [[PersonTool sharedPersonTool] getCurrentPerson];
    
    if (![name isEqualToString:personInfoPart]) {
        person = [NSKeyedUnarchiver unarchiveObjectWithFile:personFile];
    }
    
    Author *author = [NSKeyedUnarchiver unarchiveObjectWithFile:authorFile];
    
    NSURL *url = RecordFile(author.auth_id, person.uuid, name, @"aac");
    
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc]initWithURL:url settings:_settings error:&error];
    ZJLog(@"录音地址：%@",recorder.url);
    
    if(error) {
        ZJLog(@"could not create recorder %@", error);
        return nil;
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    
    if (error) {
        ZJLog(@"Error setting category: %@", [error description]);
        return nil;
    }
    
    [recorder prepareToRecord];
    
    return recorder;
}

+ (void)stopRecord {
    [_courseRecorders enumerateKeysAndObjectsUsingBlock:^(id key, AVAudioRecorder *obj, BOOL *stop) {
        if (obj.isRecording) {
            [obj stop];
        }
    }];
}

//按照录音名称获取录音，没有则创建一个
+ (AVAudioRecorder *)getCourseRecorderWithName:(NSString *)name {
    
    AVAudioRecorder *courseRecorder = _courseRecorders[name];
    if (courseRecorder == nil) {
        
        NSInteger terminate = [[NSUD objectForKey:terminatePosition] integerValue];
        if (terminate > 1) {
            NSString *newName = [NSString stringWithFormat:@"%zd_%@",terminate,name];
            courseRecorder = [self recorderWithName:newName];
            
        }else {
            courseRecorder = [self recorderWithName:name];
        }
        _courseRecorders[name] = courseRecorder;
    }
    [NSUD removeObjectForKey:terminatePosition];
    return courseRecorder;
}

//按照录音名称上传录音
+ (void)uploadRecorderWithName:(NSString *)name success:(void(^)(id responseObj))successBlock failure:(void(^)())failureBlock {
    
    AVAudioRecorder *recorder = _courseRecorders[name];
    
    if (recorder == nil) {
        
        ZJLog(@"没有这个录音");
    }
    
    if (recorder.isRecording) {
        [recorder stop];
    }
    
    [_courseRecorders removeObjectForKey:name];
    
    Person *person = [[PersonTool sharedPersonTool] getCurrentPerson];
    
    Author *author = [NSKeyedUnarchiver unarchiveObjectWithFile:authorFile];
    
    //后台上传，延时2秒，防止有缓存未写入文件
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //判断文件个数
        
        NSMutableArray *recordFiles = [NSMutableArray array];
        if ([NSFM fileExistsAtPath:RecordFilePath(author.auth_id, person.uuid, nil, nil)]) {
            NSArray *paths = [NSFM subpathsAtPath:RecordFilePath(author.auth_id, person.uuid, nil, nil)];
            
            for (NSString *path in paths) {
                if ([path hasSuffix:[NSString stringWithFormat:@"%@.aac",name]]) {
                    NSString *fileName = [path stringByDeletingPathExtension];
                    NSURL *url = RecordFile(author.auth_id, person.uuid, fileName, @"aac");
                    [recordFiles addObject:url];
                }
            }
        }
        
        //使用新名字
        NSString *newName = [NSString stringWithFormat:@"%@_%@",[TimeOpt getGlobalTimeStr], name];
        ZJLog(@"oldName:%@,newName:%@",name,newName);
        
        //合并录音文件
        if (recordFiles.count > 1) {
            //数组排序
            NSArray *sortedArr = [recordFiles sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id obj1, id obj2) {
                return NSOrderedDescending;
            }];
            
            [self mergeAudiosWithUrls:sortedArr toNameFile:newName completion:^(BOOL flag) {
                if (flag == NO) {
                    return ;
                }
                [self uploadWithAuthorID:author.auth_id uuid:person.uuid name:newName time:[TimeOpt getGlobalTimeStr] type:@"m4a" success:^(id responseObj) {
                    successBlock(responseObj);
                } failure:^{
                    failureBlock();
                }];
            }];
        }else {
            
            //修改录音名称
            [NSFM moveItemAtPath:RecordFilePath(author.auth_id, person.uuid, name, @"aac") toPath:RecordFilePath(author.auth_id, person.uuid, newName, @"aac") error:nil];
            
            [self uploadWithAuthorID:author.auth_id uuid:person.uuid name:newName time:[TimeOpt getGlobalTimeStr] type:@"aac" success:^(id responseObj) {
                
                successBlock(responseObj);
            } failure:^{
                failureBlock();
            }];
        }
    });
}

+ (void)uploadWithAuthorID:(NSString *)auth_id uuid:(NSString *)uuid name:(NSString *)name time:(NSString *)time type:(NSString *)type success:(void(^)(id responseObj))successBlock failure:(void(^)())failureBlock {
    
    NSDictionary *timeFlag = [NSDictionary dictionaryWithContentsOfFile:timeFlagFile(auth_id, uuid, [name substringFromIndex:time.length+1], time)];
    ZJLog(@"%@",[timeFlag JSONString]);
    
    //上传录音
    
    NetworkingManager *mgr = [NetworkingManager sharedNetworkingManager];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [mgr POST:recordUploadUrlStr parameters:@{@"json" : timeFlag.JSONString} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            NSData *data = [NSData dataWithContentsOfURL:RecordFile(auth_id, uuid, name, type)];
            
            ZJLog(@"%zd",data.length);
            
            [formData appendPartWithFileData:data name:@"file" fileName:[NSString stringWithFormat:@"%@.%@",name,type] mimeType:@"audio/aac"];
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([responseObject[@"message"] isEqualToString:@"successful"]) {
                
                //成功后删除该录音文件
                NSString *recordPath = RecordFilePath(auth_id, uuid, name, type);
                
                if ([NSFM fileExistsAtPath:recordPath]) {
                    [NSFM removeItemAtPath:recordPath error:nil];
                }
                
                //删除时间戳本地文件
                NSString *timeFlagPath = timeFlagFile(auth_id, uuid, [name substringFromIndex:time.length+1], time);
                
                if ([NSFM fileExistsAtPath:timeFlagPath]) {
                    [timeFlagPath clearCaches:^{
                        //移除失败记录
                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:failureFile(auth_id, uuid)];
                        [dic removeObjectForKey:name];
                        [dic writeToFile:failureFile(auth_id, uuid) atomically:YES];
                        
                    } forFileType:[NSString stringWithFormat:@"%@.plist",name]];
                }
            
                successBlock(responseObject);

            }else {
                [self failureNetworkWithAuthorID:auth_id uuid:uuid name:name time:time type:type];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            ZJLog(@"%@",error);
            
            [self failureNetworkWithAuthorID:auth_id uuid:uuid name:name time:time type:type];
            
            failureBlock();
            
        }];
    });
}

+ (void)failureNetworkWithAuthorID:(NSString *)auth_id uuid:(NSString *)uuid name:(NSString *)name time:(NSString *)time type:(NSString *)type {
    //记录失败项到对应病人文件夹中
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:failureFile(auth_id, uuid)];
    
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    
    if (![[dic allKeys] containsObject:name]) {
        dic[name] = failure;
        dic[@"auth_id"] = auth_id;
        if (uuid) {
            dic[@"uuid"] = uuid;
        }
        dic[@"type"] = type;
        dic[@"time"] = time;
        [dic writeToFile:failureFile(auth_id, uuid) atomically:YES];
    }
    
    //激活全局扫描失败文件
    NetworkingManager *netMgr = [NetworkingManager sharedNetworkingManager];
    
    if (_timer == nil) {
        if (netMgr.reachabilityMgr.reachable) {
            //启动扫描
            _timer = [NSTimer timerWithTimeInterval:frequency target:self selector:@selector(uploadFailureFile) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
        }else {
            [netMgr.reachabilityMgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
                    if (_timer == nil) {
                        //启动扫描
                        _timer = [NSTimer timerWithTimeInterval:frequency target:self selector:@selector(uploadFailureFile) userInfo:nil repeats:YES];
                        [[NSRunLoop mainRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
                    }
                }else {
                    //关闭扫描
                    [_timer invalidate];
                    _timer = nil;
                }
            }];
            [netMgr.reachabilityMgr startMonitoring];
        }
        
    }
}

//扫描有无失败文件
+ (NSArray *)hasFailureFile {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [path findFile:path forFileType:@"failure.plist"];
}

//上传失败文件
+ (void)uploadFailureFile {
    NSArray *failureArr = [self hasFailureFile];
    
    ZJLog(@"失败记录：%@",failureArr);
    
    if (failureArr && failureArr.count > 0) {
        for (NSString *path in failureArr) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
            if (![[dic allValues] containsObject:failure]) {
                //删除无效文件
                if ([NSFM fileExistsAtPath:path]) {
                    NSError *error;
                    [NSFM removeItemAtPath:path error:&error];
                    if (error) {
                        ZJLog(@"移除失败记录失败：%@",error);
                    }
                }
            }else {
                //上传
                [dic enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
                    if ([obj isEqualToString:failure]) {
                        NSString *auth_id = dic[@"auth_id"];
                        NSString *uuid = dic[@"uuid"];
                        NSString *type = dic[@"type"];
                        NSString *time = dic[@"time"];
                        [self uploadWithAuthorID:auth_id uuid:uuid name:key time:time type:type success:^(id responseObj) {
                            ZJLog(@"重新上传成功：%@",responseObj);
                        } failure:^{
                            ZJLog(@"重新上传失败");
                        }];
                    }
                }];
            }
        }
    }else {
        //关闭扫描
        [_timer invalidate];
        _timer = nil;
        NetworkingManager *netMgr = [NetworkingManager sharedNetworkingManager];
        [netMgr.reachabilityMgr stopMonitoring];
    }
}

//按照录音名称删除录音
+ (void)deleteRecordWithName:(NSString *)name {
    
    AVAudioRecorder *record = _courseRecorders[name];
    if (record == nil) {
        ZJLog(@"没有这个录音");
    }
    else if (record.isRecording) {
        [record stop];
    }
    
    Author *author = [NSKeyedUnarchiver unarchiveObjectWithFile:authorFile];
    
    if ([name isEqualToString:personInfoPart]) {
        [NSFM removeItemAtPath:RecordFilePath(author.auth_id, nil, personInfoPart, @"aac") error:nil];
        [_courseRecorders removeObjectForKey:name];
        return;
    }
    
    Person *person = [[PersonTool sharedPersonTool] getCurrentPerson];
    [RecordFilePath(author.auth_id, person.uuid, nil, nil) clearCaches:nil forFileType:[NSString stringWithFormat:@"%@.aac",name] ? : [NSString stringWithFormat:@"%@.m4a",name]];
    [_courseRecorders removeObjectForKey:name];
    
    //删除对应时间戳，如果有时间戳
    NSString *timeFlagPath = timeFlagFile(author.auth_id, person.uuid, name, [TimeOpt getGlobalTimeStr]);
    if ([NSFM fileExistsAtPath:timeFlagPath]) {
        NSError *error;
        [NSFM removeItemAtPath:timeFlagPath error:&error];
        if (error) {
            ZJLog(@"删除录音后，删除时间戳失败：%@",error);
        }
    }
}

//按照病人删除录音
+ (void)deleteRecordsOfPerson:(Person *)person {
    [_courseRecorders removeAllObjects];
    [self deleteRecordTimeFlagsOfPerson:person];
    
    Author *author = [NSKeyedUnarchiver unarchiveObjectWithFile:authorFile];
    
    if ([NSFM fileExistsAtPath:RecordFilePath(author.auth_id, person.uuid, nil, nil)]) {
        NSError *error;
        [NSFM removeItemAtPath:RecordFilePath(author.auth_id, person.uuid, nil, nil) error:&error];
        if (error) {
            ZJLog(@"移除病人文件夹错误：%@",error);
        }
    }
    
    [[PersonTool sharedPersonTool] setCurrentPerson:nil];
    
}

//录音开始时间
+ (void)setRecordWithName:(NSString *)name startTime:(NSTimeInterval)time {
    if (!name) return;
    
    _recordTimeFlag.name = name;
    
    _recordTimeFlag.start = time;
    
}

//录音结束时间
+ (void)setRecordWithName:(NSString *)name endTime:(NSTimeInterval)time  {
    if (!name || !time) return;
    
    _recordTimeFlag.end = time;
    
}

+ (void)setRecordTimeFlagPart:(NSString *)part {
    if (!part) return;
    _recordTimeFlag.part = part;
}

+ (void)setRecordTimeFlagPerson:(Person *)person {
    
    if (!_recordTimeFlag) {
        _recordTimeFlag = [RecordTimeFlag new];
    }
    
    _recordTimeFlag.personID = person.uuid;
}

//按照名字删除时间戳
+ (void)deleteRecordTimeFlagWithName:(NSString *)name {
    [_recordTimeFlag deleteOneFlag:name];
}

//按照病人删除时间戳
+ (void)deleteRecordTimeFlagsOfPerson:(Person *)person {
    [_recordTimeFlag deleteFileWithPerson:person];
    _recordTimeFlag = nil;
}

//合并录音文件
+ (void)mergeAudiosWithUrls:(NSArray *)urls toNameFile:(NSString *)name completion:(void(^)(BOOL flag))completion {
    
    NSError * error;
    
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    CGFloat audioStartTime = 0;
    CGFloat audioEndTime = 0;
    
    for (NSURL *url in urls) {
        
        ZJLog(@"url--------------%@",url);
        
        AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:url options:nil];
        AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeAudio] lastObject];
        AVMutableCompositionTrack *comTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        CMTime time = mixComposition.duration;
        
        [comTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:track atTime:time error:&error];
        if (error) {
            ZJLog(@"合并录音文件错误：%@",error);
            return;
        }
        
        audioEndTime += CMTimeGetSeconds(asset.duration);
    }
    
    Person *person = [[PersonTool sharedPersonTool] getCurrentPerson];
    Author *author = [NSKeyedUnarchiver unarchiveObjectWithFile:authorFile];
    
    NSString *pathToSave = [NSString stringWithFormat:@"%@.m4a",name];
    
    NSURL *moveUrl = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@",author.auth_id, person.uuid,pathToSave]]];
    
    AVAssetExportSession *exporter =[[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetAppleM4A];
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.outputURL = moveUrl;
    
    exporter.outputFileType = AVFileTypeAppleM4A;
    
    CMTime startTime = CMTimeMake((NSInteger)(floor(audioStartTime * 100)), 100);
    
    CMTime stopTime = CMTimeMake((NSInteger)(ceil(audioEndTime * 100)), 100);
    
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    exporter.timeRange =exportTimeRange;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^(void) {
        NSString* message;
        switch (exporter.status) {
            case AVAssetExportSessionStatusFailed:
                message = [NSString stringWithFormat:@"Export failed. Error: %@", exporter.error.description];
                ZJLog(@"%@", message);
                completion(NO);
                break;
            case AVAssetExportSessionStatusCompleted:
            {
                message = [NSString stringWithFormat:@"Export completed"];
                ZJLog(@"%@", message);
                //删除原文件
                for (NSURL *url in urls) {
                    [NSFM removeItemAtURL:url error:nil];
                }
                [self deleteRecordWithName:[name substringFromIndex:[TimeOpt getGlobalTimeStr].length + 1]];
                break;
            }
            case AVAssetExportSessionStatusCancelled:
                message = [NSString stringWithFormat:@"Export cancelled!"];
                ZJLog(@"%@", message);
                completion(NO);
                break;
            default:
                ZJLog(@"Export unhandled status: %ld", (long)exporter.status);
                break;
        }
    }];
}
@end


