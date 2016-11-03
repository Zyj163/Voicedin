//
//  DoneCollectionViewCell.m
//  Voicedin
//
//  Created by zhangyj on 15-10-28.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "DoneCollectionViewCell.h"

@implementation DoneCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createDoneView];
    }
    return self;
}

/**
 *  完成测试视图
 */
- (void)createDoneView {
    CGFloat kimageTop = 0.128;
    CGFloat labelFont = 24  * kScreenHeight / 768;
    CGFloat ktopLabelTop = 0.37;
    CGFloat kdownLabelTop = 0.42;
    
    [self setBottomBtnWithText:@"结束" image:nil];
    
    UIView *view = [[UIView alloc]init];
    self.mainview = view;
    [self addSubview:self.mainview];
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, -kimageTop * kScreenHeight, self.width, self.height);
    imageLayer.contents = (id)[[UIImage imageNamed:@"finish"]CGImage];
    imageLayer.contentsScale = 1;
    [self.layer addSublayer:imageLayer];
    imageLayer.contentsGravity = @"center";
    
    NSDictionary *attrs = @{@"fontSize" : @(labelFont),
                            @"color" : ColorFromRGB(0x3f3f3f),
                            @"mode" : @"center"};
    
    UIFont *font = [UIFont systemFontOfSize:labelFont];
    
    CATextLayer *upTextLayer = [CATextLayer textLayerWithStr:@"恭喜！完成了所有检测环节！" attrs:attrs];
    [self.layer addSublayer:upTextLayer];
    upTextLayer.frame = CGRectMake(0, ktopLabelTop * kScreenHeight, self.width, font.lineHeight);
    
    CATextLayer *downTextLayer = [CATextLayer textLayerWithStr:@"请稍做休息，检测报告马上就能出来！" attrs:attrs];
    [self.layer addSublayer:downTextLayer];
    
    downTextLayer.frame = CGRectMake(0, kdownLabelTop * kScreenHeight, self.width, font.lineHeight);
    
    [super layoutMainView];
}

- (void)setBottomBtnWithText:(NSString *)text image:(UIImage *)image {
    [super setBottomBtnWithText:text image:image];
}

- (void)clickOn:(UIButton *)btn {
    [super clickOn:btn];
}

@end
