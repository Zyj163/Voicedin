//
//  ViewController.m
//  CustomTabBar
//
//  Created by zhangyongjun on 15/9/19.
//  Copyright (c) SpaceOfViews15年 张永俊. All rights reserved.
//

#import "TestViewController.h"

#import "NoteCollectionViewCell.h"
#import "PersonInfoCollectionViewCell.h"
#import "ExampleCollectionViewCell.h"
#import "TestingCollectionViewCell.h"
#import "DoneCollectionViewCell.h"

#import "CHYPorgressImageView.h"
#import "TestCollectionViewLineLayout.h"
#import "CHYPorgressImageView.h"
#import "NSString+Extension.h"

#import "RecroderManager.h"
#import "PersonTool.h"
#import "Person.h"
#import "Author.h"
#import "TimeOpt.h"

//拼接两张图片的进度UIImageView
@interface DoubleProgressImageView : UIView
/**
 *  上图片
 */
@property (nonatomic, strong) CHYPorgressImageView *upImageView;
/**
 *  下图片
 */
@property (nonatomic, strong) CHYPorgressImageView *downImageView;
/**
 *  设置上下图片
 *
 *  @param upImage   上图片
 *  @param downImage 下图片
 */
- (void)setUpImage:(UIImage *)upImage downImage:(UIImage *)downImage withDisScale:(CGFloat)scale;
/**
 *  按照百分比设置进度
 *
 *  @param pecent 百分比
 */
- (void)setProgressWithPecent:(CGFloat)pecent;
/**
 *  根据部分设置进度
 *
 *  @param number 第几部分
 */
- (void)setProgressWithNumber:(NSUInteger)number;


@end



@interface TestViewController () <TestCenterCollectionViewCellDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>

/**
 *  主视图collectionView
 */
@property (nonatomic, weak) UICollectionView *centerCollectionView;

/**
 *  顶部进度图片（总进度）
 */
@property (strong, nonatomic) DoubleProgressImageView *topView;
/**
 *  底部进度图片（测试进度）
 */
@property (strong, nonatomic) DoubleProgressImageView *bottomView;
/**
 *  关闭按钮
 */
@property (nonatomic, weak) UIButton *closeBtn;

/**
 *  当前显示item的indexPath
 */
@property (strong, nonatomic) NSIndexPath *currentIndexPath;

@property (nonatomic, strong) NSArray *testingPngArr;
@property (nonatomic, assign) NSInteger rowsCount;

@property (nonatomic, strong) Author *author;


@end

@implementation TestViewController

#define kBottomViewH 0.166
#define kTopViewH 0.1387

static NSString *noteCell = @"noteCell";
static NSString *personInfoCell = @"personInfoCell";
static NSString *exampleCell = @"exampleCell";
static NSString *testingCell = @"testingCell";
static NSString *doneCell = @"doneCell";

static void UncaughtExceptionHandler(NSException *exception);
static dispatch_block_t _terminate;

- (NSArray *)testingPngArr {
    if (!_testingPngArr) {
        _testingPngArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testPngs" ofType:@"plist"]];
    }
    return _testingPngArr;
}

/**
 *  懒加载
 *
 *  @return 顶部进度图片视图
 */
- (DoubleProgressImageView *)topView {
    if (!_topView) {
        _topView = [[DoubleProgressImageView alloc]init];
        
        [_topView setUpImage:[UIImage imageNamed:@"topImage"]
                   downImage:[UIImage imageNamed:@"topTitle"] withDisScale:0.2];
        [self.view addSubview:_topView];
        WS(ws);
        [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(ws.view);
            make.height.mas_equalTo(kTopViewH * kScreenHeight);
        }];
    }
    return _topView;
}

/**
 *  懒加载
 *
 *  @return 底部进度图片视图
 */
- (DoubleProgressImageView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[DoubleProgressImageView alloc]init];
        
        [_bottomView setUpImage:[UIImage imageNamed:@"bottomTitle"]
                      downImage:[UIImage imageNamed:@"bottomImage"] withDisScale:5];
        
        [self.view addSubview:_bottomView];
        WS(ws);
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kBottomViewH * kScreenHeight);
            make.bottom.left.right.equalTo(ws.view);
        }];
    }
    return _bottomView;
}

/**
 *  懒加载
 *
 *  @return 获取cell的个数
 */
