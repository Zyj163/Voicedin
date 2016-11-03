//
//  NSString+Extension.m
//  瀑布流
//
//  Created by zhangyongjun on 15/8/8.
//  Copyright (c) 2015年 张永俊. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (NSInteger)getCachesSize:(void(^)())completion {
    return [self getCachesSize:completion forFileType:nil];
}

- (void)clearCaches:(void(^)())completion {
    [self clearCaches:completion forFileType:nil];
}

- (void)clearCaches {
    [self clearCaches:nil];
}

- (NSInteger)getCachesSize {
    return [self getCachesSize:nil];
}

- (NSArray *)findFile:(NSString *)path forFileType:(NSString *)fileType {
    NSMutableArray *removeArr = [NSMutableArray array];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSArray *subPaths = [fileMgr subpathsAtPath:path];//获取所有子路径内容
    for (NSString *subPath in subPaths) {
        NSString *fullPath = [self stringByAppendingPathComponent:subPath];
        BOOL directory = NO;
        if ([fileMgr fileExistsAtPath:fullPath isDirectory:&directory]) {
            if (directory == NO) {
                
                if (fileType.length > 0) {
                    if (![fullPath hasSuffix:fileType]) {
                        continue;
                    }
                }
                
                [removeArr addObject:fullPath];
            }
            else {
                NSArray *arr = [self findFile:fullPath forFileType:fileType];
                [removeArr addObjectsFromArray:arr];
            }
        }
    }
    return removeArr;
}

- (NSInteger)getCachesSize:(void(^)())completion forFileType:(NSString *)fileType {
    if (self.length == 0) {
        return 0;
    }
    __block NSInteger totalSize = 0;
    __block NSMutableArray *cachesArr = [NSMutableArray array];
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL isDirectory = NO;
        if ([fileMgr fileExistsAtPath:self isDirectory:&isDirectory]) {//判断路径是否存在
            if (isDirectory) {//判断是否是文件 no代表是文件
                //path下的直接内容
                //NSArray *contents = [fileMgr contentsOfDirectoryAtPath:path error:nil];
                NSArray *arr = [self findFile:self forFileType:fileType];
                [cachesArr addObjectsFromArray:arr];
                
                [cachesArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    totalSize += [[fileMgr attributesOfItemAtPath:obj error:nil][NSFileSize]integerValue];
                }];
                
            }else {
                
                if (fileType.length > 0) {
                    if (![self hasSuffix:fileType]) {
                        return;
                    }
                }
                
                totalSize += [[fileMgr attributesOfItemAtPath:self error:nil][NSFileSize]integerValue];
            }
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
    return totalSize;
}


- (void)clearCaches:(void (^)())completion forFileType:(NSString *)fileType {
    if (self.length == 0) {
        return;
    }
    __block NSMutableArray *removeArr = [NSMutableArray array];
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL isDirectory = NO;
        if ([fileMgr fileExistsAtPath:self isDirectory:&isDirectory]) {//判断路径是否存在
            if (isDirectory) {//判断是否是文件 no代表是文件
                //path下的直接内容
                NSArray *arr = nil;
                if (!fileType) {
                    NSArray *a = [fileMgr contentsOfDirectoryAtPath:self error:nil];
                    for (NSString *subPath in a) {
                        NSString *fullPath = [self stringByAppendingPathComponent:subPath];
                        [removeArr addObject:fullPath];
                    }
                    
                }else {
                    arr = [self findFile:self forFileType:fileType];
                    [removeArr addObjectsFromArray:arr];
                }
                
            }else {
                
                if (fileType.length > 0) {
                    if (![self hasSuffix:fileType]) {
                        return;
                    }
                }
                
                [removeArr addObject:self];
            }
        }
        __block NSError *removeError;
        [removeArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [fileMgr removeItemAtPath:obj error:&removeError];
            if (removeError) {
                ZJLog(@"移除失败：%@",removeError);
            }
        }];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
    
}


@end
