//
//  Const.h
//  Voicedin
//
//  Created by zhangyj on 15-9-22.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Const : NSObject

#ifdef DEBUG
#define ZJLog(...) NSLog(__VA_ARGS__)
#else
#define ZJLog(...)
#endif

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define iOS7 (([[[UIDevice currentDevice] systemVersion] doubleValue] >=7.0f && [[[UIDevice currentDevice] systemVersion] doubleValue] <8.0) ? YES :NO)
#define iOS8 (([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0f) ? YES : NO)

//以十六进制的方式获取颜色
#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define Color(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define RandomColor Color(arc4random_uniform(256), arc4random_uniform(256),arc4random_uniform(256))

#define WS(weakSelf) __weak typeof(self) (weakSelf) = self

#define kScreenHeight (iOS8 ? ([UIScreen mainScreen].bounds.size.height) :(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height))

#define kScreenWidth (iOS8 ? ([UIScreen mainScreen].bounds.size.width) : (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width))

#define kStatusBarHeight (iPhone6Plus ? 30 : 20)
#define kNavBarHeight    (iPhone6Plus ? 66 : 44)
#define kKeyboardHeight (iPhone6Plus ? 226 : 216)
#define kKeyboardLandspaceheight 194
#define kiPadKeyBoardHeight 303
#define kiPadLadnSapceKeyBoardHeight 391
#define kTabBarHeight (iPhone6Plus ? (147/2.0) : 49)
#define kToolbarHeight 44

#define leftViewWidth  135
#define leftButtonSpace 10
#define reportTopViewHeight 45
#define datePickerHeight 280
#define datePickerTopHeight 44
#define REPORT_LIST_URL @"http://api.fluvoice.com/report_list/report_list"
#define SEVICETERM_URL @"http://api.fluvoice.com/service/service_view"
#define PRIVATETERM_URL @"http://api.fluvoice.com/service/service_list"

#define NSDC [NSNotificationCenter defaultCenter]
#define NSUD [NSUserDefaults standardUserDefaults]
#define NSFM [NSFileManager defaultManager]

#define RecordFile(authFolder,folderName,fileName,type) \
                ([NSURL fileURLWithPath:\
                [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] \
                stringByAppendingPathComponent:(folderName) ? \
                [NSString stringWithFormat:@"%@/%@/%@.%@",(authFolder),(folderName),(fileName),(type)] : \
                [NSString stringWithFormat:@"%@/%@.%@",(authFolder),(fileName),(type)]]])

#define RecordFilePath(authFolder,folderName,fileName,type) \
                ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] \
                stringByAppendingPathComponent:(folderName) ? \
                ((folderName) ? \
                ((fileName) ? \
                [NSString stringWithFormat:@"%@/%@/%@.%@",(authFolder),(folderName),(fileName),(type)] : \
                [NSString stringWithFormat:@"%@/%@",(authFolder),(folderName)]) :\
                [NSString stringWithFormat:@"%@/%@",(authFolder),(folderName)]) :\
                [NSString stringWithFormat:@"%@/%@.%@",(authFolder),(fileName),(type)]])

#define timeFlagFile(authFolder,folderName,fileName,time) \
                ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] \
                stringByAppendingPathComponent:\
                [NSString stringWithFormat:@"%@/%@/%@_%@.plist",(authFolder),(folderName),(time),(fileName)]])

#define authorFile ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"author.db"])

#define personFile ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"person.db"])

#define failureFile(authFolder,folderName) [RecordFilePath(authFolder,folderName,nil,nil) stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_failure.plist",(folderName)]]

#define timeOptFile ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"timeOpt.plist"])

#define terminatePosition @"terminatePosition"

#define continueFromTerminate @"continueFromTerminate"

#define registID @"registrationID"

UIKIT_EXTERN const CGFloat StatusHeight;
UIKIT_EXTERN const CGFloat TabBarHOrW;
UIKIT_EXTERN NSString *const UnfinishedCount;

UIKIT_EXTERN NSString *const ClickSound;
UIKIT_EXTERN NSString *const RollBack;
UIKIT_EXTERN NSString *const ChangeTabBarBadge;
UIKIT_EXTERN NSString *const TabBarBadgeIsShow;
UIKIT_EXTERN NSString *const BadgeOfTarget;
UIKIT_EXTERN NSString *const Reset;

UIKIT_EXTERN NSString *const GotoDead;

UIKIT_EXTERN NSString *const uploadPersonInfoUrlStr;
UIKIT_EXTERN NSString *const loginUrlStr;
UIKIT_EXTERN NSString *const logoutUrlStr;
UIKIT_EXTERN NSString *const getDiseaseUrlStr;
UIKIT_EXTERN NSString *const getGradeUrlStr;
UIKIT_EXTERN NSString *const judgeNewPerson;


UIKIT_EXTERN NSString *const personInfoPart;
UIKIT_EXTERN NSString *const shengmuPart;
UIKIT_EXTERN NSString *const yunmuPart;
UIKIT_EXTERN NSString *const cizuPart;
UIKIT_EXTERN NSString *const duanjuPart;

@end
