//
//  PersonInfoPickerView.m
//  Voicedin
//
//  Created by zhangyj on 15-10-27.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "PersonInfoPickerView.h"

@interface PersonInfoPickerView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, copy) NSArray *datas;
@property (nonatomic, weak) UIPickerView *pickerView;
@property (nonatomic, strong) UIView *coverView;

@end

@implementation PersonInfoPickerView

- (UIView *)coverView {
    if (!_coverView) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        _coverView  = [[UIView alloc]initWithFrame:window.bounds];
        [window addSubview:_coverView];
        _coverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [_coverView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickOn:)]];
    }
    return _coverView;
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        UIPickerView *pickerView = [[UIPickerView alloc]init];
        pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView = pickerView;
        [self addSubview:pickerView];
        pickerView.delegate = self;
        pickerView.dataSource = self;
        WS(ws);
        [pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(ws);
        }];
        UIView *topView = [[UIView alloc]init];
        topView.backgroundColor = ColorFromRGB(0xf9f9f9);
        [self addSubview:topView];
        [topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(pickerView.mas_top);
            make.left.right.equalTo(ws);
            make.height.equalTo(@44);
        }];
        UIButton *ackBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        ackBtn.backgroundColor = ColorFromRGB(0xf9f9f9);
        [topView addSubview:ackBtn];
        [ackBtn setTitle:@"确认" forState:UIControlStateNormal];
        ackBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        ackBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20 * kScreenHeight / 768];
        [ackBtn addTarget:self action:@selector(ack:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        cancelBtn.backgroundColor = ColorFromRGB(0xf9f9f9);
        [topView addSubview:cancelBtn];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        cancelBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20 * kScreenHeight / 768];
        [cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.top.left.equalTo(topView);
            make.width.equalTo(@(kScreenWidth * 0.15));
        }];
        
        [ackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.top.right.equalTo(topView);
            make.width.equalTo(cancelBtn.mas_width);
        }];
    }
    return _pickerView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)ack:(UIButton *)btn {
    NSInteger row = [self.pickerView selectedRowInComponent:0];
    if ([[self.datas lastObject] isEqualToString:@"年龄"]) {
        [self.delegate didSelectedStr:[NSString stringWithFormat:@"%zd",row + 1]];
    }else {
        [self.delegate didSelectedStr:self.datas[row]];
    }
    [self hideWithAnimate:YES];
}

- (void)cancel:(UIButton *)btn {
    [self hideWithAnimate:YES];
}

- (void)clickOn:(UITapGestureRecognizer *)tap {
    [self hideWithAnimate:YES];
}

- (void)setDatas:(NSArray *)datas {
    _datas = datas;
    [self.pickerView reloadAllComponents];
}

- (void)showWithAnimate:(BOOL)animate {
    WS(ws);
    [self.coverView addSubview:ws];
    self.coverView.hidden = NO;
    self.frame = CGRectMake(60, kScreenHeight, kScreenWidth - kNavBarHeight, 50 + 216);
    if (animate) {
        [UIView animateWithDuration:0.25 animations:^{
            self.y = kScreenHeight - self.height;
        } completion:^(BOOL finished) {
            nil;
        }];
    }else {
        self.y = kScreenHeight - self.height;
    }
    
    if ([[self.datas lastObject] isEqualToString:@"年龄"]) {
        [self.pickerView selectRow:29 inComponent:0 animated:NO];
    }else {
        [self.pickerView selectRow:0 inComponent:0 animated:NO];
    }
}

- (void)hideWithAnimate:(BOOL)animate {
    if (animate) {
        [UIView animateWithDuration:0.25 animations:^{
            self.y = kScreenHeight;
        } completion:^(BOOL finished) {
            self.coverView.hidden = YES;
            [self removeFromSuperview];
        }];
    }else {
        self.coverView.hidden = YES;
        [self removeFromSuperview];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([[self.datas lastObject] isEqualToString:@"年龄"]) {
        return 100;
    }else
        return self.datas.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([[self.datas lastObject] isEqualToString:@"年龄"]) {
        return [NSString stringWithFormat:@"%zd", row + 1];
    }
    return self.datas[row];
}

- (void)dealloc {}

@end
