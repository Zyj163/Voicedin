//
//  ZJLoading.m
//  Voicedin
//
//  Created by zhangyj on 15-10-10.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "ZJLoading.h"
#import "CATextLayer+Extension.h"

static NSString *StrokeAnimationKey = @"stroke";
static NSString *RotationAnimationKey = @"rotation";

@interface ZJLoading ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, readwrite) BOOL isAnimating;
@property (strong, nonatomic) NSTimer *colorTimer;
@property (copy, nonatomic) NSString *message;
@property (weak, nonatomic) CATextLayer *messageLayer;
@property (strong, nonatomic) CALayer *backLayer;

@property (strong, nonatomic) NSArray *balls;
@property (assign, nonatomic) NSInteger countOfBalls;

@end

#define ChangeColor Color(arc4random_uniform(256) + 128, arc4random_uniform(256) + 128,arc4random_uniform(256) + 128)

@implementation ZJLoading

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

//小背景
- (CALayer *)backLayer {
    if (!_backLayer) {
        _backLayer = [[CALayer alloc]init];
        _backLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7].CGColor;
        _backLayer.anchorPoint = CGPointMake(0.5, 0.5);
        _backLayer.cornerRadius = 5;
    }
    return _backLayer;
}

//定时器
- (NSTimer *)colorTimer {
    if (!_colorTimer) {
        _colorTimer = [NSTimer timerWithTimeInterval:1.5f target:self selector:@selector(changeColor) userInfo:nil repeats:YES];
    }
    return _colorTimer;
}

- (void)initialize {
    
    [self.layer addSublayer:self.backLayer];
    
    _timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.layer addSublayer:self.progressLayer];
    
    self.progressLayer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAnimations) name:UIApplicationDidBecomeActiveNotification object:nil];
}

#define messageFont 16
- (void)setMessage:(NSString *)message {
    _message = message;
    CATextLayer *messageLayer = [CATextLayer textLayerWithStr:self.message color:self.tintColor fontSize:messageFont alimentMode:@"center"];
    self.messageLayer = messageLayer;
    messageLayer.anchorPoint = CGPointMake(0.5, 0);
    messageLayer.bounds = CGRectMake(0, 0, message.length * messageFont, messageFont * 1.5);
    messageLayer.font = (__bridge CFTypeRef)([UIFont boldSystemFontOfSize:messageFont]);
    
    [self.layer addSublayer:messageLayer];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}


#define spaceBetweenMessageAndProgress 10
#define inset 50

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat x = self.centerX - self.loadingRadius - self.lineWidth;
    CGFloat y = self.centerY - self.messageLayer.bounds.size.height * 1.5 - spaceBetweenMessageAndProgress;
    CGFloat w = self.loadingRadius * 2 + self.lineWidth * 2;
    CGFloat h = w;
    
    self.progressLayer.frame = CGRectMake(x, y, w, h);
    
    self.progressLayer.cornerRadius = w / 2;
    
    self.messageLayer.position = CGPointMake(self.centerX, CGRectGetMaxY(self.progressLayer.frame) + spaceBetweenMessageAndProgress);
    
    
    self.backLayer.position = CGPointMake(self.centerX, self.centerY);
    self.backLayer.bounds = CGRectMake(0, 0, MAX(self.messageLayer.bounds.size.width, self.progressLayer.bounds.size.width) + inset, self.messageLayer.bounds.size.height * 0.5 + spaceBetweenMessageAndProgress + self.progressLayer.bounds.size.height + inset);
    
    [self updatePathWithRadius:self.loadingRadius];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    self.messageLayer.foregroundColor = self.progressLayer.strokeColor = self.tintColor.CGColor;
}

- (void)resetAnimations {
    
    if (self.isAnimating) {
        [self stopAnimating];
        [self startAnimating];
    }
}

- (void)setAnimating:(BOOL)animate {
    (animate ? [self startAnimating] : [self stopAnimating]);
}

