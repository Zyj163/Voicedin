//
//  LoginViewController.m
//  Voicedin
//
//  Created by zhangyj on 15-9-25.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "LoginViewController.h"
#import "CustomTabBarController.h"
#import "Author.h"
#import "NetworkingManager.h"
#import "TermsViewController.h"
#import "NSString+Extension.h"
#import "LoginOrOut.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, weak) UIView *centerView;
@property (nonatomic, weak) UIButton *loginBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self clearOtherAuthor];
    //设置背景
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"loginBackground"]];
    [self.view addSubview:backgroundImageView];
    [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    //设置导航栏
    [self setNavBar];
    //设置中间登录界面
    [self setLoginView];
    //textField通知
    [self addNotification];
    
}
//textField通知
- (void)addNotification {
    [NSDC addObserver:self
             selector:@selector(textFieldDidChanged:)
                 name:UITextFieldTextDidChangeNotification
               object:self.textField];
    
    [NSDC addObserver:self
             selector:@selector(keyboardFrameChanged:)
                 name:UIKeyboardWillChangeFrameNotification
               object:nil];
    
}


//设置导航栏
- (void)setNavBar {
    CGFloat navBarH = 64;
    CGFloat rightImageRight = 28.5;
    CGFloat font = 17 * kScreenHeight / 768;
    
    UIView *topView = [[UIView alloc]init];
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@(navBarH));
    }];
    topView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    
    UIButton *loginBtn = [[UIButton alloc]init];
    self.loginBtn = loginBtn;
    [topView addSubview:loginBtn];
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(topView).offset(-rightImageRight);
        make.top.equalTo(topView).offset(rightImageRight);
    }];
    [loginBtn setImage:[UIImage imageNamed:@"ok_disable"] forState:UIControlStateDisabled];
    [loginBtn setImage:[UIImage imageNamed:@"ok_enable"] forState:UIControlStateNormal];
    loginBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [loginBtn addTarget:self
                 action:@selector(login:)
       forControlEvents:UIControlEventTouchUpInside];
    
    loginBtn.enabled = NO;
    
    UILabel *title = [[UILabel alloc]init];
    [topView addSubview:title];
    title.text = @"登录";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:font];
    title.textColor = [UIColor whiteColor];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight);
        make.left.right.bottom.equalTo(topView);
    }];
}
//点击登录按钮
- (void)login:(UIButton *)sender {
    [MBProgressHUD showMessage:@"正在验证..." toView:self.view];
    NSString *regist_id = [NSUD objectForKey:registID];
    
    [LoginOrOut loginWithAuth_id:self.textField.text andRegistID:regist_id callBack:^(id responseObj, NSError *error) {
        
        ZJLog(@"login------%@",responseObj);
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (responseObj && ![responseObj[@"message"] isEqualToString:@"successful"]) {
            [MBProgressHUD show:@"授权码输入有误!" icon:@"toast_commen.jpg" view:self.view];
            return ;
        }
        if (error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD show:@"网络未连接!" icon:@"toast_internet.jpg" view:self.view];
            
            ZJLog(@"failure------%@",error);
            return;
        }
        
        Author *author = [Author objectWithKeyValues:responseObj[@"data"]];
        
        //生成授权医生文件夹
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:author.auth_id];
        
        NSError *createError;
        [NSFM createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&createError];
        if (error) {
            ZJLog(@"生成授权文件夹失败：%@",createError);
            return;
        }
        
        [MBProgressHUD showSuccess:@"授权成功" toView:self.view];
        
        //本地记录授权号
        [NSKeyedArchiver archiveRootObject:author toFile:authorFile];
        ZJLog(@"authorFile------%@",authorFile);
        
        //请求成功推出主界面
        CustomTabBarController *ctbc = [[CustomTabBarController alloc]init];
        
        CABasicAnimation *animation = [[CABasicAnimation alloc]init];
        animation.keyPath = @"transform.translation.y";
        animation.fromValue = @(-kScreenHeight);
        animation.toValue = @(0);
        
        animation.removedOnCompletion = YES;
        animation.fillMode = kCAFillModeForwards;
        
        animation.duration = 0.15;
        
        [ctbc.view.layer addAnimation:animation forKey:@"translation"];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        window.rootViewController = ctbc;
        
        if ([[NSUD objectForKey:ClickSound] isEqual: @1]) {
            [PlayerTool playMusic:@"ButtonClick"];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ctbc.view.layer removeAnimationForKey:@"translation"];
        });
        
    }];
    
}
//设置中间登录界面
- (void)setLoginView {
    
    CGFloat kloginViewLeft = 0.292;
    CGFloat kloginViewTop = 0.2357;
    CGFloat kloginViewBottom = 0.267;
    
    UIView *loginView = [[UIView alloc]init];
    self.centerView = loginView;
    [self.view addSubview:loginView];
    loginView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    [loginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(kloginViewLeft * kScreenWidth);
        make.right.equalTo(self.view).offset(-kloginViewLeft * kScreenWidth);
        make.top.equalTo(self.view).offset(kloginViewTop * kScreenHeight);
        make.bottom.equalTo(self.view).offset(-kloginViewBottom * kScreenHeight);
    }];
    
    CGFloat placeFont = 15 * kScreenHeight / 768;
    CGFloat ktextFieldTop = 0.526;
    CGFloat ktextFieldH = 0.0677;
    CGFloat kplaceHeadIndent = 0.009;
    
    UITextField *textField = [[UITextField alloc]init];
    textField.delegate = self;
    self.textField = textField;
    [loginView addSubview:textField];
    textField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    textField.borderStyle = UITextBorderStyleNone;
    NSString *str = @"请输入六位授权码";
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:str
                                                                               attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:placeFont], NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:0.58]}];
    
    textField.attributedPlaceholder = attrStr;
    textField.tintColor = [UIColor whiteColor];
    textField.textColor = [UIColor whiteColor];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(loginView);
        make.top.equalTo(self.view).offset(ktextFieldTop * kScreenHeight);
        make.height.equalTo(@(ktextFieldH * kScreenHeight));
    }];
    
    textField.leftViewMode = UITextFieldViewModeAlways;
    UIView *leftInsetView = [[UIView alloc]init];
    leftInsetView.size = CGSizeMake(kplaceHeadIndent * kScreenWidth, textField.height);
    textField.leftView = leftInsetView;
    
    textField.returnKeyType = UIReturnKeyDone;
    textField.secureTextEntry = NO;
    
    textField.rightViewMode = UITextFieldViewModeAlways;
    UIButton *showBtn = [[UIButton alloc]init];
    
    [showBtn setImage:[UIImage imageNamed:@"show"]
             forState:UIControlStateNormal];
    
    [showBtn setImage:[UIImage imageNamed:@"hide"]
             forState:UIControlStateSelected];
    showBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    showBtn.adjustsImageWhenHighlighted = NO;
    textField.rightView = showBtn;
    showBtn.size = CGSizeMake(showBtn.currentImage.size.width * 1.5, showBtn.currentImage.size.height);
    showBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, showBtn.currentImage.size.width * 0.5);
    
    [showBtn addTarget:self
                action:@selector(clickOnShowBtn:)
      forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat bottomFont = 11 * kScreenHeight / 768;
    CGFloat kbottomLabelTop = 0.677;
    
    UILabel *bottomlabel = [[UILabel alloc]init];
    [loginView addSubview:bottomlabel];
    NSString *labelText = @"完成授权码验证，表示你同意服务条款和隐私条款。";
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]initWithString:labelText];
    
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:bottomFont]
                       range:NSMakeRange(0, labelText.length)];
    
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:ColorFromRGB(0x064a40)
                       range:NSMakeRange(0, labelText.length)];
    

    [attrString addAttribute:NSLinkAttributeName
                       value:@"http://www.baidu.com"
                       range:[labelText rangeOfString:@"服务条款"]];
    
    [attrString addAttribute:NSLinkAttributeName
                       value:@1
                       range:[labelText rangeOfString:@"隐私条款"]];
    
    bottomlabel.attributedText = attrString;
    
    [bottomlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kbottomLabelTop * kScreenHeight);
        make.centerX.equalTo(loginView);
    }];
    
    [bottomlabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickOnSpecialText:)]];
    bottomlabel.userInteractionEnabled = YES;
    
    UIImageView *iconImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"voicedin"]];
    iconImageView.contentMode = UIViewContentModeCenter;
    [loginView addSubview:iconImageView];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(loginView);
        make.top.equalTo(loginView);
        make.bottom.equalTo(self.textField.mas_top);
    }];
}
//显示/隐藏输入文字
- (void)clickOnShowBtn:(UIButton *)btn {
    btn.selected = !btn.selected;
    self.textField.secureTextEntry = !self.textField.secureTextEntry;
}
//点击服务条款/隐私条款
- (void)clickOnSpecialText:(UITapGestureRecognizer *)tap {
    UILabel *label = (UILabel*)tap.view;
    CGPoint location = [tap locationInView:tap.view];
    NSRange seviceRange = [label.text rangeOfString:@"服务条款"];
    NSRange secureRange = [label.text rangeOfString:@"隐私条款"];
    CGRect rect = CGRectZero;
    if (location.x >= seviceRange.location * label.font.pointSize && location.x <= (seviceRange.location + seviceRange.length) * label.font.pointSize) {
        rect = CGRectMake(seviceRange.location * label.font.pointSize, 0, seviceRange.length * label.font.pointSize, label.height);
        ZJLog(@"服务条款");
        [self RangeTurnByType:TermsViewTypeServer];
    }
    else if (location.x >= secureRange.location * label.font.pointSize &&
             location.x <= (secureRange.location + secureRange.length) * label.font.pointSize) {
        rect = CGRectMake(secureRange.location * label.font.pointSize, 0, secureRange.length * label.font.pointSize, label.height);
        ZJLog(@"隐私条款");
        [self RangeTurnByType:TermsViewTypePrivacy];
    }
    else {
        return;
    }
    
    UIView *cover = [[UIView alloc] init];
    cover.backgroundColor = [UIColor greenColor];
    cover.frame = rect;
    cover.layer.cornerRadius = 2;
    cover.layer.masksToBounds = YES;
    [label insertSubview:cover atIndex:0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [cover removeFromSuperview];
    });
}
#pragma mark - 显示条款
- (void)RangeTurnByType:(TermsViewType)type {
    TermsViewController *termsVC = [[TermsViewController alloc]init];
    termsVC.type = type;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:termsVC];
    
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    
    [self presentViewController:nav animated:YES completion:^{
        
        nil;
    }];
}

