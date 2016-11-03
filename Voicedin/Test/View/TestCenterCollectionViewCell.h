//
//  TestCenterCollectionViewCell.h
//  Voicedin
//
//  Created by zhangyj on 15-9-23.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExampleView.h"

#define kBottomBtnH 0.0716

#define kBottomImageBtnH 0.103

#define h MIN(kScreenWidth, kScreenHeight)

#define w MAX(kScreenHeight, kScreenWidth)
/**
 *  cellType枚举
 */
typedef NS_ENUM(NSInteger, TestCenterCollectionViewCellType){
    /**
     *  开始测试
     */
    TestCenterCollectionViewCellTypeStartTest = 0,
    /**
     *  病人信息
     */
    TestCenterCollectionViewCellTypePersonInfo,
    /**
     *  测试视图
     */
    TestCenterCollectionViewCellTypeTesting,
    /**
     *  完成视图
     */
    TestCenterCollectionViewCellTypeDone,
    /**
     *  没有意义
     */
    TestCenterCollectionViewCellTypeNone
};

/**
 *  DetailCellType结构体
 */
struct DetailCellType {
    TestCenterCollectionViewCellType cellType;
    ExampleViewPart examplePart;
    NSInteger positionInPart;
};

/**
 *  DetailCellType类型声明
 */
typedef struct DetailCellType DetailCellType;

/**
 *  DetailCellType结构体构造函数
 *
 *  @param cellType       视图类型
 *  @param examplePart    示例视图类型
 *  @param positionInPart 测试视图坐标
 *
 *  @return DetailCellType结构体
 */
CG_INLINE DetailCellType
DetailCellTypeMake(TestCenterCollectionViewCellType cellType, ExampleViewPart examplePart, NSInteger positionInPart)
{
    DetailCellType detailCellType;
    detailCellType.cellType = cellType;
    detailCellType.examplePart = examplePart;
    detailCellType.positionInPart = positionInPart;
    return detailCellType;
}

@interface TestCenterCollectionViewCell : UICollectionViewCell
/**
 *  DetailCellType结构体
 */
@property (nonatomic) DetailCellType detailCellType;

@end


@protocol TestCenterCollectionViewCellDelegate <NSObject>

@optional
/**
 *  点击底部按钮
 *
 *  @param centerView cell
 *  @param btn        按钮
 */
- (void)centerView:(TestCenterCollectionViewCell *)centerView clickOnBottomBtn:(UIButton *)btn;

@end

@interface TestCenterCollectionViewCell ()

/**
 *  主视图
 */
@property (nonatomic, weak) UIView *mainview;
/**
 *  底部按钮
 */
@property (nonatomic, weak) UIButton *bottomBtn;

@property (weak, nonatomic) id<TestCenterCollectionViewCellDelegate> delegate;

/**
 *  底部button
 *
 *  @param text  文字
 *  @param image 图片
 */
- (void)setBottomBtnWithText:(NSString *)text image:(UIImage *)image;
- (void)clickOn:(UIButton *)btn;
- (void)clickOnImageBtn:(UIButton *)btn;
- (void)layoutMainView;;

@end