- (NSInteger)rowsCount {
    if (!_rowsCount) {
        NSArray *pngArrs = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testPngs" ofType:@"plist"]];
        NSInteger count = 0;
        for (NSInteger i = 0; i < pngArrs.count; i ++) {
            NSArray *pngs = pngArrs[i];
            count += pngs.count;
        }
        _rowsCount = count + pngArrs.count + 1 + 1 + 1;
    }
    return _rowsCount;
}

- (void)viewDidLoad {
    
    [NSDC addObserver:self selector:@selector(haveToDead) name:GotoDead object:nil];
    
    _author = [NSKeyedUnarchiver unarchiveObjectWithFile:authorFile];
    
    self.navigationController.navigationBarHidden = YES;
    [self initialViews];
    [super viewDidLoad];
    
    _terminate = ^(){
        [self appWillTerminate];
    };
    
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}

//程序崩溃
void UncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];//得到当前调用栈信息
    NSString *reason = [exception reason];//非常重要，就是崩溃的原因
    NSString *name = [exception name];//异常类型
    
    ZJLog(@"exception type : %@ \n crash reason : %@ \n call stack info : %@", name, reason, arr);
    
    _terminate();
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSInteger con = [[NSUD objectForKey:continueFromTerminate] integerValue];
    if (con == 0) return;
    
    [NSUD setObject:@0 forKey:continueFromTerminate];
    
    NSInteger item = [[NSUD objectForKey:terminatePosition] integerValue];
    if (item < 2) return;
    
    NSArray *pngArrs = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testPngs" ofType:@"plist"]];
    if (item == 2 ||
        item == [self.testingPngArr[0] count] + 2 + 1 ||
        item == [self.testingPngArr[0] count] + 2 + 1 + [self.testingPngArr[1] count] + 1 ||
        item == [self.testingPngArr[0] count] + 2 + 1 + [self.testingPngArr[1] count] + 1 + [self.testingPngArr[2] count] + 1) {
        
        self.currentIndexPath = [NSIndexPath indexPathForItem:item inSection:0];
        [NSUD removeObjectForKey:terminatePosition];
        
    }else {
        NSIndexPath *preIndexPath = [NSIndexPath indexPathForItem:item - 1 inSection:0];
        self.currentIndexPath = preIndexPath;
    }
    
    TestCenterCollectionViewCell *cell = [[TestCenterCollectionViewCell alloc]init];
    
    
    [self initialCell:cell atIndexPath:self.currentIndexPath];
    
    [self.centerCollectionView scrollToItemAtIndexPath:self.currentIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    Person *person = [NSKeyedUnarchiver unarchiveObjectWithFile:personFile];
    
    Author *author = [NSKeyedUnarchiver unarchiveObjectWithFile:authorFile];
    
    if (cell.detailCellType.positionInPart != 0) {
        //重组时间戳文件
        NSMutableDictionary *timeFlag = [NSMutableDictionary dictionaryWithContentsOfFile:timeFlagFile(author.auth_id, person.uuid, person.part, [TimeOpt getGlobalTimeStr])];
        
        NSString *imageName = pngArrs[cell.detailCellType.examplePart][cell.detailCellType.positionInPart - 1];
        
        NSMutableArray *mArr = timeFlag[person.part];
        
        NSDictionary *temDic = nil;
        for (NSDictionary *obj in mArr) {
            if ([[obj allValues] containsObject:imageName]) {
                temDic = obj;
            }
        }
        NSInteger loc = [mArr indexOfObject:temDic];
        [mArr removeObjectsInRange:NSMakeRange(loc, mArr.count - loc)];
        [timeFlag removeObjectForKey:person.part];
        timeFlag[person.part] = mArr;
        [timeFlag writeToFile:timeFlagFile(author.auth_id, person.uuid, person.part, [TimeOpt getGlobalTimeStr]) atomically:YES];
    }
    
    //启动录音
    switch (cell.detailCellType.examplePart) {
        case ExampleViewPartShengmu:
            //启动
            [[RecroderManager getCourseRecorderWithName:shengmuPart] record];
            person.part = shengmuPart;
            [RecroderManager setRecordTimeFlagPart:shengmuPart];
            break;
        case ExampleViewPartYunmu:
            //启动
            [[RecroderManager getCourseRecorderWithName:yunmuPart] record];
            person.part = yunmuPart;
            [RecroderManager setRecordTimeFlagPart:shengmuPart];
            break;
        case ExampleViewPartCizu:
            //启动
            [[RecroderManager getCourseRecorderWithName:cizuPart] record];
            person.part = cizuPart;
            [RecroderManager setRecordTimeFlagPart:cizuPart];
            break;
        case ExampleViewPartDuanyu:
            //启动
            [[RecroderManager getCourseRecorderWithName:duanjuPart] record];
            person.part = duanjuPart;
            [RecroderManager setRecordTimeFlagPart:duanjuPart];
            break;
        default:
            break;
    }
    
    //设置进度条
    [self setProgressWithCell:cell atIndexPath:self.currentIndexPath btn:nil];
    
    [[PersonTool sharedPersonTool] setCurrentPerson:person];
    
}

