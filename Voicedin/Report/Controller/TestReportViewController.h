//
//  TestReportViewController.h
//  Voicedin
//
//  Created by 顾雄剑 on 15/10/26.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Author.h"
@class DetailWebView;

@interface TestReportViewController : UIViewController

@property (nonatomic, retain) UIDatePicker *picker;
@property (nonatomic, retain) UIView *pickerView;
@property (nonatomic, retain) UIView *buttonsBack;
@property (nonatomic, retain) UILabel *timeLabel;

@property (nonatomic, retain) UIImageView *noDateImage;
@property (nonatomic, retain) UIWebView *web;
@property (nonatomic, retain) DetailWebView *detailView;

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, retain) UIView *listNav;
@property (nonatomic, retain) UIView *detailNav;
@property (nonatomic, retain) UILabel *navLabel;

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) NSString *pdate;
@property (nonatomic, copy) NSString *detailReportDate;

@end
