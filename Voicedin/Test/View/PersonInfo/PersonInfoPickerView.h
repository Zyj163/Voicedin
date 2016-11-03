//
//  PersonInfoPickerView.h
//  Voicedin
//
//  Created by zhangyj on 15-10-27.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PersonInfoPickerView;

@protocol PersonInfoPickerViewDelegate <NSObject>

- (void)didSelectedStr:(NSString *)str;

@end

@interface PersonInfoPickerView : UIView

@property (nonatomic, weak) id<PersonInfoPickerViewDelegate> delegate;

- (void)setDatas:(NSArray *)datas;
- (void)showWithAnimate:(BOOL)animate;
- (void)hideWithAnimate:(BOOL)animate;

@end
