//
//  DiseaseModel.h
//  Voicedin
//
//  Created by zhangyj on 15-10-29.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GradesModel.h"

@interface DiseaseModel : NSObject

@property (nonatomic, strong) NSArray *grades;

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *disease;

@end
