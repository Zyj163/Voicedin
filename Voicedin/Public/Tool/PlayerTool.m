//
//  PlayerTool.m
//  Voicedin
//
//  Created by zhangyj on 15-9-25.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "PlayerTool.h"

#define testVoiceUrl(fileName) [[NSBundle mainBundle] URLForResource:(fileName) withExtension:@"m4a"]
#define buttonVoiceUrl(fileName) [[NSBundle mainBundle] URLForResource:(fileName) withExtension:@"wav"]

static NSMutableDictionary *_musicPlayers;

@implementation PlayerTool

NSString *const PlayingNotification = @"PlayingNotification";
NSString *const PauseNotification = @"PauseNotification";
NSString *const StopNotification = @"StopNotification";

+ (void)initialize {
    if (!_musicPlayers) {
        _musicPlayers = [NSMutableDictionary dictionary];
    }
}

+ (AVAudioPlayer*)getCurrentPlayer:(NSString*)fileName{
    if (!fileName) {
        return nil;
    }
    if (!_musicPlayers[fileName]) {
        return nil;
    }
    return _musicPlayers[fileName];
}

+ (AVAudioPlayer*)setCurrentPlayer:(NSString*)fileName {
    if (!fileName) {
        return nil;
    }
    if ([fileName isEqualToString:@"ButtonClick"] && ![NSUD objectForKey:ClickSound]) {
        return nil;
    }
    AVAudioPlayer *player = _musicPlayers[fileName];
    if (!player) {
        NSURL *url = testVoiceUrl(fileName);
        if (!url && [NSUD objectForKey:ClickSound]) {
            url = buttonVoiceUrl(fileName);
        }
        NSError *error;
        player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _musicPlayers[fileName] = player;
    }
    return player;
}

//播放
+ (BOOL)playMusic:(NSString*)fileName {
    if (!fileName) {
        return NO;
    }
    if ([fileName isEqualToString:@"ButtonClick"] && ![NSUD objectForKey:ClickSound]) {
        return nil;
    }
    AVAudioPlayer *player = _musicPlayers[fileName];
    if (!player) {
        NSURL *url = testVoiceUrl(fileName);
        if (!url && [NSUD objectForKey:ClickSound]) {
            url = buttonVoiceUrl(fileName);
        }
        NSError *error;
        player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        if (![player prepareToPlay]) {
            return NO;
        }
        _musicPlayers[fileName] = player;
    }
    if (!player.isPlaying) {
        [player play];
        if (![player.url.absoluteString isEqualToString:buttonVoiceUrl(fileName).absoluteString]) {
            [[NSNotificationCenter defaultCenter]postNotificationName:PlayingNotification object:self userInfo:@{@"player" : player, @"fileName" : fileName}];
        }
    }
    return YES;
}


//暂停
+ (BOOL)pauseMusic:(NSString*)fileName {
    if (!fileName) {
//        for (AVAudioPlayer *player in [_musicPlayers allValues]) {
//            [player pause];
//            [[NSNotificationCenter defaultCenter]postNotificationName:PauseNotification object:self userInfo:@{@"player" : player}];
//            return YES;
//        }
        return NO;
    }else{
        AVAudioPlayer *player = _musicPlayers[fileName];
        if (player && player.isPlaying) {
            [player pause];
            if (![player.url.absoluteString isEqualToString:buttonVoiceUrl(fileName).absoluteString]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:PauseNotification object:self userInfo:@{@"player" : player, @"fileName" : fileName}];
            }
            return YES;
        }
    }
    return NO;
}


//停止
+ (BOOL)stopMusic:(NSString*)fileName {
    if (!fileName) {
//        for (AVAudioPlayer *player in [_musicPlayers allValues]) {
//            [player stop];
//            [[NSNotificationCenter defaultCenter]postNotificationName:StopNotification object:self userInfo:@{@"player" : player}];
//            [_musicPlayers removeObjectForKey:fileName];
//            return YES;
//        }
        return NO;
    }else {
        AVAudioPlayer *player = _musicPlayers[fileName];
        if (player) {
            [player stop];
            if (![player.url.absoluteString isEqualToString:buttonVoiceUrl(fileName).absoluteString]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:StopNotification object:self userInfo:@{@"player" : player, @"fileName" : fileName}];
            }
            [_musicPlayers removeObjectForKey:fileName];
            return YES;
        }
    }
    return NO;
}

@end
