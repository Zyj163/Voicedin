//
//  TestReportViewController.m
//  Voicedin
//
//  Created by 顾雄剑 on 15/10/26.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "TestReportViewController.h"
#import "NSDate+FormatterDate.h"
#import "APService.h"
#import "DetailWebView.h"

@interface TestReportViewController () <UIWebViewDelegate>

/**
 *  中文星期数组
 */
@property (nonatomic, strong) NSArray *weekdays;
/**
 *  日期选择器视图
 */
@property (nonatomic, weak) UIView *coverView;
@property (nonatomic, weak) UIView *backView;
@property (nonatomic, strong) UIView *pickerBack;

@property (nonatomic, strong) NSArray *urlArray;

@property (nonatomic, copy) NSMutableString *lastDetailUrl1;

@end

@implementation TestReportViewController

- (NSArray *)weekdays {
    if (!_weekdays) {
        _weekdays = @[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"];
    }
    return _weekdays;
}
- (UIView *)pickerView {
    if (!_pickerView) {
        self.pickerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        self.pickerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
        [self.pickerView addGestureRecognizer:tap];
        [self.pickerView addSubview:self.pickerBack];
    }
    return _pickerView;
}
- (UIView *)pickerBack {
    if (!_pickerBack) {
        self.pickerBack = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, datePickerHeight + datePickerTopHeight)];
        self.pickerBack.backgroundColor = [UIColor whiteColor];
        [self.pickerBack addSubview:self.buttonsBack];
        [self.pickerBack addSubview:self.picker];
    }
    return _pickerBack;
}
- (UIDatePicker *)picker {
    if (!_picker) {
        self.picker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, datePickerTopHeight, kScreenWidth, datePickerHeight)];
        
        self.picker.datePickerMode = UIDatePickerModeDate;
    }
    return _picker;
}
- (UIView *)buttonsBack {
    if (!_buttonsBack) {
        self.buttonsBack = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, datePickerTopHeight)];
        
        self.buttonsBack.backgroundColor = Color(249, 249, 249);
        
        UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 0, 100, datePickerTopHeight)];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [cancelButton setTitleColor:Color(0, 113, 255) forState:UIControlStateNormal];
        [cancelButton addTarget:self  action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonsBack addSubview:cancelButton];
        
        UIButton *comfirmButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth - 175, 0, 100, datePickerTopHeight)];
        [comfirmButton setTitle:@"确定" forState:UIControlStateNormal];
        comfirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        comfirmButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [comfirmButton setTitleColor:Color(0, 113, 255) forState:UIControlStateNormal];
        [comfirmButton addTarget: self action:@selector(comfirm) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonsBack addSubview:comfirmButton];
    }
    return _buttonsBack;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (!self.listNav) {
        self.listNav = [self ListReportNav];
    }
    if (!self.detailNav) {
        self.detailNav = [self DetailReportNav];
    }
    self.listNav.hidden = NO;
    self.detailNav.hidden = YES;
    Author *author = [NSKeyedUnarchiver unarchiveObjectWithFile:authorFile];
    self.uuid = author.auth_id;
    [self createWebView];
    
    [NSDC addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NSDC postNotificationName:ChangeTabBarBadge
                        object:self
                      userInfo:@{TabBarBadgeIsShow : @0,
                                 BadgeOfTarget : self.navigationController}];
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    
    NSDictionary *message = [notification userInfo];
    NSMutableDictionary *receiveDic = [[NSMutableDictionary alloc] initWithCapacity:4];
    NSString *title = [message valueForKey:@"title"];
    NSString *content = [message valueForKey:@"content"];
    NSDictionary *extrasDic = [message valueForKey:@"extras"];
    
    [receiveDic setValue:title forKey:@"title"];
    [receiveDic setValue:content forKey:@"message"];
    [receiveDic setValue:extrasDic forKey:@"extras"];
    
    NSLog(@"%@",[receiveDic description]);
    
    [NSDC postNotificationName:ChangeTabBarBadge
                        object:self
                      userInfo:@{TabBarBadgeIsShow : @1,
                                 BadgeOfTarget : self.navigationController}];
}

