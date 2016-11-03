//
//  PersonInfoView.m
//  Voicedin
//
//  Created by zhangyj on 15-9-24.
//  Copyright (c) 2015年 xitong. All rights reserved.
//


#import "PersonInfoView.h"
#import "Person.h"
#import "PersonTool.h"
#import "Author.h"
#import "PersonInfoPickerView.h"
#import "PersonInfoModel.h"

@interface PersonInfoView () <UITextFieldDelegate, PersonInfoPickerViewDelegate>

{
    /**
     *  姓名
     */
    UITextField *_nameTextField;
    /**
     *  性别
     */
    UITextField *_sexTextField;
    /**
     *  职业
     */
    UITextField *_careerTextField;
    /**
     *  病症
     */
    UITextField *_diseaseTextField;
    /**
     *  病症程度
     */
    UITextField *_gradeTextField;
    /**
     *  录音医生
     */
    UITextField *_doctorTextField;
    /**
     *  年龄
     */
    UITextField *_ageTextField;
    /**
     *  籍贯
     */
    UITextField *_provinceTextField;
    /**
     *  文化程度
     */
    UITextField *_educationTextField;
    /**
     *  就诊卡
     */
    UITextField *_kidTextField;
}

@property (nonatomic, weak) UITextField *responder;
@property (nonatomic, strong) PersonInfoPickerView *pickerView;

@property (nonatomic, strong) PersonInfoModel *personInfoModel;



@end

@implementation PersonInfoView
@dynamic delegate;

- (PersonInfoPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[PersonInfoPickerView alloc]init];
        _pickerView.delegate = self;
    }
    return _pickerView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        
        [NSDC addObserver:self
                 selector:@selector(keyboardFrameWillChange:)
                     name:UIKeyboardWillChangeFrameNotification
                   object:nil];
        
        [NSDC addObserver:self
                 selector:@selector(textFieldDidChanged:)
                     name:UITextFieldTextDidChangeNotification
                   object:nil];
    }
    return self;
}

#define redLabelFont 15 * kScreenHeight / 768
#define infoLabelFont 18 * kScreenHeight / 768
- (void)addSubviews {
    
    WS(ws);
    
    static const CGFloat kredLabelLeft = 0.033;
    static const CGFloat kredLabelTop = 0.0176;
    
    
    UILabel *redLabel = [[UILabel alloc]init];
    [self addSubview:redLabel];
    redLabel.text = @"必填项";
    
    [redLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ws.mas_top).offset(kredLabelTop * kScreenHeight);
        make.left.equalTo(ws.mas_left).offset(kredLabelLeft * kScreenWidth);
    }];
    
#define firstRowLabelTop 0.08 * kScreenHeight
    
