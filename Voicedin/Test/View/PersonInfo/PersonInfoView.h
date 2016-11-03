//
//  PersonInfoView.h
//  Voicedin
//
//  Created by zhangyj on 15-9-24.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PersonInfoView;
@class Person;

@protocol PersonInfoViewDelegate <UIScrollViewDelegate>

@optional
/**
 *  病人信息填满或者未满
 *
 *  @param personInfo    病人信息视图
 *  @param finishedOrNot 是否填满，yes代表填满
 */
- (void)personInfo:(PersonInfoView *)personInfo finished:(BOOL)finishedOrNot withPerson:(Person *)person;

@end

@interface PersonInfoView : UIScrollView

@property (nonatomic, weak) id<PersonInfoViewDelegate> delegate;

- (void)clear;

@end
