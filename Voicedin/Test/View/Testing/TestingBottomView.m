//
//  TestingBottomView.m
//  Voicedin
//
//  Created by zhangyj on 15-9-25.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "TestingBottomView.h"
#import <AVFoundation/AVFoundation.h>
#import "RecroderManager.h"

@interface WaveFormView : UIView

- (void)updateWithLevel:(CGFloat)level;

@end

@interface TestingBottomView ()
/**
 *  录音对象
 */
@property (nonatomic, weak) AVAudioRecorder *recorder;
/**
 *  波浪视图
 */
@property (nonatomic, weak) WaveFormView *waveformView;
/**
 *  屏幕刷新定时器
 */
@property (weak, nonatomic) CADisplayLink *displayLink;
/**
 *  录音时长
 */
@property (nonatomic, weak) UILabel *timeLabel;

@property (nonatomic, copy) NSString *currentWaveName;

@property (nonatomic, assign) NSTimeInterval startTime;

@end

@implementation TestingBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialViews];
        [NSDC addObserver:self
                 selector:@selector(reset)
                     name:@"reset"
                   object:nil];
    }
    return self;
}

- (void)initialViews {
#define btnWidth kScreenWidth * 0.18
    
    CGFloat font = 24 * kScreenHeight / 768;
    
    //重新开始
    UIButton *restartBtn = [[UIButton alloc]init];
    [self addSubview:restartBtn];
    [restartBtn setTitle:@"重新录音" forState:UIControlStateNormal];
    restartBtn.titleLabel.font = [UIFont systemFontOfSize:font];
    [restartBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [restartBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.width.equalTo(@(btnWidth));
    }];
    
    [restartBtn addTarget:self
                   action:@selector(clickOnRestart:)
         forControlEvents:UIControlEventTouchUpInside];
    
    //完成
    UIButton *finishBtn = [[UIButton alloc]init];
    [self addSubview:finishBtn];
    [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    finishBtn.titleLabel.font = [UIFont systemFontOfSize:font];
    
    [finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(self);
        make.width.equalTo(@(btnWidth));
    }];
    
    [finishBtn addTarget:self
                  action:@selector(clickOnFinishBtn:)
        forControlEvents:UIControlEventTouchUpInside];
    
    [restartBtn setBackgroundImage:[UIImage imageNamed:@"orange-normal"] forState:UIControlStateNormal];
    [restartBtn setBackgroundImage:[UIImage imageNamed:@"orange-highlight"] forState:UIControlStateHighlighted];
    [finishBtn setBackgroundImage:[UIImage imageNamed:@"disable"] forState:UIControlStateDisabled];
    [finishBtn setBackgroundImage:[UIImage imageNamed:@"green2-normal"] forState:UIControlStateNormal];
    [finishBtn setBackgroundImage:[UIImage imageNamed:@"green2-highlight"] forState:UIControlStateHighlighted];
    
    WaveFormView *view = [[WaveFormView alloc]init];
    self.waveformView = view;
    view.backgroundColor = Color(29, 186, 70);
    [self addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(restartBtn.mas_right);
        make.top.bottom.equalTo(self);
        make.right.equalTo(finishBtn.mas_left);
    }];
    
    //录音时长
    UILabel *timeLabel = [[UILabel alloc]init];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.text = @"00:00";
    [self addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view).offset(-10);
        make.top.equalTo(view).offset(8);
    }];

}

/**
 *  启动录音
 *
 *  @param recordName 录音名
 */