//程序终止通知
- (void)appWillTerminate {
    
    if (self.currentIndexPath.item < 2) return;
    
    [NSUD setObject:@1 forKey:continueFromTerminate];
    [NSUD removeObjectForKey:terminatePosition];
    [NSUD setObject:@(self.currentIndexPath.item) forKey:terminatePosition];
    [NSKeyedArchiver archiveRootObject:[[PersonTool sharedPersonTool] getCurrentPerson] toFile:personFile];
    [NSUD synchronize];
    
    [RecroderManager stopRecord];
}

//初始化所有视图
- (void)initialViews {
    self.currentIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    //中间视图
    UICollectionView *collectionView = [[UICollectionView alloc]
                                        initWithFrame:CGRectZero
                                        collectionViewLayout:[[TestCollectionViewLineLayout alloc]init]];
    
    [self.view addSubview:collectionView];
    
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollEnabled = NO;
    self.centerCollectionView = collectionView;
    
    [self.centerCollectionView registerClass:[NoteCollectionViewCell class]
                  forCellWithReuseIdentifier:noteCell];
    
    [self.centerCollectionView registerClass:[PersonInfoCollectionViewCell class]
                  forCellWithReuseIdentifier:personInfoCell];
    
    [self.centerCollectionView registerClass:[ExampleCollectionViewCell class]
                  forCellWithReuseIdentifier:exampleCell];
    
    [self.centerCollectionView registerClass:[TestingCollectionViewCell class]
                  forCellWithReuseIdentifier:testingCell];
    
    [self.centerCollectionView registerClass:[DoneCollectionViewCell class]
                  forCellWithReuseIdentifier:doneCell];
    
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kTopViewH * h);
        make.bottom.equalTo(self.view).offset(-kBottomViewH * h);
        make.left.right.equalTo(self.view);
    }];
    
    //设置进度视图的初始值
    [self.topView setProgressWithNumber:1];
    [self.bottomView setProgressWithPecent:0.043];
    
    //关闭按钮
    CGFloat kcloseBtnTop = 0.0397;
    
    UIButton *closeBtn = [[UIButton alloc]init];
    [self.view addSubview:closeBtn];
    self.closeBtn = closeBtn;
    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self
                 action:@selector(clickOnCloseBtn:)
       forControlEvents:UIControlEventTouchUpInside];
    WS(ws);
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ws.view).offset(kcloseBtnTop * h);
        make.right.equalTo(ws.view).offset(- kcloseBtnTop * h);
    }];
}

