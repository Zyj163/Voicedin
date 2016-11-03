//
//  ExampleView.m
//  Voicedin
//
//  Created by zhangyj on 15-9-24.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "ExampleView.h"
@import MediaPlayer;

@interface ExampleView () <AVAudioPlayerDelegate>

/**
 *  当前播放时间
 */
@property (nonatomic, weak) UILabel *leftTimeLabel;
/**
 *  示例声音总时长
 */
@property (nonatomic, weak) UILabel *rightTimeLabel;
/**
 *  第一行文字
 */
@property (nonatomic, weak) UILabel *firstLineLabel;
/**
 *  第二行文字
 */
@property (nonatomic, weak) UILabel *secLineLabel;
/**
 *  第三行文字
 */
@property (nonatomic, weak) UILabel *thirdLineLabel;
/**
 *  示例声音文件名
 */
@property (nonatomic, copy) NSString *voiceFileName;
/**
 *  播放器
 */
@property (nonatomic, weak) AVAudioPlayer *player;
/**
 *  播放/暂停按钮
 */
@property (nonatomic, weak) UIButton *playBtn;
/**
 *  进度条
 */
@property (nonatomic, weak) UISlider *progressSlider;
/**
 *  计时器
 */
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) UISlider *volumeViewSlider;

@end


#define firstLineTop 0.11 * kScreenHeight
#define secondLineTop 0.195 * kScreenHeight
#define thirdLineTop 0.3 * kScreenHeight
#define sliderTop 0.376 * kScreenHeight
#define sliderMargin 0.26 * kScreenWidth
#define playBtnTop 0.433 * kScreenHeight

@implementation ExampleView

- (UISlider *)volumeViewSlider {
    if (!_volumeViewSlider) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        [self addSubview:volumeView];
        
        for (UIView *view in volumeView.subviews){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeViewSlider = (UISlider*)view;
                _volumeViewSlider.hidden = YES;
                break;
            }
        }
    }
    return _volumeViewSlider;
}
/**
 *  懒加载
 *
 *  @return 定时器
 */
- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:0.01
                                         target:self
                                       selector:@selector(updateWithTimer)
                                       userInfo:nil
                                        repeats:YES];
    }
    return _timer;
}

- (UILabel *)leftTimeLabel {
    if (!_leftTimeLabel) {
        CGFloat font = 17 * kScreenHeight / 768;
        UILabel *leftTimeLabel = [[UILabel alloc]init];
        leftTimeLabel.font = [UIFont systemFontOfSize:font];
        self.leftTimeLabel = leftTimeLabel;
        [self addSubview:leftTimeLabel];
        
        [leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.progressSlider.mas_left).offset(-8);
            make.centerY.equalTo(self.progressSlider);
        }];
    }
    return _leftTimeLabel;
}

- (UILabel *)rightTimeLabel {
    if (!_rightTimeLabel) {
        CGFloat font = 17 * kScreenHeight / 768;
        UILabel *rightTimeLabel = [[UILabel alloc]init];
        rightTimeLabel.font = [UIFont systemFontOfSize:font];
        self.rightTimeLabel = rightTimeLabel;
        [self addSubview:rightTimeLabel];
        
        [rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.progressSlider.mas_right).offset(8);
            make.centerY.equalTo(self.progressSlider);
        }];
    }
    return _rightTimeLabel;
}

- (UILabel *)firstLineLabel {
    if (!_firstLineLabel) {
        CGFloat firstLineFontSize = 30 * kScreenHeight / 768;
        UIFont *firstLineFont = [UIFont systemFontOfSize:firstLineFontSize];
        UILabel *firstLineLabel = [[UILabel alloc]init];
        self.firstLineLabel = firstLineLabel;
        [self addSubview:firstLineLabel];
        firstLineLabel.font = firstLineFont;
        firstLineLabel.textAlignment = NSTextAlignmentCenter;
        WS(ws);
        [firstLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(ws);
            make.top.equalTo(@(firstLineTop));
            make.right.equalTo(ws);
        }];
    }
    return _firstLineLabel;
}

