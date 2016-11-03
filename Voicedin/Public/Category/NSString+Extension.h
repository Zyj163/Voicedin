//
//  NSString+Extension.h
//  瀑布流
//
//  Created by zhangyongjun on 15/8/8.
//  Copyright (c) 2015年 张永俊. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSString (Extension)
/**
 *  获取一个路径下的所有文件大小
 *
 *  @param completion  完成后
 *  @return NSInteger 返回计算大小
 */
- (NSInteger)getCachesSize:(void(^)())completion;
/**
 *  清除一个路径下的所有文件
 *
 *  @param completion  完成后
 */
- (void)clearCaches:(void(^)())completion;
/**
 *  获取一个路径下的所有文件大小
 *
 *  @return NSInteger 返回计算大小
 */
- (NSInteger)getCachesSize;
/**
 *  清除一个路径下的所有文件
 *
 */
- (void)clearCaches;
/**
 *  按照文件类型获取一个路径下的所有文件大小
 *
 *  @param completion  计算完成后
 *  @param fileType    文件类型
 *  @return NSInteger 返回计算大小
 */
- (NSInteger)getCachesSize:(void(^)())completion forFileType:(NSString *)fileType;
/**
 *  按照文件类型清除一个路径下的所有文件
 *
 *  @param completion  计算完成后
 *  @param fileType    文件类型
 */
- (void)clearCaches:(void (^)())completion forFileType:(NSString *)fileType;
/**
 *  按照文件类型找到一个路径下的所有文件的路径
 *
 *  @param path  给定路径
 *  @param fileType  文件类型
 *  @return NSArray 返回数组
 */
- (NSArray *)findFile:(NSString *)path forFileType:(NSString *)fileType;
@end