#define firstRowTextFieldLeft 0.114 * kScreenWidth
#define firstColumTextFieldTop 0.067 * kScreenHeight
#define firstRowTextFieldWidth 0.178 * kScreenWidth
#define twoTextFieldVLineSpace 0.05 * kScreenHeight
#define twoTextFieldHItemSpace 0.123 * kScreenWidth
#define textFieldHeight 0.05 * kScreenHeight
#define textFieldSpaceLabel 0.0123 * kScreenWidth
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.text = @"姓　　名";
    
    //firstRow
    _nameTextField = [[UITextField alloc]init];
    
    _sexTextField = [[UITextField alloc]init];
    _sexTextField.inputView = [[UIView alloc]init];
    _sexTextField.inputView.hidden = YES;
    _sexTextField.inputAccessoryView.hidden = YES;
    
    UILabel *sexLabel = [[UILabel alloc]init];
    sexLabel.text = @"性　　别";
    
    _careerTextField = [[UITextField alloc]init];
    _careerTextField.inputView = [[UIView alloc]init];
    _careerTextField.inputView.hidden = YES;
    _careerTextField.inputAccessoryView.hidden = YES;
    
    UILabel *careerLabel = [[UILabel alloc]init];
    careerLabel.text = @"职　　业";
    
    _diseaseTextField = [[UITextField alloc]init];
    _diseaseTextField.inputView = [[UIView alloc]init];
    _diseaseTextField.inputView.hidden = YES;
    _diseaseTextField.inputAccessoryView.hidden = YES;
    
    UILabel *diseaseLabel = [[UILabel alloc]init];
    diseaseLabel.text = @"病　　症";
    
    _doctorTextField = [[UITextField alloc]init];
    _doctorTextField.inputView = [[UIView alloc]init];
    _doctorTextField.inputView.hidden = YES;
    _doctorTextField.inputAccessoryView.hidden = YES;
    _doctorTextField.userInteractionEnabled = NO;
    Author *author = [NSKeyedUnarchiver unarchiveObjectWithFile:authorFile];
    _doctorTextField.text = author.name;
    
    UILabel *doctorLabel = [[UILabel alloc]init];
    doctorLabel.text = @"录音医生";
    
    //secondRow
    _kidTextField = [[UITextField alloc]init];
    
    UILabel *firstCheckLabel = [[UILabel alloc]init];
    firstCheckLabel.text = @"就诊卡号";

    _ageTextField = [[UITextField alloc]init];
    _ageTextField.inputView = [[UIView alloc]init];
    _ageTextField.inputView.hidden = YES;
    _ageTextField.inputAccessoryView.hidden = YES;
    
    UILabel *ageLabel = [[UILabel alloc]init];
    ageLabel.text = @"年　　龄";
    
    _educationTextField = [[UITextField alloc]init];
    _educationTextField.inputView = [[UIView alloc]init];
    _educationTextField.inputView.hidden = YES;
    _educationTextField.inputAccessoryView.hidden = YES;
    
    UILabel *educationLabel = [[UILabel alloc]init];
    educationLabel.text = @"文化程度";
    
    _gradeTextField = [[UITextField alloc]init];
    _gradeTextField.inputView = [[UIView alloc]init];
    _gradeTextField.inputView.hidden = YES;
    _gradeTextField.inputAccessoryView.hidden = YES;
    
    UILabel *gradeLabel = [[UILabel alloc]init];
    gradeLabel.text = @"病症程度";
    
    //thirdRow
    _provinceTextField = [[UITextField alloc]init];
    _provinceTextField.inputView = [[UIView alloc]init];
    _provinceTextField.inputView.hidden = YES;
    _provinceTextField.inputAccessoryView.hidden = YES;
    
    UILabel *provinceLabel = [[UILabel alloc]init];
    provinceLabel.text = @"籍　　贯";
    
    
    [self addSubview:nameLabel];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ws.mas_top).offset(firstRowLabelTop);
        make.left.equalTo(redLabel.mas_left).offset(1);
    }];
    [self addSubview:_nameTextField];
    
    [_nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameLabel.mas_right).offset(textFieldSpaceLabel);
        make.centerY.equalTo(nameLabel);
        make.width.mas_equalTo(firstRowTextFieldWidth);
    }];
    
    [self addSubview:_kidTextField];
    
    [_kidTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameTextField.mas_right).offset(twoTextFieldHItemSpace);
        make.centerY.equalTo(_nameTextField.mas_centerY);
        make.width.equalTo(_nameTextField.mas_width);
    }];
    
    [self addSubview:firstCheckLabel];
    [firstCheckLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_kidTextField.mas_centerY);
        make.right.equalTo(_kidTextField.mas_left).offset(-textFieldSpaceLabel);
    }];
    [self addSubview:_sexTextField];
    
    [_sexTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameTextField.mas_left);
        make.width.equalTo(_nameTextField.mas_width);
        make.top.equalTo(_nameTextField.mas_bottom).offset(twoTextFieldVLineSpace);
    }];
    [self addSubview:sexLabel];
    
    [sexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_sexTextField.mas_centerY);
        make.left.equalTo(nameLabel.mas_left);
    }];
    [self addSubview:_ageTextField];
    
    [_ageTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_kidTextField.mas_left);
        make.top.equalTo(_sexTextField.mas_top);
        make.width.equalTo(_sexTextField.mas_width).multipliedBy(0.32);
    }];
    [self addSubview:ageLabel];
    [ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_ageTextField.mas_centerY);
        make.right.equalTo(_kidTextField.mas_left).offset(-textFieldSpaceLabel);
    }];
    [self addSubview:_provinceTextField];
    
    [_provinceTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_ageTextField.mas_right).offset(twoTextFieldHItemSpace);
        make.width.equalTo(_sexTextField.mas_width).multipliedBy(0.7);
        make.centerY.equalTo(_ageTextField.mas_centerY);
    }];
    [self addSubview:provinceLabel];
    
    [provinceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_provinceTextField.mas_centerY);
        make.right.equalTo(_provinceTextField.mas_left).offset(-textFieldSpaceLabel);
    }];
    [self addSubview:_careerTextField];
    
    [_careerTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameTextField.mas_left);
        make.width.equalTo(_nameTextField.mas_width);
        make.top.equalTo(_sexTextField.mas_bottom).offset(twoTextFieldVLineSpace);
    }];
    [self addSubview:careerLabel];
    
    [careerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_careerTextField.mas_centerY);
        make.left.equalTo(nameLabel.mas_left);
    }];
    [self addSubview:_educationTextField];
    
    [_educationTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_kidTextField.mas_left);
        make.width.equalTo(_nameTextField.mas_width);
        make.centerY.equalTo(_careerTextField.mas_centerY);
    }];
    [self addSubview:educationLabel];
    
    [educationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_educationTextField.mas_centerY);
        make.right.equalTo(_kidTextField.mas_left).offset(-textFieldSpaceLabel);
    }];
    [self addSubview:_diseaseTextField];
    
    [_diseaseTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameTextField.mas_left);
        make.width.equalTo(_nameTextField.mas_width);
        make.top.equalTo(_careerTextField.mas_bottom).offset(twoTextFieldVLineSpace);
    }];
    [self addSubview:diseaseLabel];
    
    [diseaseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_diseaseTextField.mas_centerY);
        make.left.equalTo(nameLabel.mas_left);
    }];
    [self addSubview:_gradeTextField];
    
    [_gradeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_kidTextField.mas_left);
        make.width.equalTo(_sexTextField.mas_width).multipliedBy(0.6);
        make.centerY.equalTo(_diseaseTextField.mas_centerY);
    }];
    [self addSubview:gradeLabel];
    
    [gradeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_gradeTextField.mas_centerY);
        make.right.equalTo(_kidTextField.mas_left).offset(-textFieldSpaceLabel);
    }];
    [self addSubview:_doctorTextField];
    
    [_doctorTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameTextField.mas_left);
        make.width.equalTo(_nameTextField.mas_width);
        make.top.equalTo(_diseaseTextField.mas_bottom).offset(twoTextFieldVLineSpace);
    }];
    [self addSubview:doctorLabel];
    
    [doctorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_doctorTextField.mas_centerY);
        make.left.equalTo(nameLabel.mas_left);
    }];
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)view;
            [textField setBorderStyle:UITextBorderStyleNone];
            
            textField.background = [[UIImage imageNamed:@"textField"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 5, 5)
                                           resizingMode:UIImageResizingModeStretch];
            
            [textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(textFieldHeight);
            }];
            
            textField.tintColor = [UIColor grayColor];
            textField.textColor = [UIColor blackColor];
            textField.textAlignment = NSTextAlignmentCenter;
            textField.delegate = self;
            textField.returnKeyType = UIReturnKeyNext;
            textField.font = [UIFont systemFontOfSize:infoLabelFont];
        }
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            label.font = [UIFont systemFontOfSize:infoLabelFont];
            label.textColor = ColorFromRGB(0x5c5c5c);
        }
    }
    
    redLabel.font = [UIFont systemFontOfSize:redLabelFont];
    redLabel.textColor = ColorFromRGB(0xff543e);
    