- (void)clickOnCloseBtn:(UIButton *)btn {
    self.closeBtn = btn;
    if (btn) {
        [PlayerTool playMusic:@"ButtonClick"];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"是否要重新开始？" message:nil delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        [alertView show];
    }else {
        //发送复位通知
        [NSDC postNotificationName:Reset object:nil userInfo:nil];
        
        //移除并销毁所有子视图
        [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _topView = nil;
        _bottomView = nil;
        
        //重新初始化视图
        [self initialViews];
    }
    
    //删除全局时间标记
    if ([NSFM fileExistsAtPath:timeOptFile]) {
        [NSFM removeItemAtPath:timeOptFile error:nil];
    }
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.rowsCount;
}

- (void)initialCell:(TestCenterCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSArray *shengmus = self.testingPngArr[ExampleViewPartShengmu];
    NSArray *yunmus = self.testingPngArr[ExampleViewPartYunmu];
    NSArray *cizus = self.testingPngArr[ExampleViewPartCizu];
    NSArray *duanyus = self.testingPngArr[ExampleViewPartDuanyu];
    
    if (indexPath.item == 0) {//说明页
        cell.detailCellType = DetailCellTypeMake(TestCenterCollectionViewCellTypeStartTest, ExampleViewPartNone, 0);
        self.closeBtn.hidden = YES;
    }
    else if (indexPath.item == 1) {//填充信息页
        cell.detailCellType = DetailCellTypeMake(TestCenterCollectionViewCellTypePersonInfo, ExampleViewPartNone, 0);
        self.closeBtn.hidden = YES;
        
    }
    else if (indexPath.item < shengmus.count + 1 + 2) {//声母 2是前面两页，1是test页中有一页示例页
        cell.detailCellType = DetailCellTypeMake(TestCenterCollectionViewCellTypeTesting, ExampleViewPartShengmu, indexPath.item - 2);
        self.closeBtn.hidden = NO;
        
    }
    else if (indexPath.item < shengmus.count + 2 + 1 + 1 + yunmus.count) {//韵母 2是前面两页，1是test页中有一页示例页 * 2 ,shengmus.count前面声母的页数
        NSInteger count = indexPath.item - shengmus.count - 2 - 1;
        cell.detailCellType = DetailCellTypeMake(TestCenterCollectionViewCellTypeTesting, ExampleViewPartYunmu, count);
        self.closeBtn.hidden = NO;
    }
    else if (indexPath.item < shengmus.count + 2 + 1 + 1 + 1 + yunmus.count + cizus.count) {//词组 2是前面两页，1是test页中有一页示例页 * 3 ,shengmus.count前面声母的页数
        NSInteger count = indexPath.item - shengmus.count - 2 - 1 - yunmus.count - 1;
        cell.detailCellType = DetailCellTypeMake(TestCenterCollectionViewCellTypeTesting, ExampleViewPartCizu, count);
        self.closeBtn.hidden = NO;
    }
    else if (indexPath.item < shengmus.count + 2 + 1 + 1 + 1 + 1 + yunmus.count + cizus.count + duanyus.count) {//同上
        NSInteger count = indexPath.item - shengmus.count - 2 - 1 - cizus.count - 1 - yunmus.count - 1;
        cell.detailCellType = DetailCellTypeMake(TestCenterCollectionViewCellTypeTesting, ExampleViewPartDuanyu, count);
        self.closeBtn.hidden = NO;
    }
    else {//结束页
        cell.detailCellType = DetailCellTypeMake(TestCenterCollectionViewCellTypeDone, ExampleViewPartNone, 0);
    }
    cell.delegate = self;

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TestCenterCollectionViewCell *cell = nil;
    
    //说明页
    if (indexPath.item == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:noteCell forIndexPath:indexPath];
    }
    //填充信息页
    else if (indexPath.item == 1) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:personInfoCell forIndexPath:indexPath];
    }
    //示例页
    else if (indexPath.item == 2 ||
              indexPath.item == [self.testingPngArr[0] count] + 2 + 1 ||
              indexPath.item == [self.testingPngArr[0] count] + 2 + 1 + [self.testingPngArr[1] count] + 1 ||
              indexPath.item == [self.testingPngArr[0] count] + 2 + 1 + [self.testingPngArr[1] count] + 1 + [self.testingPngArr[2] count] + 1) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:exampleCell forIndexPath:indexPath];
    }
    //完成页
    else if (indexPath.item == self.rowsCount - 1) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:doneCell forIndexPath:indexPath];
    }
    //测试页
    else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:testingCell forIndexPath:indexPath];
    }
    
    [self initialCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - cellDelegate
- (void)centerView:(TestCenterCollectionViewCell *)centerView clickOnBottomBtn:(UIButton *)btn {
    
    NSIndexPath *currentIndexPath = [self.centerCollectionView indexPathForCell:centerView];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentIndexPath.item + 1
                                                 inSection:currentIndexPath.section];
    
#warning test
//    if (indexPath.item == 55) {
//        indexPath = [NSIndexPath indexPathForItem:currentIndexPath.item + 200
//                                                     inSection:currentIndexPath.section];
//    }
    
    if (centerView.detailCellType.cellType == TestCenterCollectionViewCellTypeDone) {
        if (btn) {
            [self uploadWithCell:nil];
        }
        [self clickOnCloseBtn:nil];
        return;
        
    }else {
        [self.centerCollectionView scrollToItemAtIndexPath:indexPath
                                          atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                  animated:YES];
        if (indexPath.item == self.rowsCount - 1) {
            self.closeBtn.hidden = YES;
        }
    }
    TestCenterCollectionViewCell *newCell = (TestCenterCollectionViewCell*)[self.centerCollectionView cellForItemAtIndexPath:indexPath];
    [self setProgressWithCell:newCell atIndexPath:indexPath btn:btn];
    self.currentIndexPath = indexPath;
}

