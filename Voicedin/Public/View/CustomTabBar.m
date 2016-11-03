//
//  TabBar.m
//  CustomTabBar
//
//  Created by zhangyongjun on 15/9/19.
//  Copyright (c) 2015年 张永俊. All rights reserved.
//

/**
 *  自定义TabBar
 */

#import "CustomTabBar.h"

//通过button类自定义tabBarItem
@interface BottomTextButton :UIButton

@property (nonatomic, weak) UIImageView *redCircle;

+ (BottomTextButton *)buttonWithText:(NSString *)text image:(UIImage *)image selectedImage:(UIImage *)selectedImage;

@end

@interface CustomTabBar ()

@property (weak, nonatomic) UIButton *preBtn;
@property (weak, nonatomic) UIImageView *backImageView;
@property (weak, nonatomic) UIImageView *lineView;

@end

@implementation CustomTabBar

- (UIImageView *)backImageView {
    if (!_backImageView) {
        UIImageView *imageView = [[UIImageView alloc]init];
        _backImageView = imageView;
        [self insertSubview:imageView atIndex:0];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _backImageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _items = [NSMutableArray array];
        
        //tabBar顶部虚影
        UIImageView *lineView = [[UIImageView alloc]init];
        lineView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        [self addSubview:lineView];
        self.lineView = lineView;
        
    }
    return self;
}

#pragma mark - private method

/**
 *  切换按钮被选中状态，自己内部的事情不要交给其他类来实现
 */
- (void)clickOnBtn:(UIButton *)btn {
    if (self.preBtn == btn) return;
    if (self.preBtn) {
        self.preBtn.selected = NO;
        [self.preBtn.layer removeAnimationForKey:@"rotation"];
    }
    if ([btn.titleLabel.text isEqualToString:@"设置"]) {
        self.preBtn.selected = YES;
    }else {
        btn.selected = YES;
    }
    
    //控制器的切换交给TabBarController处理，通过代理
    if ([self.delegate respondsToSelector:@selector(tabBar:clickOnItemAtIdx:preIdx:)]) {
        if (self.preBtn) {
            [self.delegate tabBar:self
                 clickOnItemAtIdx:btn.tag
                           preIdx:self.preBtn.tag];
        }else {
            [self.delegate tabBar:self
                 clickOnItemAtIdx:btn.tag
                           preIdx:-1];
        }
    }
    if ([btn.titleLabel.text isEqualToString:@"设置"]) {
        
    }else {
        self.preBtn = btn;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat scale = 1.575;//(189 - 120) / 120
    for (NSInteger i = 0; i < self.items.count; i ++) {
        CGFloat width, height, x, y;
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            width = self.width;
            height = self.width * scale;
            CGFloat inset = (self.height - height * self.items.count) * 0.5;
            x = 0;
            y = i * height + inset;
        }else {
            width = self.height * scale;
            height = self.height;
            CGFloat inset = (self.width - width * self.items.count) * 0.5;
            x = inset + i * width;
            y = 0;
        }
        UIView *view = self.items[i];
        view.frame = CGRectMake(x, y, width, height);
    }
    
    CGFloat lineH = 0.5;
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        self.lineView.frame = CGRectMake(self.width - lineH, 0, lineH, self.height);
    }else {
        self.lineView.frame = CGRectMake(0, 0, self.width, lineH);
    }
}

#pragma mark - public method
/**
 *  添加Item
 */
- (void)addTabBarItemWithText:(NSString *)text image:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    BottomTextButton *btn = [BottomTextButton buttonWithText:text
                                                       image:image
                                               selectedImage:selectedImage];
    
    [btn addTarget:self action:@selector(clickOnBtn:) forControlEvents:UIControlEventTouchDown];
    [self.items addObject:btn];
    [self addSubview:btn];
    btn.tag = self.items.count - 1;
    if (btn.tag == 0) {
        [self clickOnBtn:btn];
    }
}

/**
 *  设置导航栏背景图片，默认为空
 */
- (void)setBackGroundImage:(UIImage *)image {
    if (image) {
        self.backImageView.image = image;
    }
}

- (void)setBadgeOnIdx:(NSInteger)idx value:(BOOL)showOrNot {
    BottomTextButton *btn = self.items[idx];
    btn.redCircle.hidden = !showOrNot;
}

@end


/**
 *  自定义Item类实现
 */
@interface BottomTextButton ()
@property (assign, nonatomic) CGFloat currentImageHeight;
//@property (assign, nonatomic) CGFloat currentFontSize;
@end

@implementation BottomTextButton

#define Font 13

+ (BottomTextButton *)buttonWithText:(NSString *)text image:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    BottomTextButton *btn = [[self alloc]init];
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:selectedImage forState:UIControlStateSelected];
    btn.currentImageHeight = btn.currentImage.size.height;
    btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    btn.currentFontSize = btn.currentImageHeight * 0.5;
//    btn.titleLabel.font = [UIFont systemFontOfSize:btn.currentFontSize];
    btn.titleLabel.font = [UIFont systemFontOfSize:Font];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setTitleColor:Color(83, 83, 83) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    UIImageView *redCircle = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ellipse"]];
    redCircle.contentMode = UIViewContentModeScaleAspectFit;
    [btn addSubview:redCircle];
    btn.redCircle = redCircle;
    redCircle.hidden = YES;
    return btn;
}

- (void)setHighlighted:(BOOL)highlighted {}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGFloat totalH = (self.currentImageHeight + Font);
    CGFloat space = totalH * 0.15;
    CGFloat y = (self.height - totalH - space) * 0.5;
    return CGRectMake(0, y, self.width, self.currentImageHeight);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGFloat totalH = (self.currentImageHeight + Font);
    CGFloat space = totalH * 0.15;
    CGFloat y = (self.height - totalH - space) * 0.5 + space + self.currentImageHeight;
    return CGRectMake(0, y, self.width, Font);
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self sizeToFit];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    [super setImage:image forState:state];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.imageView sizeToFit];
    [self sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.redCircle) {
        CGFloat x = self.imageView.centerX + self.currentImage.size.width * 0.5;
        CGFloat y = self.imageView.centerY - self.currentImage.size.height * 0.5;
        CGFloat w = 8;
        CGFloat h = 8;
        self.redCircle.frame = CGRectMake(x, y, w, h);
    }
}

@end








