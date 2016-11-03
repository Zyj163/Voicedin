//
//  TestingView.m
//  Voicedin
//
//  Created by zhangyj on 15-9-29.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "TestingView.h"
#import <AVFoundation/AVFoundation.h>

@interface TestingView () <AVAudioPlayerDelegate>
/**
 *  文字图片
 */
@property (nonatomic, weak) UIImageView *imageView;
/**
 *  显示是否正在播放示例文件
 */
@property (nonatomic, weak) UIButton *voiceBtn;

@end

@implementation TestingView

/**
 *  懒加载
 *
 *  @return 文字图片
 */
- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView = imageView;
        [self addSubview:imageView];
        WS(ws);
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(ws);
        }];
        imageView.userInteractionEnabled = YES;
        CGFloat kvoiceBtnRight = 0.0464;
        CGFloat kvoiceBtnTop = 0.052;
        
        //同时添加示例声音状态图片
        UIButton *voiceBtn = [[UIButton alloc]init];
        voiceBtn.userInteractionEnabled = NO;
        self.voiceBtn = voiceBtn;
        [self addSubview:voiceBtn];
        [voiceBtn setImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
        
        [voiceBtn setImage:[UIImage imageNamed:@"voice_over"] forState:UIControlStateSelected];
        voiceBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [voiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-kvoiceBtnRight * kScreenWidth);
            make.top.equalTo(self).offset(kvoiceBtnTop * kScreenHeight);
        }];
        
        //文字图片添加手势点击播放/暂停示例声音
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(playVoice)]];
    }
    return _imageView;
}

/**
 *  设置图片
 */
- (void)setImageName:(NSString *)imageName {
    _imageName = imageName;
    self.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:_imageName ofType:@"png"]];
    
}

//播放示例声音，并切换指示图片
- (void)playVoice {
    self.voiceBtn.selected = !self.voiceBtn.selected;
    if (self.voiceBtn.selected == YES) {
        [PlayerTool playMusic:self.voiceName];
        AVAudioPlayer *player = [PlayerTool getCurrentPlayer:self.voiceName];
        player.delegate = self;
    }else {
        [PlayerTool stopMusic:self.voiceName];
    }
}

//播放结束，切换指示图片
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.voiceBtn.selected = NO;
}

- (void)stopVoice {
    self.voiceBtn.selected = NO;
    [PlayerTool stopMusic:self.voiceName];
}

@end