//设置进度条
- (void)setProgressWithCell:(TestCenterCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath btn:(UIButton *)btn {
    switch (cell.detailCellType.cellType) {
        case TestCenterCollectionViewCellTypePersonInfo:
        {
            
            [[PersonTool sharedPersonTool] setCurrentPerson:nil];
            
            //启动病人信息阶段录音
            if (btn) {
                [[RecroderManager getCourseRecorderWithName:personInfoPart] record];
                //记录全局时间
                [TimeOpt setGlobalTime:[NSDate date]];
            }
            
            //设置进度条
            [self.topView setProgressWithNumber:2];
            [self.bottomView setProgressWithPecent:0.086];
        }
            break;
        case TestCenterCollectionViewCellTypeTesting:
        {
            if (btn) {
                [self uploadWithCell:cell];
            }
            
            NSArray *shengmus = self.testingPngArr[ExampleViewPartShengmu];
            NSArray *yunmus = self.testingPngArr[ExampleViewPartYunmu];
            NSArray *cizus = self.testingPngArr[ExampleViewPartCizu];
            NSArray *duanyus = self.testingPngArr[ExampleViewPartDuanyu];
            
            [self.topView setProgressWithNumber:3];
            if (indexPath.item == 2) {
                [self.bottomView setProgressWithPecent:0.122];
            }
            else if (indexPath.item < shengmus.count + 1 + 2) {
                
                NSInteger count = indexPath.item - 2;
                [self.bottomView setProgressWithPecent:0.122 + count * (0.29 - 0.122) / shengmus.count];
            }
            else if (indexPath.item == shengmus.count + 1 + 2) {
                [self.bottomView setProgressWithPecent:0.326];
            }
            else if (indexPath.item < shengmus.count + 2 + 1 + 1 + yunmus.count) {
                NSInteger count = indexPath.item - shengmus.count - 2 - 1;
                [self.bottomView setProgressWithPecent:0.326 + count * (0.62 - 0.326) / yunmus.count];
            }
            else if (indexPath.item == shengmus.count + 2 + 1 + 1 + yunmus.count) {
                [self.bottomView setProgressWithPecent:0.652];
            }
            else if (indexPath.item < shengmus.count + 2 + 1 + 1 + 1 + yunmus.count + cizus.count) {
                NSInteger count = indexPath.item - shengmus.count - 2 - yunmus.count - 1 - 1;
                [self.bottomView setProgressWithPecent:0.652 + count * (0.816 - 0.652) / cizus.count];
            }
            else if (indexPath.item == shengmus.count + 2 + 1 + 1 + 1 + yunmus.count + cizus.count) {
                [self.bottomView setProgressWithPecent:0.85];
            }
            else if (indexPath.item < shengmus.count + 2 + 1 + 1 + 1 + 1 + yunmus.count + cizus.count + duanyus.count) {
                NSInteger count = indexPath.item - shengmus.count - cizus.count - yunmus.count - 2 - 1 - 1 - 1;
                [self.bottomView setProgressWithPecent:0.85 + count * (0.956 - 0.85) / duanyus.count];
            }
        }
            break;
        case TestCenterCollectionViewCellTypeDone:
        {
            [self.topView setProgressWithNumber:4];
            [self.bottomView setProgressWithPecent:1.0];
        }
            break;
        default:
            break;
    }

}

- (void)uploadWithCell:(TestCenterCollectionViewCell *)newCell {
    
    Person *person = [[PersonTool sharedPersonTool] getCurrentPerson];
    
    NSString *filePath = RecordFilePath(self.author.auth_id, person.uuid, nil, nil);
    
    if (newCell == nil) {
        [RecroderManager uploadRecorderWithName:duanjuPart success:^(id responseObj) {
            ZJLog(@"%@信息阶段录音上传成功",duanjuPart);
            
            //扫描病人文件夹，无文件则删除该文件夹

            if ([NSFM fileExistsAtPath:filePath]) {
                NSInteger aacSize = [filePath getCachesSize:nil forFileType:@".aac"];
                
                ZJLog(@"aacSize------------%zd",aacSize);
                
                if (aacSize == 0) {
                    NSError *removePathError;
                    
                    [NSFM removeItemAtPath:filePath error:&removePathError];
                    if (removePathError) {
                        ZJLog(@"removePathError-------%@",removePathError);
                    }
                }
            }
            
        } failure:^{
            ZJLog(@"%@信息阶段录音上传失败",duanjuPart);
            
        }];

    }
    else if (newCell.detailCellType.examplePart == ExampleViewPartShengmu
        && newCell.detailCellType.positionInPart == 0) {
        
        //移动文件到对应病人文件夹
        
        NSError *createError;
        NSError *moveError;
        
        [NSFM createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&createError];
        
        if (createError) {
            ZJLog(@"创建病人文件夹错误：%@",createError);
        }
        
        [NSFM moveItemAtPath:RecordFilePath(self.author.auth_id, nil, personInfoPart, @"aac") toPath:RecordFilePath(self.author.auth_id, person.uuid, personInfoPart, @"aac") error:&moveError];
        
        if (moveError) {
            ZJLog(@"移动病人信息阶段录音文件错误：%@",moveError);
        }
        
        person.part = personInfoPart;
        [RecroderManager setRecordTimeFlagPerson:person];
        [RecroderManager setRecordTimeFlagPart:personInfoPart];
        AVAudioRecorder *recorder = [RecroderManager getCourseRecorderWithName:personInfoPart];
        [RecroderManager setRecordWithName:personInfoPart startTime:0];
        [RecroderManager setRecordWithName:personInfoPart endTime:recorder.currentTime];
        
        //上传病人信息阶段录音
        //启动声母阶段录音
        [self uploadRecordName:personInfoPart startRecordName:shengmuPart];
        
    }else if (newCell.detailCellType.examplePart == ExampleViewPartYunmu
              && newCell.detailCellType.positionInPart == 0) {
        
        //上传声母阶段录音
        //启动韵母阶段录音
        [self uploadRecordName:shengmuPart startRecordName:yunmuPart];
        
    }else if (newCell.detailCellType.examplePart == ExampleViewPartCizu
              && newCell.detailCellType.positionInPart == 0) {
        
        //上传韵母阶段录音
        //启动词组阶段录音
        [self uploadRecordName:yunmuPart startRecordName:cizuPart];
        
    }else if (newCell.detailCellType.examplePart == ExampleViewPartDuanyu
              && newCell.detailCellType.positionInPart == 0) {
        
        //上传韵母阶段录音
        //启动短句阶段录音
        [self uploadRecordName:cizuPart startRecordName:duanjuPart];
    }
}

- (void)uploadRecordName:(NSString *)upName startRecordName:(NSString *)StartName {
    
    ZJLog(@"self.currentIndexPath.item------%zd",self.currentIndexPath.item);
    
    //上传
    [RecroderManager uploadRecorderWithName:upName success:^(id responseObj) {
        ZJLog(@"%@信息阶段录音上传成功：%@",upName,responseObj);
    } failure:^{
        ZJLog(@"%@信息阶段录音上传失败",upName);
    }];
    //启动
    
    Person *person = [[PersonTool sharedPersonTool] getCurrentPerson];
    person.part = StartName;
    
    [[RecroderManager getCourseRecorderWithName:StartName] record];
    
    //设置时间戳
    [RecroderManager setRecordTimeFlagPerson:[[PersonTool sharedPersonTool]getCurrentPerson]];
    [RecroderManager setRecordTimeFlagPart:StartName];
}

- (void)restart {
    [self haveToDead];
    
    //重新初始化视图
    [self initialViews];

}

- (void)haveToDead {
    //废弃当前病人的所有录音
    Person *person = [[PersonTool sharedPersonTool] getCurrentPerson];
    [RecroderManager deleteRecordWithName:personInfoPart];
    [RecroderManager deleteRecordsOfPerson:person];
    
    //发送复位通知
    [NSDC postNotificationName:Reset object:nil userInfo:nil];
    
    //移除并销毁所有子视图
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _topView = nil;
    _bottomView = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"是"]) {
        [self restart];
    }else {
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}

