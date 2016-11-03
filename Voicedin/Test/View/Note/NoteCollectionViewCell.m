//
//  NoteCollectionViewCell.m
//  Voicedin
//
//  Created by zhangyj on 15-10-28.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "NoteCollectionViewCell.h"

@implementation NoteCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createStartTestView];
    }
    return self;
}

- (void)setBottomBtnWithText:(NSString *)text image:(UIImage *)image {
    [super setBottomBtnWithText:text image:image];
}

/**
 *  开始测试视图
 */
- (void)createStartTestView {
    
    [self setBottomBtnWithText:@"开始检测" image:nil];
    
    CGFloat kinset = 0.026;
    
    CGFloat ktopInset = 0.049;
    
    
    CGFloat titleFont = 21 * kScreenHeight / 768;
    CGFloat textFont = 17 * kScreenHeight / 768;
    CGFloat klinespace = 0.026;
    CGFloat ktitleSpaceText = 0.0234;
    
    UILabel *label = [[UILabel alloc]init];
    label.numberOfLines = 0;
    
    NSString *str = @"测试说明：\n1.录音过程大约需要15分钟左右，包括音节、词、短句三部分内容。\n2.录音过程比较简单，请在测试过程中尽量放松。\n3.患者若无法识别文本内容，请提前告知医护人员。医护人员将会逐条播放测试内容供患者模仿。\n4.患者若需要借助辅助工具才能识别文本内容，请提前自行准备好相关工具。\n注意事项：\n1.录音过程中请尽量保持安静，避免不必要的声音。\n2.录音过程需要安静的环境，因此无法开窗、运行空调、电风扇等，敬请谅解。\n3.录音过程中若感觉疲惫或身体不适，请向医护人员示意。休息调整后若仍无法完成录音，医护人员将另行安排时间。";
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:str];
    
    NSRange firstTitleRange = [str rangeOfString:@"测试说明：\n"];
    NSRange secTitleRange = [str rangeOfString:@"注意事项：\n"];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    [style setMaximumLineHeight:titleFont];
    [style setLineSpacing:ktitleSpaceText * h];
    
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:titleFont]
                    range:firstTitleRange];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:ColorFromRGB(0x029dff)
                    range:firstTitleRange];
    
    [attrStr addAttribute:NSParagraphStyleAttributeName
                    value:style
                    range:firstTitleRange];
    
    [style setParagraphSpacingBefore:(ktopInset - klinespace) * h];
    
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:titleFont]
                    range:secTitleRange];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:ColorFromRGB(0x029dff)
                    range:secTitleRange];
    
    [attrStr addAttribute:NSParagraphStyleAttributeName
                    value:style
                    range:secTitleRange];
    
    
    NSRange firstTextRange = NSMakeRange(firstTitleRange.length, secTitleRange.location - firstTitleRange.length);
    NSRange secTextRange = NSMakeRange(secTitleRange.length + secTitleRange.location, str.length - secTitleRange.length - secTitleRange.location);
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc]init];
    [textStyle setMaximumLineHeight:textFont];
    [textStyle setLineSpacing:klinespace * h];
    
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:textFont]
                    range:firstTextRange];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:ColorFromRGB(0x5c5c5c)
                    range:firstTextRange];
    
    [attrStr addAttribute:NSParagraphStyleAttributeName
                    value:textStyle
                    range:firstTextRange];
    
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:textFont]
                    range:secTextRange];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:ColorFromRGB(0x5c5c5c)
                    range:secTextRange];
    
    [attrStr addAttribute:NSParagraphStyleAttributeName
                    value:textStyle
                    range:secTextRange];
    
    label.attributedText = attrStr;
    self.mainview = label;
    [self addSubview:self.mainview];
    WS(ws);
    [self.mainview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ws).offset(ktopInset * h);
        make.right.equalTo(ws).offset(-kinset * w);
        make.left.equalTo(ws).offset(kinset * w);
    }];
}

- (void)clickOn:(UIButton *)btn {
    [super clickOn:btn];
}


@end
