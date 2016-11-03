//
//  TermsViewController.m
//  Voicedin
//
//  Created by zhangyj on 15-10-23.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "TermsViewController.h"

@interface TermsViewController () <UIWebViewDelegate>
@property (nonatomic, copy) NSString *urlString;
@end

@implementation TermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setType:(TermsViewType)type {
    _type = type;
    switch (type) {
        case TermsViewTypeServer:
            self.title = @"服务条款";
            self.urlString = SEVICETERM_URL;
            break;
        case TermsViewTypePrivacy:
            self.title = @"隐私条款";
            self.urlString = PRIVATETERM_URL;
            break;
        default:
            break;
    }
    
    UIWebView *webView = [[UIWebView alloc]init];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    [self.view addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"理解并同意条款" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showMessage:@"请稍等..." toView:self.view];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:self.view];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view];
    [MBProgressHUD showError:@"加载失败" toView:self.view];
}


- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
