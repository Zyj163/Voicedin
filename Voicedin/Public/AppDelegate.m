//
//  AppDelegate.m
//  CustomTabBar
//
//  Created by zhangyongjun on 15/9/19.
//  Copyright (c) 2015年 张永俊. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "CustomTabBarController.h"
#import "Author.h"
#import "NSString+Extension.h"
#import "APService.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    //判断有无授权
    Author *author = [NSKeyedUnarchiver unarchiveObjectWithFile:authorFile];
    
    if (author && author.auth_id.length > 0) {
        self.window.rootViewController = [[CustomTabBarController alloc] init];
        
    }else {
        self.window.rootViewController = [[LoginViewController alloc]init];
    }
    self.window.backgroundColor = Color(32, 33, 35);
    [self.window makeKeyAndVisible];
    
    // Required
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
#else
    //categories 必须为nil
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
#endif
    // Required
    [APService setupWithOption:launchOptions];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *devTkn = [NSString stringWithFormat:@"%@",deviceToken];
    NSLog(@"deviceToken------%@\n[APService registrationID]%@",devTkn,[APService registrationID]);
    // Required
    [NSUD setObject:[APService registrationID] forKey:registID];
    
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [application setApplicationIconBadgeNumber:0];
    
    [NSDC postNotificationName:kJPFNetworkDidReceiveMessageNotification object:nil userInfo:userInfo];
    
    // Required
    [APService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [application setApplicationIconBadgeNumber:0];
    
    [NSDC postNotificationName:kJPFNetworkDidReceiveMessageNotification object:nil userInfo:userInfo];
    
    // IOS 7 Support Required
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
}

//清理本次授权下的所有文件
//- (void)applicationWillTerminate:(UIApplication *)application {
//    Author *author = [NSKeyedUnarchiver unarchiveObjectWithFile:authorFile];
//    if (!author) return;
//    NSString *path = [authorFile stringByDeletingLastPathComponent];
//    NSError *error;
//    if ([NSFM fileExistsAtPath:path]) {
//        [NSFM removeItemAtPath:[path stringByAppendingPathComponent:author.auth_id] error:&error];
//        if (error) {
//            ZJLog(@"applicationWillTerminate清理文件错误：%@",error);
//        }
//    }
//    [NSFM removeItemAtPath:authorFile error:&error];
//    if (error) {
//        ZJLog(@"applicationWillTerminate清理授权文件错误：%@",error);
//    }
//}


@end











