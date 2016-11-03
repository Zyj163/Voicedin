//
//  TabBar.h
//  CustomTabBar
//
//  Created by zhangyongjun on 15/9/19.
//  Copyright (c) 2015年 张永俊. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomTabBar;

@protocol CustomTabBarTabBarDelegate <NSObject>

@optional
- (void)tabBar:(CustomTabBar *)tabBar clickOnItemAtIdx:(NSInteger)idx preIdx:(NSInteger)preIdx;

@end

@interface CustomTabBar : UIView

@property (strong, nonatomic, readonly) NSMutableArray *items;
@property (weak, nonatomic) id<CustomTabBarTabBarDelegate> delegate;

- (void)addTabBarItemWithText:(NSString *)text image:(UIImage *)image selectedImage:(UIImage *)selectedImage;
- (void)setBackGroundImage:(UIImage *)image;
- (void)setBadgeOnIdx:(NSInteger)idx value:(BOOL)showOrNot;

@end