@end

@interface DoubleProgressImageView ()

@property (nonatomic, assign) CGFloat upH;
@property (nonatomic, assign) CGFloat downH;
@property (nonatomic, assign) CGFloat W;
@property (nonatomic, assign) CGFloat upD;
@property (nonatomic, assign) CGFloat downD;
@property (nonatomic, assign) CGFloat disScale;

@end

@implementation DoubleProgressImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat upH = _upImageView.image.size.height;
    CGFloat downH = _downImageView.image.size.height;
    if (_upImageView.image.size.width > self.width || _downImageView.image.size.width > self.width) {
        self.W = self.width * 0.6;
        _upImageView.contentMode = UIViewContentModeScaleAspectFit;
        _downImageView.contentMode = UIViewContentModeScaleAspectFit;
    }else {
        self.W = self.width;
        _downImageView.contentMode = UIViewContentModeCenter;
        _upImageView.contentMode = UIViewContentModeCenter;
        self.disScale = 0.2;
    }
    self.upH = self.height * upH / (upH + downH);
    self.downH = self.height * downH / (upH + downH);
    
    self.upD = ABS(self.upH - upH);
    self.downD = ABS(self.downH - downH);
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)updateConstraints {
    if (_upImageView && _downImageView && self.upH && self.downH) {
        WS(ws);
        [_upImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(ws.W));
            make.centerX.equalTo(ws);
            make.top.equalTo(ws.mas_top).offset(ABS(ws.upD * 0.5 - ABS(ws.upD - ws.downD) * ws.disScale));
            make.height.equalTo(@(ws.upH));
        }];
        [_downImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(ws.W));
            make.centerX.equalTo(ws);
            make.bottom.equalTo(ws.mas_bottom).offset(-ABS((ws.downD * 0.5 - ABS(ws.upD - ws.downD) * ws.disScale)));
            make.height.equalTo(@(ws.downH));
        }];
    }
    
    [super updateConstraints];
}

