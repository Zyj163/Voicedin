//
//  ExampleCollectionViewCell.m
//  Voicedin
//
//  Created by zhangyj on 15-10-28.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "ExampleCollectionViewCell.h"
#import "ExampleView.h"

@implementation ExampleCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createExampleView];
    }
    return self;
}

//示例视图
- (void)createExampleView {
    [self setBottomBtnWithText:@"下一步" image:nil];
    ExampleView *exampleView = [[ExampleView alloc] init];
    self.mainview = exampleView;
    [self addSubview:self.mainview];
    
    [super layoutMainView];
}

- (void)setBottomBtnWithText:(NSString *)text image:(UIImage *)image {
    [super setBottomBtnWithText:text image:image];
}

/**
 *  底部按钮点击
 */
- (void)clickOn:(UIButton *)btn {
    ExampleView *exampleView = (ExampleView *)self.mainview;
    [exampleView stopVoice];
    [super clickOn:btn];
}

- (void)setDetailCellType:(DetailCellType)detailCellType {
    [super setDetailCellType:detailCellType];
    //设置是哪一部分的示例视图
    ExampleView *exampleView = (ExampleView *)self.mainview;
    exampleView.part = self.detailCellType.examplePart;
}

@end












