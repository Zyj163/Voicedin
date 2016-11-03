//
//  Const.m
//  Voicedin
//
//  Created by zhangyj on 15-9-22.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "Const.h"

@implementation Const

const CGFloat StatusHeight = 20;
const CGFloat TabBarHOrW = 60;
NSString *const ClickSound = @"clickSound";
NSString *const RollBack = @"rollBack";
NSString *const ChangeTabBarBadge = @"ChangeTabBarBadge";
NSString *const TabBarBadgeIsShow = @"TabBarBadgeIsShow";
NSString *const BadgeOfTarget = @"BadgeOfTarget";
NSString *const Reset = @"reset";
NSString *const UnfinishedCount = @"unfinishedCount";
NSString *const GotoDead = @"GotoDead";

NSString *const uploadPersonInfoUrlStr = @"http://api.fluvoice.com/user/addUser";
NSString *const loginUrlStr = @"http://api.fluvoice.com/login/index";

NSString *const logoutUrlStr = @"http://api.fluvoice.com/login/loginOut";

NSString *const getDiseaseUrlStr = @"http://api.fluvoice.com/disease/disease_list";
NSString *const getGradeUrlStr = @"http://api.fluvoice.com/disease/degree_list";

NSString *const judgeNewPerson = @"http://api.fluvoice.com/user/checkKid";

NSString *const personInfoPart = @"personInfo";
NSString *const shengmuPart = @"shengmu";
NSString *const yunmuPart = @"yunmu";
NSString *const cizuPart = @"cizu";
NSString *const duanjuPart = @"duanju";

@end