- (CHYPorgressImageView *)upImageView {
    if (!_upImageView) {
        _upImageView = [[CHYPorgressImageView alloc]init];
//        _upImageView.backgroundColor = [UIColor yellowColor];
        [_upImageView sizeToFit];
        [self addSubview:_upImageView];
    }
    return _upImageView;
}

- (CHYPorgressImageView *)downImageView {
    if (!_downImageView) {
        _downImageView = [[CHYPorgressImageView alloc]init];
//        _downImageView.backgroundColor = [UIColor colorWithRed:0.3 green:0.2 blue:0.4 alpha:0.5];
        [_downImageView sizeToFit];
        [self addSubview:_downImageView];
    }
    return _downImageView;
}

- (void)setUpImage:(UIImage *)upImage downImage:(UIImage *)downImage withDisScale:(CGFloat)scale {
    self.disScale = scale;
    if (upImage) {
        self.upImageView.image = upImage;
    }
    if (downImage) {
        self.downImageView.image = downImage;
    }
}

- (void)setProgressWithNumber:(NSUInteger)number {
    if (number > 4) {
        return;
    }
    CGFloat up = 0;
    CGFloat down = 0;
    switch (number) {
        case 0:
            up = 0;
            down = 0;
            break;
        case 1:
            up = 0.3;
            down = 0.2;
            break;
        case 2:
            up = 0.575;
            down = 0.5;
            break;
        case 3:
            up = 0.875;
            down = 0.8;
            break;
        default:
            up = 1;
            down = 1;
            break;
    }
    self.upImageView.progress = up;
    self.downImageView.progress = down;
}

- (void)setProgressWithPecent:(CGFloat)pecent {
    if (pecent < 0 || pecent >1) {
        return;
    }
    CGFloat up = 0;
    CGFloat down = 0;
    
    down = pecent;
    if (pecent >= 0 && pecent <= 0.1) {
        up = 0;
    }
    else if (pecent <= 0.29) {
        up = 0.2;
    }else if (pecent <= 0.625) {
        up = 0.5;
    }else if (pecent <= 0.816) {
        up = 0.7;
    }else if (pecent < 1.0) {
        up = 0.9;
    }else {
        up = 1.0;
    }
    
    self.upImageView.progress = up;
    self.downImageView.progress = down;
}

@end