#define spaceToUpTextField 0.05 * kScreenHeight
#define speViewWidth 0.77 * kScreenWidth
    
#define speLeft 0.026 * kScreenWidth
    
    UIView *firstSpeView = [[UIView alloc]init];
    firstSpeView.backgroundColor = ColorFromRGB(0xeaeaea);
    [self addSubview:firstSpeView];
    
    [firstSpeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@1);
        make.top.equalTo(_nameTextField.mas_bottom).offset(twoTextFieldVLineSpace * 0.5);
        make.left.equalTo(@(speLeft));
        make.right.equalTo(@(-speLeft));
    }];
    
    UIView *secSpeView = [[UIView alloc]init];
    secSpeView.backgroundColor = ColorFromRGB(0xeaeaea);
    [self addSubview:secSpeView];
    
    [secSpeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@1);
        make.top.equalTo(_careerTextField.mas_bottom).offset(twoTextFieldVLineSpace * 0.5);
        make.left.equalTo(@(speLeft));
        make.right.equalTo(@(-speLeft));
    }];
    
    UIView *thirdSpeView = [[UIView alloc]init];
    thirdSpeView.backgroundColor = ColorFromRGB(0xeaeaea);
    [self addSubview:thirdSpeView];
    
    [thirdSpeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@1);
        make.top.equalTo(_diseaseTextField.mas_bottom).offset(twoTextFieldVLineSpace * 0.5);
        make.left.equalTo(@(speLeft));
        make.right.equalTo(@(-speLeft));
    }];
}

