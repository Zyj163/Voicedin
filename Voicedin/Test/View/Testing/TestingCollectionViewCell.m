//
//  TestingCollectionViewCell.m
//  Voicedin
//
//  Created by zhangyj on 15-10-28.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "TestingCollectionViewCell.h"
#import "TestingView.h"
#import "TestingBottomView.h"

@interface TestingCollectionViewCell () <TestingBottomViewDelegate>

/**
 *  测试视图中底部声波视图
 */
@property (nonatomic, weak) TestingBottomView *bottomView;
/**
 * 存放所有图片对应的声音文件的数组
 */
@property (nonatomic, strong) NSArray *testingVoiceArr;
@property (nonatomic, strong) NSArray *testingPngArr;

@end

@implementation TestingCollectionViewCell

/**
 *  懒加载
 *
 *  @return 测试图片名数组
 */
- (NSArray *)testingPngArr {
    if (!_testingPngArr) {
        _testingPngArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testPngs" ofType:@"plist"]];
    }
    return _testingPngArr;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createTestingView];
    }
    return self;
}

//录音视图
- (void)createTestingView {
    [self setBottomBtnWithText:nil image:[UIImage imageNamed:@"record"]];
    TestingView *testingView = [[TestingView alloc]init];
    self.mainview = testingView;
    [self addSubview:self.mainview];
    
    [super layoutMainView];
}

- (void)setDetailCellType:(DetailCellType)detailCellType {
    [super setDetailCellType:detailCellType];
    //取出对应图片名
    TestingView *testingView = (TestingView *)self.mainview;
    testingView.imageName = self.testingPngArr[self.detailCellType.examplePart][self.detailCellType.positionInPart - 1];
}

- (void)setBottomBtnWithText:(NSString *)text image:(UIImage *)image {
    [super setBottomBtnWithText:text image:image];
    
    [self.bottomBtn addTarget:self
                   action:@selector(clickOnImageBtn:)
         forControlEvents:UIControlEventTouchUpInside];
}

/**
 *  点击纯图片按钮，转变为声波视图
 *
 *  @param btn 图片按钮
 */
- (void)clickOnImageBtn:(UIButton *)btn {
    
    [super clickOnImageBtn:btn];
    
    TestingBottomView *view = [[TestingBottomView alloc]init];
    view.delegate = self;
    self.bottomView = view;
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bottomBtn);
    }];
    
    TestingView *testingView = (TestingView *)self.mainview;
    
    //关闭示例声音
    [testingView stopVoice];
    
    //播放按键声音
    
    
    //设置时间戳
    NSString *str = nil;
    if (self.detailCellType.examplePart == ExampleViewPartShengmu) {
        str = @"shengmu";
    }else if (self.detailCellType.examplePart == ExampleViewPartYunmu) {
        str = @"yunmu";
    }else if (self.detailCellType.examplePart == ExampleViewPartCizu) {
        str = @"cizu";
    }else if (self.detailCellType.examplePart == ExampleViewPartDuanyu) {
        str = @"duanju";
    }
    
    [self.bottomView startRecordWave:str waveName:testingView.imageName];
}

#pragma mark - TestingBottomViewDelegate
/**
 *  测试视图点击重新开始
 *
 *  @param view       当前测试视图
 *  @param restartBtn 重新开始的按钮
 */
- (void)TestingBottomView:(TestingBottomView *)view clickOnRestartBtn:(UIButton *)restartBtn {
    
    //恢复播放示例功能
    self.mainview.userInteractionEnabled = YES;
    
    [self.bottomView removeFromSuperview];
    self.bottomView = nil;
    self.bottomBtn.hidden = NO;
}

/**
 *  测试视图点击完成
 *
 *  @param view      当前测试视图
 *  @param finishBtn 完成按钮
 */
- (void)TestingBottomView:(TestingBottomView *)view clickOnFinishBtn:(UIButton *)finishBtn {
    //恢复播放示例功能
    self.mainview.userInteractionEnabled = YES;
    [self.bottomView removeFromSuperview];
    self.bottomView = nil;
    self.bottomBtn.hidden = NO;
    if ([self.delegate respondsToSelector:@selector(centerView:clickOnBottomBtn:)]) {
        //通知代理切换视图
        [self.delegate centerView:self clickOnBottomBtn:finishBtn];
    }
}

@end
