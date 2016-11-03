//
//  AboutAndExit.m
//  Voicedin
//
//  Created by 顾雄剑 on 15/10/21.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "AboutAndExit.h"
#import "LoginViewController.h"

@interface AboutAndExit ()

@property(nonatomic,strong)UIImageView*aboutView;
@property(nonatomic,strong)UIImageView*logo;
@property(nonatomic,strong)UILabel*aboutLabel;
@property(nonatomic,strong)UIButton*exitButton;
@property(nonatomic,strong)UIButton*soundButton;

@end

@implementation AboutAndExit

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:43./255. green:44./255. blue:47./255. alpha:1];
        self.userInteractionEnabled = YES;
        self.logo = [[UIImageView alloc]initWithFrame:CGRectMake(leftViewWidth/3, leftViewWidth/3, leftViewWidth/3, leftViewWidth/4)];
        self.logo.image = [UIImage imageNamed:@"logo"];
        [self addSubview:self.logo];
        self.aboutLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.logo.frame), leftViewWidth, leftViewWidth/3)];
        self.aboutLabel.text = @"百灵说V1.0.1";
        self.aboutLabel.textColor = [UIColor whiteColor];
        self.aboutLabel.textAlignment = NSTextAlignmentCenter;
        self.aboutLabel.font = [UIFont fontWithName:@"arial" size:16];
        [self addSubview:self.aboutLabel];

        self.exitButton = [[UIButton alloc]initWithFrame:CGRectMake(0, leftViewWidth+leftButtonSpace, leftViewWidth, leftViewWidth)];
        [self.exitButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:59./255. green:60./255. blue:65./255. alpha:1]] forState:UIControlStateNormal];
        [self.exitButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:53./255. green:54./255. blue:59./255. alpha:1]] forState:UIControlStateHighlighted];
        [self.exitButton setTitle:@"退出授权" forState:UIControlStateNormal];
        [self.exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.exitButton addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
        self.exitButton.titleLabel.font = [UIFont fontWithName:@"arial" size:16];
        [self addSubview:self.exitButton];
        
        self.soundButton = [[UIButton alloc]initWithFrame:CGRectMake(0, (leftViewWidth+leftButtonSpace)*2, leftViewWidth, leftViewWidth)];
        [self.soundButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:59./255. green:60./255. blue:65./255. alpha:1]] forState:UIControlStateNormal];
        [self.soundButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:53./255. green:54./255. blue:59./255. alpha:1]] forState:UIControlStateHighlighted];
        if ([NSUD objectForKey:ClickSound] == nil) {
            [self.soundButton setTitle:@"打开提示音" forState:UIControlStateNormal];
        }else {
            [self.soundButton setTitle:@"关闭提示音" forState:UIControlStateNormal];
        }
        [self.soundButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.soundButton addTarget:self action:@selector(soundButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.soundButton.titleLabel.font = [UIFont fontWithName:@"arial" size:16];
        [self addSubview:self.soundButton];

    }
    return self;
}
- (void)soundButtonClick:(UIButton *)button {
    ZJLog(@"xxxx");

    if ([NSUD objectForKey:ClickSound] == nil) {
        [NSUD setObject:@1 forKey:ClickSound];
        [self.soundButton setTitle:@"关闭提示音" forState:UIControlStateNormal];
        [PlayerTool playMusic:@"ButtonClick"];
    }else {
        [NSUD removeObjectForKey:ClickSound];
        [self.soundButton setTitle:@"打开提示音" forState:UIControlStateNormal];
    }
    [NSUD synchronize];
    [NSDC postNotificationName:RollBack object:nil];
}
- (void)logout:(UIButton*)button {
    if ([self.delegate respondsToSelector:@selector(VoicedinLogout)]) {
        [self.delegate VoicedinLogout];
    }
}
//定义纯色的image
-(UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