- (void)didMoveToSuperview {
    Person *person = [NSKeyedUnarchiver unarchiveObjectWithFile:personFile];
    [self getPreTextWithPerson:person];
    [super didMoveToSuperview];
}

- (void)getPreTextWithPerson:(Person *)person {
    _nameTextField.text = person.name;
    _sexTextField.text = person.sex;
    _careerTextField.text = person.career;
    _diseaseTextField.text = person.disease;
    _gradeTextField.text = person.grade;
    _ageTextField.text = person.age;
    _provinceTextField.text = person.province;
    _educationTextField.text = person.education;
    _kidTextField.text = person.kid;
    [self textFieldDidEndEditing:self.responder];
    
}

- (void)clear {
    
    if ([NSFM fileExistsAtPath:personFile]) {
        [NSFM removeItemAtPath:personFile error:nil];
    }
    
    _nameTextField.text = nil;
    _sexTextField.text = nil;
    _careerTextField.text = nil;
    _diseaseTextField.text = nil;
    _gradeTextField.text = nil;
    _ageTextField.text = nil;
    _provinceTextField.text = nil;
    _educationTextField.text = nil;
    _kidTextField.text = nil;
    [self textFieldDidEndEditing:self.responder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

#pragma mark - UITextFieldDelegate && UITextFieldNotification
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *subTextField = (UITextField *)view;
            if (subTextField.text.length == 0) {
                if (_nameTextField.text.length > 0 && _kidTextField.text.length > 0) {
                    [self getPerson];
                    break;
                }
                [subTextField becomeFirstResponder];
                break;
            }
        }
    }
    [self textFieldDidEndEditing:textField];
    return YES;
}

- (void)getPerson {
            
    //发送请求，获取病人信息
    Author *author = [NSKeyedUnarchiver unarchiveObjectWithFile:authorFile];
    [MBProgressHUD showMessage:@"请稍等..." toView:self.superview.superview.superview];
    [[PersonTool sharedPersonTool] judgeNewAddPersonUseName:_nameTextField.text kid:_kidTextField.text andAuthID:author.auth_id WithSuccess:^(NSDictionary *personDic) {
        
        [MBProgressHUD hideHUDForView:self.superview.superview.superview animated:YES];
        
        Person *person = [Person objectWithKeyValues:personDic];
        [self getPreTextWithPerson:person];
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.superview.superview.superview animated:YES];
        if (error) {
            [MBProgressHUD showError:@"获取病人信息失败" toView:self.superview.superview.superview];
            ZJLog(@"获取已有病人信息失败");
        }
        
    }];

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *subTextField = (UITextField *)view;
            if (subTextField.text.length == 0) {
                if ([self.delegate respondsToSelector:@selector(personInfo:finished:withPerson:)]) {
                    [self.delegate personInfo:self finished:NO withPerson:nil];
                }
                return;
            }
        }
    }
    if ([self.delegate respondsToSelector:@selector(personInfo:finished:withPerson:)]) {
        
        Person *person = [[Person alloc]init];
        person.name = _nameTextField.text;
        person.province = _provinceTextField.text;
        person.disease = _diseaseTextField.text;
        person.grade = _gradeTextField.text;
        person.education = _educationTextField.text;
        person.doctor = _doctorTextField.text;
        person.sex = _sexTextField.text;
        person.career = _careerTextField.text;
        person.age = _ageTextField.text;
        person.kid = _kidTextField.text;
        
        [self.delegate personInfo:self finished:YES withPerson:person];
    }
}