- (void)startRecordWave:(NSString *)recordName waveName:(NSString *)waveName
{
    self.recorder = [RecroderManager getCourseRecorderWithName:recordName];
    [self.recorder setMeteringEnabled:YES];
    self.currentWaveName = waveName;
    //设置起始时间
    self.startTime = self.recorder.currentTime;
    [RecroderManager setRecordWithName:waveName startTime:self.recorder.currentTime];
    
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    self.displayLink = displaylink;
    [displaylink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

/**
 *  跟随定时器刷新界面
 */
- (void)updateMeters
{
    //记录时长
    NSTimeInterval time = self.recorder.currentTime - self.startTime;
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",
                           (int)time/60,
                           (int)time%60];
    
    [self.recorder updateMeters];
    
    CGFloat normalizedValue = pow (10, [self.recorder averagePowerForChannel:0] / 50);
    
    [self.waveformView updateWithLevel:normalizedValue];
}

/**
 *  重新开始
 */
- (void)clickOnRestart:(UIButton *)btn {
    if (btn) {
        [PlayerTool playMusic:@"ButtonClick"];
    }
    [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self.delegate TestingBottomView:self clickOnRestartBtn:btn];
}

/**
 *  完成
 */
- (void)clickOnFinishBtn:(UIButton *)btn {
    [PlayerTool playMusic:@"ButtonClick"];
    [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    //设置结束时间戳
    [RecroderManager setRecordWithName:self.currentWaveName endTime:self.recorder.currentTime];
    
    [self.delegate TestingBottomView:self clickOnFinishBtn:btn];
}

//接受复位通知（将定时器从运行循环移除）
- (void)reset {
    [self clickOnRestart:nil];
}

- (void)dealloc {
    [NSDC removeObserver:self];
}

@end


@interface WaveFormView ()

@property (nonatomic, assign) CGFloat phase;

@property (nonatomic, assign) CGFloat amplitude;

@property (nonatomic, assign) NSUInteger numberOfWaves;

@property (nonatomic, strong) UIColor *waveColor;

@property (nonatomic, assign) CGFloat primaryWaveLineWidth;

@property (nonatomic, assign) CGFloat secondaryWaveLineWidth;

@property (nonatomic, assign) CGFloat idleAmplitude;

@property (nonatomic, assign) CGFloat frequency;

@property (nonatomic, assign) CGFloat density;

@property (nonatomic, assign) CGFloat phaseShift;

@end

@implementation WaveFormView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.frequency = 1.5;
    
    self.amplitude = 0.0;
    self.idleAmplitude = 0.01;
    
    self.numberOfWaves = 5;
    self.phaseShift = - 0.15;
    self.density = 5.0;
    
    self.waveColor = [UIColor whiteColor];
    self.primaryWaveLineWidth = 3.0;
    self.secondaryWaveLineWidth = 1.0;
}

-(void)updateWithLevel:(CGFloat)level
{
    self.phase += self.phaseShift;
    self.amplitude = fmax( level, self.idleAmplitude);
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, self.bounds);
    
    [self.backgroundColor set];
    CGContextFillRect(context, rect);
    
    for(int i=0; i < self.numberOfWaves; i++) {
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetLineWidth(context, (i==0 ? self.primaryWaveLineWidth : self.secondaryWaveLineWidth));
        
        CGFloat halfHeight = CGRectGetHeight(self.bounds) * 0.5;
        CGFloat width = CGRectGetWidth(self.bounds);
        CGFloat mid = width * 0.5;
        
        const CGFloat maxAmplitude = halfHeight - 4;
        
        CGFloat progress = 1 - (CGFloat)i / self.numberOfWaves;
        CGFloat normedAmplitude = (1.5 * progress - 0.5) * self.amplitude;
        
        CGFloat multiplier = MIN(1.0, (progress / 3.0 * 2.0) + (1.0 / 3.0));
        [[self.waveColor colorWithAlphaComponent:multiplier * CGColorGetAlpha(self.waveColor.CGColor)] set];
        
        for(CGFloat x = 0; x < width + self.density; x += self.density) {
            
            CGFloat scaling = -pow(1 / mid * (x - mid), 2) + 1;
            
            CGFloat y = scaling * maxAmplitude * normedAmplitude * sinf(2 * M_PI *(x / width) * self.frequency + self.phase) + halfHeight;
            
            if (x==0) {
                CGContextMoveToPoint(context, x, y);
            }
            else {
                CGContextAddLineToPoint(context, x, y);
            }
        }
        
        CGContextStrokePath(context);
    }
}


@end



















