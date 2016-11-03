//
//  DetailWebView.m
//  Voicedin
//
//  Created by 顾雄剑 on 15/11/1.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "DetailWebView.h"

@implementation DetailWebView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _wv = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - reportTopViewHeight)];
        
        [self addSubview:_wv];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