- (void)createWebView {
    if (!self.web) {
        self.web = [[UIWebView alloc]initWithFrame:CGRectMake(0.5, reportTopViewHeight, kScreenWidth, kScreenHeight-reportTopViewHeight)];
        [self.web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.fluvoice.com/report_list/report_list?auth_id=%@&date=%@", self.uuid, [self dateToString:[NSDate date]]]]]];
        [self.web sizeToFit];
        self.web.delegate = self;
        [self.view addSubview:self.web];
    }
}
- (void)webViewReloadRequest:(NSString *)urlString {
    [self.web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}
#pragma mark - 显示日期到时间label
- (void)resetNavbarWithDate:(NSDate *)date {
    NSMutableArray *arr = [self stringFromDate:date];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ %@", arr[0], arr[1]];
}
#pragma mark - 设置日期格式为.
- (NSMutableArray *)stringFromDate:(NSDate *)date {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *com = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitYear fromDate:date];
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    NSString *str = [[NSString alloc]init];
    str = [NSString stringWithFormat:@"%ld.%02ld.%02ld",(long)com.year, (long)com.month, (long)com.day];
    [arr addObject:str];
    NSString *weekday = [NSString stringWithFormat:@"%@", [self.weekdays objectAtIndex:com.weekday - 1]];
    [arr addObject:weekday];
    return arr;
}
#pragma mark - 展示日期选择器
- (void)datePicker {
    [self.view addSubview:self.pickerView];
    
    [UIView animateWithDuration:.5 animations:^{
        self.pickerBack.frame = CGRectMake(0, kScreenHeight - datePickerHeight - datePickerTopHeight, kScreenWidth, datePickerHeight + datePickerTopHeight);
    } completion:^(BOOL finished) {
        
    }];
    
    self.picker.maximumDate = [NSDate date];
    self.picker.minimumDate = [self OneMonthBefore];
    
    self.pickerBack.hidden = NO;
}

#pragma mark - 当前时间一个月前的日期
- (NSDate *)OneMonthBefore {
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *com = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitYear fromDate:now];
    NSInteger year = (long)com.year;
    NSInteger month = (long)com.month;
    NSInteger day = (long)com.day;
    if (month == 1) {
        if (day == 31) {
            day = 1;
        }else if (day == 31) {
            year --;
            month = 12;
        }else {
            year --;
            month = 12;
            day ++;
        }
    }else if (month == 3) {
        if (day > 28) {
            day = 1;
        }else {
            month --;
            day ++;
        }
    }else if (month == 5 || month == 7 || month == 10 || month == 12) {
        if (day > 29) {
            day = 1;
        }else {
            day ++;
            month --;
        }
    }else if (month == 8) {
        if (day > 30) {
            day = 1;
        }
    }else {
        day ++;
        month --;
    }
    NSString *past = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)year, (long)month, (long)day];
    return [NSDate dateFromFormatter:@"yyyy-MM-dd" WithDateStr:past];
}

- (void)tap {
    [self cancel];
}
#pragma mark - 时间转换格式
- (NSString *)dateToString:(NSDate *)date {
    return [date convertdateToFormatter:@"yyyy-MM-dd"];
}
#pragma mark - 获取webview上面的点击事件
- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    if ([[NSString stringWithFormat:@"%@", url] rangeOfString:@"report_view"].location != NSNotFound) {
        if ([self.lastDetailUrl1 isEqualToString:[NSString stringWithFormat:@"%@", url]]) {
            [self.view addSubview:self.detailView];
        }else {
            self.lastDetailUrl1 = [NSMutableString stringWithFormat:@"%@", url];
            self.navLabel.text = [NSString stringWithFormat:@"检测报告 %@", [self detailReportDateString:url]];
            [self.view addSubview:self.detailView];
            [self.detailView.wv loadRequest:[NSURLRequest requestWithURL:url]];
        }
        self.listNav.hidden = YES;
        self.detailNav.hidden = NO;
        return NO;
    }
    return YES;
}

- (DetailWebView *)detailView {
    if (!_detailView) {
        _detailView = [[DetailWebView alloc]init];
        _detailView.frame = CGRectMake(0.5, reportTopViewHeight, kScreenWidth, kScreenHeight - reportTopViewHeight);
    }
    return _detailView;
}

