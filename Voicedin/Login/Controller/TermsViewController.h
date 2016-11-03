//
//  TermsViewController.h
//  Voicedin
//
//  Created by zhangyj on 15-10-23.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TermsViewType) {
    TermsViewTypeServer = 0,
    TermsViewTypePrivacy
};

@interface TermsViewController : UIViewController
@property (nonatomic, assign) TermsViewType type;
@end