#pragma mark - UITextFieldDelegate && UITextFieldNotification

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.centerView.layer removeAnimationForKey:@"rotation"];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self textFieldDidEndEditing:textField];
    [self.textField endEditing:YES];
    if (textField.text.length > 0) {
        [self login:self.loginBtn];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.loginBtn.enabled = self.textField.text.length;
}

- (void)textFieldDidChanged:(NSNotification *)noti {
    if (self.textField.text.length > 6) {
        self.textField.text = [self.textField.text substringToIndex:6];
    }
    [self textFieldDidEndEditing:self.textField];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.loginBtn.enabled = self.textField.text.length;
    [self.textField endEditing:YES];
}

- (void)keyboardFrameChanged:(NSNotification *)noti {
    
    
    self.centerView.transform = CGAffineTransformIdentity;
    
    CGRect currentFrame = [self.textField convertRect:self.textField.bounds toView:self.view];
    CGRect endFrame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    if (iOS7) {
        CGFloat x = currentFrame.origin.y;
        CGFloat y = currentFrame.origin.x;
        CGFloat w = currentFrame.size.height;
        CGFloat h = currentFrame.size.width;
        currentFrame = CGRectMake(x, y, w, h);
        
        x = endFrame.origin.y;
        y = endFrame.origin.x;
        w = endFrame.size.height;
        h = endFrame.size.width;
        endFrame = CGRectMake(x, y, w, h);
    }
    
    if (endFrame.origin.y < CGRectGetMaxY(currentFrame)) {
        CGFloat distance = ABS(endFrame.origin.y - CGRectGetMaxY(currentFrame));
        [UIView animateWithDuration:duration animations:^{
            self.centerView.transform = CGAffineTransformMakeTranslation(self.textField.x,-distance);
        }];
    }
    if (endFrame.origin.y >= self.view.height){
        [UIView animateWithDuration:duration animations:^{
            self.centerView.transform = CGAffineTransformIdentity;
        }];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

//为保证推出视图时的动画流畅
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 0;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.alpha = 1;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //抖动动画
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.values = @[@0,@(-M_PI/100),@0,@(M_PI/100),@0];
    animation.repeatCount = 3;
    animation.repeatDuration = 0;
    [self.centerView.layer addAnimation:animation forKey:@"rotation"];
    
}

- (void)clearOtherAuthor {
    
    if ([NSFM fileExistsAtPath:authorFile]) {
        [NSFM removeItemAtPath:authorFile error:nil];
    }
    
    if ([NSFM fileExistsAtPath:personFile]) {
        [NSFM removeItemAtPath:personFile error:nil];
    }
}

- (void)dealloc {
    [self.centerView.layer removeAllAnimations];
    [NSDC removeObserver:self];
}

@end
