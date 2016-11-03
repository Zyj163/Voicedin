//
//  CustomTabBarController
//  CustomTabBarController
//
//  Created by zhangyongjun on 15/9/19.
//  Copyright (c) 2015年 张永俊. All rights reserved.
//
/**
 *  自定义TabBarController
 */

#import "CustomTabBarController.h"
#import "TestViewController.h"
#import "TestReportViewController.h"
#import "SettingViewController.h"
#import "LoginViewController.h"
#import "NetworkingManager.h"
#import "LoginOrOut.h"

@interface CustomTabBarController () <CustomTabBarTabBarDelegate, AboutAndExitDelelgate, UIAlertViewDelegate>
@property (nonatomic, assign) CGFloat leftViewX;
@property (nonatomic, weak) UIAlertView *alertView;
@end

@implementation CustomTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    [self createTabBar];
    
    [self addChildWithClass:[TestViewController class]
                      title:@"检测"
                      image:[UIImage imageNamed:@"check_normal"]
              selectedImage:[UIImage imageNamed:@"check_selected"]];
    
    [self addChildWithClass:[TestReportViewController class]
                      title:@"报告"
                      image:[UIImage imageNamed:@"report_normal"]
              selectedImage:[UIImage imageNamed:@"report_selected"]];
    
    [self addChildWithClass:[SettingViewController class]
                      title:@"设置"
                      image:[UIImage imageNamed:@"setting_normal"]
              selectedImage:[UIImage imageNamed:@"setting_normal"]];
    
    [NSDC addObserver:self selector:@selector(switchBadge:) name:ChangeTabBarBadge object:nil];
    
    [NSDC addObserver:self selector:@selector(tap) name:RollBack object:nil];
}

#pragma mark - private method

- (void)dealloc {
    [NSDC removeObserver:self];
}

- (void)switchBadge:(NSNotification *)noti {
    BOOL showOrNot = [noti.userInfo[TabBarBadgeIsShow] integerValue];
    NSObject *obj = noti.userInfo[BadgeOfTarget];
    NSInteger idx = [self.childViewControllers indexOfObject:obj];
    [self.tabBar setBadgeOnIdx:idx value:showOrNot];
}
/**
 *  创建tabBar
 */
- (void)createTabBar {
    CustomTabBar *tabBar = [[CustomTabBar alloc]init];
    [self.view addSubview:tabBar];
    tabBar.delegate = self;
    _tabBar = tabBar;
    tabBar.backgroundColor = [UIColor clearColor];
}

#pragma mark - CustomTabBarTabBarDelegate
/**
 *  响应tabBarItem的点击事件
 */
- (void)tabBar:(CustomTabBar *)tabBar clickOnItemAtIdx:(NSInteger)idx preIdx:(NSInteger)preIdx {
    if (preIdx >= 0) {//隐藏之前显示的
        TabBarOffset = 0;
        UIViewController *viewVc = self.childViewControllers[preIdx];
        if (idx != 2) {
            [viewVc.view removeFromSuperview];
            //显示当前需要的
            UIViewController *viewVc = self.childViewControllers[idx];
            [self.view addSubview:viewVc.view];
        }else {
            TabBarOffset = leftViewWidth;
            [self createLeftView];
            [self.view addSubview:self.tempCover];
            self.tempCover.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            
            [UIView animateWithDuration:0.25 animations:^{
                self.tempCover.x = leftViewWidth;
                [self viewWillLayoutSubviews];
            } completion:^(BOOL finished) {
                nil;
            }];
            
            if (!self.tempCover) {
            }else {
            }
        }
    }
}

- (UIView *)tempCover {
    if (!_tempCover) {
        UIView *tempCover = [[UIView alloc] init];
        _tempCover = tempCover;
        _tempCover.backgroundColor = [UIColor blackColor];
        _tempCover.alpha = 0.3;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
        [_tempCover addGestureRecognizer:tap];
    }
    return _tempCover;
}

