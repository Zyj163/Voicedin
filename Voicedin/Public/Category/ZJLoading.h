//
//  ZJLoading.h
//  Voicedin
//
//  Created by zhangyj on 15-10-10.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJLoading : UIView

@property (nonatomic, assign) CGFloat loadingRadius;

@property (nonatomic) CGFloat lineWidth;

@property (nonatomic) BOOL hidesWhenStopped;

@property (nonatomic, strong) CAMediaTimingFunction *timingFunction;

@property (nonatomic, readonly) BOOL isAnimating;

- (void)setAnimating:(BOOL)animate;

- (void)startAnimating;

- (void)stopAnimating;

+ (void)addLoadingMessage:(NSString *)message toView:(UIView *)view;
+ (void)hideLoadingFromView:(UIView *)view;
@end
