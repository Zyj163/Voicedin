//
//  AboutAndExit.h
//  Voicedin
//
//  Created by 顾雄剑 on 15/10/21.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AboutAndExit;

@protocol AboutAndExitDelelgate <NSObject>

- (void)VoicedinLogout;

@end

@interface AboutAndExit : UIView

@property(nonatomic,assign)id <AboutAndExitDelelgate> delegate;

@end