- (NSString *)detailReportDateString:(NSURL *)url {
    NSString *urlString = (NSString*)url;
    NSString *str = [NSString stringWithFormat:@"%@", urlString];
    NSArray *arr = [str componentsSeparatedByString:@"date="];
    NSString *string = [arr[1] stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    return string;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('html')[0].outerHTML;"];
    if ([html rangeOfString:@":2004"].location != NSNotFound) {
        self.web.hidden = YES;
        [self createNoDateImage];
        self.noDateImage.hidden = NO;
    }else {
        self.web.hidden = NO;
        self.noDateImage.hidden = YES;
    }
}
#pragma mark - 无报告数据情况
- (void)createNoDateImage {
    if (!self.noDateImage) {
        self.noDateImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, reportTopViewHeight, kScreenWidth, kScreenHeight - reportTopViewHeight)];
        [self.noDateImage setImage:[UIImage imageNamed:@"copy2"]];
        self.noDateImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:self.noDateImage];
    }
}
- (void)setListNav:(UIView *)listNav {
    _listNav = listNav;
}
- (UIView *)ListReportNav {
    UIView *nav = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, reportTopViewHeight)];
    [self.view addSubview:nav];
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(1, 0, 280, reportTopViewHeight)];
    [nav addSubview:topView];
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 150, reportTopViewHeight)];
    self.timeLabel.font = [UIFont systemFontOfSize:18];
    [topView addSubview:self.timeLabel];
    [self resetNavbarWithDate:[NSDate date]];
    
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(280-1, 0, 0.3, reportTopViewHeight)];
    line.backgroundColor = [UIColor grayColor];
    [topView addSubview:line];
    
    UIButton *anButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth * 0.2837 - 50, 0, 40, reportTopViewHeight)];
    [anButton setImage:[UIImage imageNamed:@"downPull"] forState:UIControlStateNormal];
    anButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [anButton addTarget:self action:@selector(datePicker) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:anButton];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(280, 0, kScreenWidth * (1-0.2837), reportTopViewHeight)];
    titleLabel.text = @"检测报告";
    titleLabel.font = [UIFont fontWithName:@"arial" size:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [nav addSubview:titleLabel];
    
    UIControl *tapControl = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth * 0.2837, reportTopViewHeight)];
    [tapControl addTarget:self action:@selector(datePicker) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:tapControl];
    
    return nav;
}
- (UIView *)DetailReportNav {
    UIView *nav = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, reportTopViewHeight)];
    [self.view addSubview:nav];
    self.navLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, reportTopViewHeight)];
    self.navLabel.textAlignment = NSTextAlignmentCenter;
    self.navLabel.text = [NSString stringWithFormat:@"%@", [self dateToString:[NSDate date]]];
    self.navLabel.font = [UIFont systemFontOfSize:18];
    [nav addSubview:self.navLabel];
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 2, reportTopViewHeight, reportTopViewHeight - 2)];
    [backButton setImage:[UIImage imageNamed:@"arrow_left"] forState:UIControlStateNormal];
    backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [nav addSubview:backButton];
    
    return nav;
}
- (void)backClick {
    self.detailNav.hidden = YES;
    self.listNav.hidden = NO;
    [self.detailView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [self.detailView.wv stopLoading];
    
    // Dispose of any resources that can be recreated.
}
#pragma mark - 取消选择时间
- (void)cancel {
    [UIView animateWithDuration:.5 animations:^{
        _pickerBack.frame = CGRectMake(0, kScreenHeight, kScreenWidth, datePickerHeight + datePickerTopHeight);
    } completion:^(BOOL finished) {
        [self.pickerView removeFromSuperview];
        [self.pickerBack.layer removeAnimationForKey:@"transform"];
    }];
}
- (void)comfirm {
    [self resetNavbarWithDate:self.picker.date];
    self.urlString = REPORT_LIST_URL;
    self.pdate = [self dateToString:self.picker.date];
    [self webViewReloadRequest:[NSString stringWithFormat:@"http://api.fluvoice.com/report_list/report_list?auth_id=%@&date=%@", self.uuid, self.pdate]];
    [self cancel];
    if ([[NSUD objectForKey:ClickSound] isEqual: @1]) {
        [PlayerTool playMusic:@"ButtonClick"];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
