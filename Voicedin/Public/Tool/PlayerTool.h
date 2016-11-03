//
//  PlayerTool.h
//  Voicedin
//
//  Created by zhangyj on 15-9-25.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayerTool : NSObject
+ (BOOL)playMusic:(NSString*)fileName;
+ (BOOL)pauseMusic:(NSString*)fileName;
+ (BOOL)stopMusic:(NSString*)fileName;
+ (AVAudioPlayer*)getCurrentPlayer:(NSString*)fileName;
+ (AVAudioPlayer*)setCurrentPlayer:(NSString*)fileName;

UIKIT_EXTERN NSString *const PlayingNotification;
UIKIT_EXTERN NSString *const PauseNotification;
UIKIT_EXTERN NSString *const StopNotification;

@end