- (UILabel *)secLineLabel {
    if (!_secLineLabel) {
        CGFloat secondLineFontSize = 24 * kScreenHeight / 768;
        UIFont *secLineFont = [UIFont systemFontOfSize:secondLineFontSize];
        
        UILabel *secLineLabel = [[UILabel alloc]init];
        self.secLineLabel = secLineLabel;
        [self addSubview:secLineLabel];
        secLineLabel.font = secLineFont;
        secLineLabel.textAlignment = NSTextAlignmentCenter;
        WS(ws);
        [secLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(ws);
            make.top.equalTo(@(secondLineTop));
            make.right.equalTo(ws);
        }];
    }
    return _secLineLabel;
}

- (UILabel *)thirdLineLabel {
    if (!_thirdLineLabel) {
        CGFloat thirdLineFontSize = 18 * kScreenHeight / 768;
        UIFont *thirdLineFont = [UIFont systemFontOfSize:thirdLineFontSize];
        
        UILabel *thirdLineLabel = [[UILabel alloc]init];
        self.thirdLineLabel = thirdLineLabel;
        [self addSubview:thirdLineLabel];
        thirdLineLabel.font = thirdLineFont;
        thirdLineLabel.textAlignment = NSTextAlignmentCenter;
        WS(ws);
        [thirdLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(ws);
            make.top.equalTo(@(thirdLineTop));
            make.right.equalTo(ws);
        }];
    }
    return _thirdLineLabel;
}

- (UISlider *)progressSlider {
    if (!_progressSlider) {
        
        UISlider *progressSlider = [[UISlider alloc]init];
        self.progressSlider = progressSlider;
        [self addSubview:progressSlider];
        
        [progressSlider setThumbImage:[UIImage imageNamed:@"handle"]
                             forState:UIControlStateNormal];
        
        [progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(sliderTop));
            make.left.equalTo(@(sliderMargin));
            make.right.equalTo(@(-sliderMargin));
        }];
        
        progressSlider.value = 0.0;
        [progressSlider setMinimumTrackTintColor:Color(25, 186, 70)];
        
        [progressSlider addTarget:self
                           action:@selector(changeProgress)
                 forControlEvents:UIControlEventValueChanged];
        
        [progressSlider addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(tap:)]];
    }
    return _progressSlider;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        UIButton *playButton = [[UIButton alloc]init];
        self.playBtn = playButton;
        playButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self addSubview:playButton];
        
        [playButton addTarget:self
                       action:@selector(clickOnBtn:)
             forControlEvents:UIControlEventTouchUpInside];
        
        [playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(playBtnTop));
            make.centerX.equalTo(self.progressSlider);
        }];
    }
    return _playBtn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialViews];
    }
    return self;
}

- (void)initialViews {
    
    self.leftTimeLabel.text = @"00:00";
    self.rightTimeLabel.text = @"00:00";
    self.playBtn.selected = NO;
    
    [NSDC addObserver:self
             selector:@selector(playing:)
                 name:PlayingNotification
               object:nil];
    
    [NSDC addObserver:self
             selector:@selector(paused:)
                 name:PauseNotification
               object:nil];
    
    [NSDC addObserver:self
             selector:@selector(stop:)
                 name:StopNotification
               object:nil];
    
    [NSDC addObserver:self
             selector:@selector(reset:)
                 name:Reset
               object:nil];
}

- (void)reset:(NSNotification *)noti {
    [PlayerTool stopMusic:self.voiceFileName];
}

- (void)stopVoice {
    [PlayerTool stopMusic:self.voiceFileName];
}

/**
 *  设置总时长
 */
- (void)setRightLabel {
    self.player = [PlayerTool setCurrentPlayer:self.voiceFileName];
    self.player.delegate = self;
    self.rightTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",
                                (int)self.player.duration/60,
                                (int)self.player.duration%60];
}

/**
 *  设置文字及时间
 *
 *  @param part 哪部分示例
 */