- (void)startAnimating {
    if (self.isAnimating)
        return;
    
    [[NSRunLoop mainRunLoop]addTimer:self.colorTimer forMode:NSRunLoopCommonModes];
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.duration = 4.f;
    animation.fromValue = @(0.f);
    animation.toValue = @(2 * M_PI);
    animation.repeatCount = INFINITY;
    [self.progressLayer addAnimation:animation forKey:RotationAnimationKey];
    
    CABasicAnimation *headAnimation = [CABasicAnimation animation];
    headAnimation.keyPath = @"strokeStart";
    headAnimation.duration = 1.f;
    headAnimation.fromValue = @(0.f);
    headAnimation.toValue = @(0.25f);
    headAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *tailAnimation = [CABasicAnimation animation];
    tailAnimation.keyPath = @"strokeEnd";
    tailAnimation.duration = 1.f;
    tailAnimation.fromValue = @(0.f);
    tailAnimation.toValue = @(1.f);
    tailAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *endHeadAnimation = [CABasicAnimation animation];
    endHeadAnimation.keyPath = @"strokeStart";
    endHeadAnimation.beginTime = 1.f;
    endHeadAnimation.duration = 0.5f;
    endHeadAnimation.fromValue = @(0.25f);
    endHeadAnimation.toValue = @(1.f);
    endHeadAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *endTailAnimation = [CABasicAnimation animation];
    endTailAnimation.keyPath = @"strokeEnd";
    endTailAnimation.beginTime = 1.f;
    endTailAnimation.duration = 0.5f;
    endTailAnimation.fromValue = @(1.f);
    endTailAnimation.toValue = @(1.f);
    endTailAnimation.timingFunction = self.timingFunction;
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    [animations setDuration:1.5f];
    [animations setAnimations:@[headAnimation, tailAnimation, endHeadAnimation, endTailAnimation]];
    animations.repeatCount = INFINITY;
    [self.progressLayer addAnimation:animations forKey:StrokeAnimationKey];
    
    self.isAnimating = true;
    
    if (self.hidesWhenStopped) {
        self.hidden = NO;
    }
}

- (void)changeColor {
    self.tintColor = ChangeColor;
}

- (void)stopAnimating {
    if (!self.isAnimating)
        return;
    
    [self.colorTimer invalidate];
    self.colorTimer = nil;
    [self.progressLayer removeAnimationForKey:RotationAnimationKey];
    [self.progressLayer removeAnimationForKey:StrokeAnimationKey];
    self.isAnimating = false;
    
    if (self.hidesWhenStopped) {
        self.hidden = YES;
    }
}

- (void)updatePathWithRadius:(CGFloat)radius {
    CGPoint center = CGPointMake(CGRectGetMidX(self.progressLayer.bounds), CGRectGetMidY(self.progressLayer.bounds));
    if (radius <= 0) {
        radius = MIN(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2) - self.progressLayer.lineWidth / 2;
    }
    CGFloat startAngle = (CGFloat)(0);
    CGFloat endAngle = (CGFloat)(2*M_PI);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius + self.lineWidth / 2 startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.progressLayer.path = path.CGPath;
    
    self.progressLayer.strokeStart = 0.f;
    self.progressLayer.strokeEnd = 0.f;
}

#pragma mark - Properties

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.strokeColor = self.tintColor.CGColor;
        _progressLayer.fillColor = nil;
        _progressLayer.lineWidth = 3.0f;
        _progressLayer.anchorPoint = CGPointMake(0.5, 0.5);
    }
    return _progressLayer;
}

- (BOOL)isAnimating {
    return _isAnimating;
}

- (CGFloat)lineWidth {
    return self.progressLayer.lineWidth;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    self.progressLayer.borderWidth = self.progressLayer.lineWidth = lineWidth;
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped {
    _hidesWhenStopped = hidesWhenStopped;
    self.hidden = !self.isAnimating && hidesWhenStopped;
}

#pragma mark - 类方法

+ (void)addLoadingMessage:(NSString *)message toView:(UIView *)view {
    
    ZJLoading *loading = [[self alloc]init];
    if (message && message.length > 0) {
        loading.message = message;
    }
    loading.tintColor = [UIColor greenColor];
    loading.lineWidth = 3;
    
    if (view == nil) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        view = window;
        [view addSubview:loading];
        [loading mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(view);
            make.left.equalTo(view).offset(kTabBarHeight * 0.5);
        }];
    }else {
        [view addSubview:loading];
        [loading mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
        }];
    }
    loading.loadingRadius = 30;
    [loading startAnimating];
}

+ (void)hideLoadingFromView:(UIView *)view {
    
    if (view == nil) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        view = window;
    }
    
    for (UIView *loadingView in view.subviews) {
        if ([loadingView isKindOfClass:[self class]]) {
            ZJLoading *loading = (ZJLoading *)loadingView;
            [loading stopAnimating];
            [loading removeFromSuperview];
            return;
        }
    }
}

@end













