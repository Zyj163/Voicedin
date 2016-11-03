//
//  TestingBottomView.h
//  Voicedin
//
//  Created by zhangyj on 15-9-25.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TestingBottomView;

@protocol TestingBottomViewDelegate <NSObject>
/**
 *  重新开始
 *
 *  @param view       声波视图
 *  @param restartBtn 重新开始按钮
 */
- (void)TestingBottomView:(TestingBottomView *)view clickOnRestartBtn:(UIButton *)restartBtn;
/**
 *  录音完成
 *
 *  @param view      声波视图
 *  @param finishBtn 完成按钮
 */
- (void)TestingBottomView:(TestingBottomView *)view clickOnFinishBtn:(UIButton *)finishBtn;

@end

@interface TestingBottomView : UIView

@property (nonatomic, weak) id<TestingBottomViewDelegate> delegate;
/**
 *  启动录音
 *
 *  @param recordName 录音名
 */
- (void)startRecordWave:(NSString *)recordName waveName:(NSString *)waveName;

@end
