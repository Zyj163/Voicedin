//
//  TestCenterCollectionViewCell.m
//  Voicedin
//
//  Created by zhangyj on 15-9-23.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "TestCenterCollectionViewCell.h"

@interface TestCenterCollectionViewCell () <NSURLSessionDelegate>

/**
 * 存放所有图片文件的数组
 */
@property (nonatomic, strong) NSArray *testingPngArr;

@end

@implementation TestCenterCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [ColorFromRGB(0xececec) CGColor];
        self.layer.borderWidth = 1.5;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

/**
 *  底部button
 *
 *  @param text  文字
 *  @param image 图片
 */
- (void)setBottomBtnWithText:(NSString *)text image:(UIImage *)image {
    UIButton *button = [[UIButton alloc]init];
    _bottomBtn = button;
    _bottomBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_bottomBtn];
    
    [_bottomBtn setBackgroundImage:[UIImage imageNamed:@"disable"] forState:UIControlStateDisabled];
    [_bottomBtn setBackgroundImage:[UIImage imageNamed:@"green-normal"] forState:UIControlStateNormal];
    [_bottomBtn setBackgroundImage:[UIImage imageNamed:@"green-highlight"] forState:UIControlStateHighlighted];
    
    if (text != nil) {
        [self setBottomBtnText:text];
    }
    if (image != nil) {
        [self setBottomBtnImage:image];
    }
}

/**
 *  设置底部按钮文字
 *
 *  @param text 按钮文字
 */
- (void)setBottomBtnText:(NSString *)text {
    CGFloat Font = h * 24 / 768;
    _bottomBtn.titleLabel.font = [UIFont systemFontOfSize:Font];
    [_bottomBtn setTitle:text forState:UIControlStateNormal];
    [_bottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    
    [_bottomBtn addTarget:self
                       action:@selector(clickOn:)
             forControlEvents:UIControlEventTouchUpInside];
    
    [_bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.equalTo(@(kBottomBtnH * h));
        }];
}

/**
 *  设置底部按钮图片
 *
 *  @param image 按钮图片
 */
- (void)setBottomBtnImage:(UIImage *)image {
    [_bottomBtn setImage:image forState:UIControlStateNormal];
    [_bottomBtn setImage:image forState:UIControlStateHighlighted];
    
    [_bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.equalTo(@(kBottomImageBtnH * h));
        }];
}

/**
 *  点击纯图片按钮，转变为声波视图
 *
 *  @param btn 图片按钮
 */
- (void)clickOnImageBtn:(UIButton *)btn {
    
    self.bottomBtn.hidden = YES;
    
    //取消播放示例功能
    self.mainview.userInteractionEnabled = NO;
    
    [PlayerTool playMusic:@"ButtonClick"];
}


- (void)layoutMainView {
    _mainview.backgroundColor = [UIColor whiteColor];
    [_mainview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(_bottomBtn.mas_top);
    }];
}

/**
 *  底部按钮点击
 */
- (void)clickOn:(UIButton *)btn {
    [PlayerTool playMusic:@"ButtonClick"];
    btn.exclusiveTouch = YES;
    if ([self.delegate respondsToSelector:@selector(centerView:clickOnBottomBtn:)]) {
        //通知代理切换视图
        [self.delegate centerView:self clickOnBottomBtn:btn];
    }
}

- (void)setDetailCellType:(DetailCellType)detailCellType {
    _detailCellType = detailCellType;
}

@end
