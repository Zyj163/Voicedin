//
//  ExampleView.h
//  Voicedin
//
//  Created by zhangyj on 15-9-24.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  ExampleViewPart枚举，表示是哪部分示例视图
 */
typedef NS_ENUM(NSInteger, ExampleViewPart){
    /**
     *  声母示例视图
     */
    ExampleViewPartShengmu = 0,
    /**
     *  韵母示例视图
     */
    ExampleViewPartYunmu = 1,
    /**
     *  词组示例视图
     */
    ExampleViewPartCizu = 2,
    /**
     *  短句示例视图
     */
    ExampleViewPartDuanyu = 3,
    /**
     *  无
     */
    ExampleViewPartNone
};

@interface ExampleView : UIView

@property (nonatomic, assign) ExampleViewPart part;
- (void)stopVoice;

@end
