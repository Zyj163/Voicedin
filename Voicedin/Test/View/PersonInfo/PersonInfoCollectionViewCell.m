//
//  PersonInfoCollectionViewCell.m
//  Voicedin
//
//  Created by zhangyj on 15-10-28.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "PersonInfoCollectionViewCell.h"
#import "PersonInfoView.h"
#import "PersonTool.h"
#import "Person.h"
#import "Author.h"

@interface PersonInfoCollectionViewCell () <PersonInfoViewDelegate>

@property (nonatomic, strong) Person *currentPerson;

@end

@implementation PersonInfoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createPersonInfoView];
    }
    return self;
}

/**
 *  填写信息视图
 */
- (void)createPersonInfoView {
    [self setBottomDoubleBtn];
    PersonInfoView *personInfoView = [[PersonInfoView alloc]init];
    self.mainview = personInfoView;
    self.bottomBtn.enabled = NO;
    personInfoView.delegate = self;
    [self addSubview:self.mainview];
    
    [super layoutMainView];
}

- (void)setBottomDoubleBtn {
    CGFloat font = 24 * kScreenHeight / 768;
    UIButton *leftBtn = [[UIButton alloc]init];
    [leftBtn setTitle:@"重新填写个人信息" forState:UIControlStateNormal];
    [leftBtn setBackgroundColor:ColorFromRGB(0xe99f00)];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:font];
    
    [self addSubview:leftBtn];
    [leftBtn addTarget:self action:@selector(clearPersonInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"orange-normal"] forState:UIControlStateNormal];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"orange-highlight"] forState:UIControlStateHighlighted];
    
    UIButton *rightBtn = [[UIButton alloc]init];
    rightBtn.enabled = NO;
    self.bottomBtn = rightBtn;
    [rightBtn setTitle:@"下一步" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:font];
    
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"disable"] forState:UIControlStateDisabled];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"green-normal"] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"green-highlight"] forState:UIControlStateHighlighted];
    
    [self addSubview:rightBtn];
    [rightBtn addTarget:self action:@selector(clickOn:) forControlEvents:UIControlEventTouchUpInside];
    WS(ws);
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(ws);
        make.height.equalTo(@(kBottomBtnH * h));
    }];
    
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(ws);
        make.height.equalTo(@(kBottomBtnH * h));
        make.width.equalTo(leftBtn.mas_width);
        make.left.equalTo(leftBtn.mas_right);
    }];
}

/**
 *  底部按钮点击
 */

- (void)clearPersonInfo:(UIButton *)btn {
    [PlayerTool playMusic:@"ButtonClick"];
    PersonInfoView *personInfoView = (PersonInfoView *)self.mainview;
    [personInfoView clear];
}

- (void)clickOn:(UIButton *)btn {
    [PlayerTool playMusic:@"ButtonClick"];
    btn.exclusiveTouch = YES;
    
    Author *author = nil;
    
    author = [NSKeyedUnarchiver unarchiveObjectWithFile:authorFile];
    if (![NSFM fileExistsAtPath:authorFile] || !author) {
        [MBProgressHUD showError:@"授权过期，请重新登录" toView:self.superview.superview];
        return;
    }
    
    //上传病人信息
    [MBProgressHUD showMessage:@"正在设置，请稍等..." toView:self.superview.superview];
    
    [[PersonTool sharedPersonTool] sendPersonInfo:self.currentPerson ofAuthor:author WithSuccess:^(id responseObj){
        
        if ([responseObj[@"message"] isEqualToString:@"successful"]) {
            ZJLog(@"病人信息上传成功,%@",responseObj);
            
            self.currentPerson.uuid = [responseObj[@"data"][@"id"] description];
            [[PersonTool sharedPersonTool] setCurrentPerson:self.currentPerson];
            
            [NSKeyedArchiver archiveRootObject:self.currentPerson toFile:personFile];
            
            [MBProgressHUD hideHUDForView:self.superview.superview animated:YES];
            
            if ([self.delegate respondsToSelector:@selector(centerView:clickOnBottomBtn:)]) {
                //通知代理切换视图
                [self.delegate centerView:self clickOnBottomBtn:btn];
            }
        }else {
            [MBProgressHUD hideHUDForView:self.superview.superview animated:YES];
            [MBProgressHUD showError:@"授权过期，请重新登录" toView:self.superview.superview];
            ZJLog(@"授权过期,%@",responseObj);
        }
        
    } failure:^{
        
        [MBProgressHUD hideHUDForView:self.superview.superview animated:YES];
        [MBProgressHUD showError:@"设置失败，请重试" toView:self.superview.superview];
        
        ZJLog(@"病人信息上传失败");
    }];
    
    [self endEditing:YES];
}


#pragma mark - personInfoDelegate
/**
 *  病人信息填满时和未填满时的处理
 *
 *  @param personInfo    病人信息视图
 *  @param finishedOrNot 是否填满，yes代表填满
 */
- (void)personInfo:(PersonInfoView *)personInfo finished:(BOOL)finishedOrNot withPerson:(Person *)person {
    if (person) {
        self.currentPerson = person;
    }
    self.bottomBtn.enabled = finishedOrNot;
    if (self.bottomBtn.enabled) {
        self.bottomBtn.alpha = 1.0;
    }else {
        self.bottomBtn.alpha = 0.4;
    }
}

@end
