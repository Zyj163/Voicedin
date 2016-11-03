//
//  CustomTabBarController
//  CustomTabBarController
//
//  Created by zhangyongjun on 15/9/19.
//  Copyright (c) 2015年 张永俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabBar.h"
#import "AboutAndExit.h"

@interface CustomTabBarController : UIViewController
{
    CGFloat TabBarOffset;
}
- (void)addChildWithClass:(Class)Class title:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage;

@property (weak, nonatomic, readonly) CustomTabBar *tabBar;
@property (nonatomic, readonly) AboutAndExit *leftView;
@property (nonatomic, retain) UIView *tempCover;
@end