- (void)tap {
    [UIView animateWithDuration:0.25 animations:^{
        TabBarOffset = 0;
        _leftView.x = -leftViewWidth;
        _tempCover.x = 0;
        [self viewWillLayoutSubviews];
    } completion:^(BOOL finished) {
        [_tempCover removeFromSuperview];
        [_leftView removeFromSuperview];
    }];
}

- (void)createLeftView {
    _leftView = [[AboutAndExit alloc]initWithFrame:CGRectMake(-leftViewWidth, 0, leftViewWidth, kScreenHeight)];
    _leftView.delegate = self;
    [self.view addSubview:_leftView];
    [UIView animateWithDuration:0.25 animations:^{
        _leftView.x = 0;
    } completion:^(BOOL finished) {
        nil;
    }];
}
#pragma mark - 退出授权

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"是"]) {
        
        Author *author = [NSKeyedUnarchiver unarchiveObjectWithFile:authorFile];
        [LoginOrOut logoutWithAuthor:author callBack:^(id responseObj, NSError *error) {
            if ([responseObj[@"message"] isEqualToString:@"successful"]) {
                
                ZJLog(@"注销成功");
                
            }else {
                
                ZJLog(@"注销失败：%@",error);
            }
        }];
        
        [self logout];
    }
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
}

- (void)logout {
    
    //结束其他任务
    [NSDC postNotificationName:GotoDead object:self];
    
    //推出登录界面
    LoginViewController *loginVC = [[LoginViewController alloc]init];
    
    CABasicAnimation *animation = [[CABasicAnimation alloc]init];
    animation.keyPath = @"transform.translation.y";
    animation.fromValue = @(kScreenHeight);
    animation.toValue = @(0);
    
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    
    animation.duration = 0.15;
    
    [loginVC.view.layer addAnimation:animation forKey:@"translation"];
    
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    window.rootViewController = loginVC;
    
    if ([[NSUD objectForKey:ClickSound] isEqual: @1]) {
        [PlayerTool playMusic:@"ButtonClick"];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [loginVC.view.layer removeAnimationForKey:@"translation"];
    });
    
}

- (void)VoicedinLogout {
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"是否确认退出授权?" message:nil delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    self.alertView = alertView;
    [alertView show];
//    [self logout];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {

        self.tabBar.frame = CGRectMake(TabBarOffset, 0, TabBarHOrW, self.view.height);
        for (UIViewController *viewVc in self.childViewControllers) {

            viewVc.view.frame = CGRectMake(TabBarHOrW+TabBarOffset, StatusHeight, self.view.width - TabBarHOrW, self.view.height - StatusHeight);
        }
    }else {
        self.tabBar.frame = CGRectMake(TabBarOffset, self.view.height - TabBarHOrW, self.view.width, TabBarHOrW);
        for (UIViewController *viewVc in self.childViewControllers) {
            viewVc.view.frame = CGRectMake(TabBarOffset, StatusHeight, self.view.width, self.view.height - StatusHeight - TabBarHOrW);
        }
    }
}


#pragma mark - public method

/**
 *  添加子控制器
 */
- (void)addChildWithClass:(Class)Class title:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    UIViewController *instance = [[Class alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:instance];
    nav.navigationBar.backgroundColor = [UIColor clearColor];
    nav.view.backgroundColor = [UIColor clearColor];
    instance.view.backgroundColor = [UIColor clearColor];
    UIImageView *backImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background"]];
    [nav.view insertSubview:backImage atIndex:0];
    [backImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(nav.view);
    }];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"background"] forBarMetrics:UIBarMetricsDefault];
    
    [self addChildViewController:nav];
    if (self.childViewControllers.count == 1) {
        [self.view addSubview:nav.view];
    }
    
    if ([title isEqualToString:@"设置"]) {
        nav.view.hidden = YES;
    }
    [self.tabBar addTabBarItemWithText:title
                                 image:image
                         selectedImage:selectedImage];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end




