- (void)setPart:(ExampleViewPart)part {
    _part = part;
    switch (part) {
        case ExampleViewPartShengmu:
            self.firstLineLabel.text = @"声母发音测试";
            self.secLineLabel.text = @"请对照每个中文汉字念一遍";
            self.thirdLineLabel.text = @"收听示例";
            self.voiceFileName = @"声母";
            [self setRightLabel];
            break;
        case ExampleViewPartYunmu:
            self.firstLineLabel.text = @"韵母发音测试";
            self.secLineLabel.text = @"请对照每个中文汉字念两遍";
            self.thirdLineLabel.text = @"收听示例";
            self.voiceFileName = @"韵母";
            [self setRightLabel];
            break;
        case ExampleViewPartCizu:
            self.firstLineLabel.text = @"词组发音测试";
            self.secLineLabel.text = @"请对照每个词语念一遍";
            self.thirdLineLabel.text = @"收听示例";
            self.voiceFileName = @"词组";
            [self setRightLabel];
            break;
        case ExampleViewPartDuanyu:
            self.firstLineLabel.text = @"短句发音测试";
            self.secLineLabel.text = @"请对照每个短句念一遍";
            self.thirdLineLabel.text = @"收听示例";
            self.voiceFileName = @"短句";
            [self setRightLabel];
            break;
        default:
            self.firstLineLabel.text = @"";
            self.secLineLabel.text = @"";
            self.thirdLineLabel.text = @"";
            self.voiceFileName = nil;
            [self setRightLabel];
            break;
    }
}

/**
 *  播放控制按钮点击
 */
- (void)clickOnBtn:(UIButton *)sender {
    if (self.voiceFileName == nil) {
        return;
    }
    if (self.player.isPlaying == NO) {
        [PlayerTool playMusic:self.voiceFileName];
    }else {
        [PlayerTool pauseMusic:self.voiceFileName];
    }
}

#pragma mark - playerNotification
/**
 *  开始播放，启动定时器，切换按钮图片
 *
 *  @param noti 开始播放通知
 */
- (void)playing:(NSNotification *)noti {
    if ([noti.userInfo[@"fileName"] isEqualToString:self.voiceFileName]) {
        [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
}

/**
 *  播放暂停，关闭定时器，切换按钮图片，设置进度时间
 *
 *  @param noti 暂定播放通知
 */
- (void)paused:(NSNotification *)noti {
    
    if ([noti.userInfo[@"fileName"] isEqualToString:self.voiceFileName]) {
        [_timer invalidate];
        _timer = nil;
        self.leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",
                                   (int)self.player.currentTime/60,
                                   (int)self.player.currentTime%60];
        
        [self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

/**
 *  播放停止通知，恢复初始状态
 *
 *  @param noti 播放停止通知
 */
- (void)stop:(NSNotification *)noti {
    
    if ([noti.userInfo[@"fileName"] isEqualToString:self.voiceFileName]) {
        [_timer invalidate];
        _timer = nil;
        self.leftTimeLabel.text = @"00:00";
        self.progressSlider.value = 0;
        [self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

- (void)dealloc {
    [NSDC removeObserver:self];
}

#pragma mark - playerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self stop:nil];
}

#pragma mark - sliderAction
//拖动进度
- (void)changeProgress {
    CGFloat progress = self.progressSlider.value;
    self.player.currentTime = self.player.duration * progress;
    self.leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",
                               (int)self.player.currentTime/60,
                               (int)self.player.currentTime%60];
}

//点击改变进度
- (void)tap:(UITapGestureRecognizer *)tap {
    CGPoint location = [tap locationInView:tap.view];
    CGFloat progress = location.x / tap.view.width;
    self.player.currentTime = self.player.duration * progress;
    self.progressSlider.value = progress;
    
    self.leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",
                               (int)self.player.currentTime/60,
                               (int)self.player.currentTime%60];
}

#pragma mark - timer
//跟随计时器刷新界面
- (void)updateWithTimer {
    self.progressSlider.value = self.player.currentTime / self.player.duration;
    
    self.leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",
                               (int)self.player.currentTime/60,
                               (int)self.player.currentTime%60];
}

//手势改变系统音量
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGPoint preLocation = [touch previousLocationInView:self];
    CGFloat distance = preLocation.y - location.y;
    
    //改变真机音量
    
    float systemVolume = self.volumeViewSlider.value + distance * 0.001;
    
    [self.volumeViewSlider setValue:systemVolume animated:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.volumeViewSlider.superview removeFromSuperview];
}

@end