- (PersonInfoModel *)personInfoModel {
    if (!_personInfoModel) {
        _personInfoModel = [PersonInfoModel objectWithFilename:@"deadPersonInfo.plist"];
    }
    return _personInfoModel;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.responder = textField;
    __block NSArray *datas = nil;
    if (![textField isEqual:_nameTextField] && ![textField isEqual:_kidTextField]) {
        if ([textField isEqual:_sexTextField]) {
            datas = self.personInfoModel.sex;
            [self.pickerView setDatas:datas];
            [self.pickerView showWithAnimate:YES];
            
        }else if ([textField isEqual:_provinceTextField]) {
            datas = self.personInfoModel.provinces;
            [self.pickerView setDatas:datas];
            [self.pickerView showWithAnimate:YES];
            
        }else if ([textField isEqual:_educationTextField]) {
            datas = self.personInfoModel.educations;
            [self.pickerView setDatas:datas];
            [self.pickerView showWithAnimate:YES];
            
        }else if ([textField isEqual:_careerTextField]) {
            datas = self.personInfoModel.careers;
            [self.pickerView setDatas:datas];
            [self.pickerView showWithAnimate:YES];
            
        }else if ([textField isEqual:_ageTextField]) {
            datas = @[@"年龄"];
            [self.pickerView setDatas:datas];
            [self.pickerView showWithAnimate:YES];
            
        }else if ([textField isEqual:_diseaseTextField]) {
            //联网获取
            [MBProgressHUD showMessage:@"请稍等..." toView:self.superview.superview.superview];
            [[PersonTool sharedPersonTool] getDiseaseWithSuccess:^(NSArray *disease) {
                [MBProgressHUD hideHUDForView:self.superview.superview.superview animated:YES];
                self.personInfoModel.diseases = [DiseaseModel objectArrayWithKeyValuesArray:disease];
                datas = [self.personInfoModel.diseases valueForKeyPath:@"disease"];
                [self.pickerView setDatas:datas];
                [self.pickerView showWithAnimate:YES];
            } failure:^(NSError *error) {
                [MBProgressHUD hideHUDForView:self.superview.superview.superview animated:YES];
                nil;
            }];
        }else if ([textField isEqual:_gradeTextField]) {
            //联网获取
            for (DiseaseModel *diseaseModel in self.personInfoModel.diseases) {
                if ([diseaseModel.disease isEqualToString:_diseaseTextField.text]) {
                    [MBProgressHUD showMessage:@"请稍等..." toView:self.superview.superview.superview];
                    [[PersonTool sharedPersonTool] getGrade:diseaseModel.ID WithSuccess:^(NSArray *grades) {
                        [MBProgressHUD hideHUDForView:self.superview.superview.superview animated:YES];
                        diseaseModel.grades = [GradesModel objectArrayWithKeyValuesArray:grades];
                        datas = [diseaseModel.grades valueForKeyPath:@"rank"];
                        [self.pickerView setDatas:datas];
                        [self.pickerView showWithAnimate:YES];
                    } failure:^(NSError *error) {
                        [MBProgressHUD hideHUDForView:self.superview.superview.superview animated:YES];
                        nil;
                    }];
                    break;
                }
            }
        }
    }else {
        [self.pickerView hideWithAnimate:YES];
    }
    return YES;
}

- (void)textFieldDidChanged:(NSNotification *)noti {
    [self textFieldDidEndEditing:self.responder];
}

#pragma mark - keyboardNotification
- (void)keyboardFrameWillChange:(NSNotification *)noti {
    CGRect currentFrame = [self.responder convertRect:self.responder.bounds
                                               toView:self.window];
    
    CGRect endFrame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (endFrame.origin.y <= CGRectGetMaxY(currentFrame)) {
        CGFloat distance = CGRectGetMaxY(currentFrame) - endFrame.origin.y;
        [self setContentOffset:CGPointMake(0, self.contentOffset.y + distance) animated:YES];
    }
    if (endFrame.origin.y >= self.height) {
        [self setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)didSelectedStr:(NSString *)str {
    if (str.length > 0) {
        self.responder.text = str;
    }
    [self endEditing:YES];
}

- (void)dealloc {
    [NSDC removeObserver:self];
}

@end
