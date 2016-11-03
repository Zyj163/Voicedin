//
//  TestingView.h
//  Voicedin
//
//  Created by zhangyj on 15-9-29.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestingView : UIView
/**
 *  文字图片名称
 */
@property (nonatomic, copy) NSString *imageName;
/**
 *  文字图片对应的示例声音文件
 */
@property (nonatomic, copy) NSString *voiceName;

- (void)stopVoice;

@end
