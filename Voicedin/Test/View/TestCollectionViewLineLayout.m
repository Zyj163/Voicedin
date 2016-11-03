//
//  TestCollectionViewLineLayout.m
//  Voicedin
//
//  Created by zhangyj on 15-9-23.
//  Copyright (c) 2015年 xitong. All rights reserved.
//

#import "TestCollectionViewLineLayout.h"

#define kMargin 0.063
#define kSpaceOfViews 0.029

@implementation TestCollectionViewLineLayout

- (void)prepareLayout {
    [super prepareLayout];
    self.minimumLineSpacing = kSpaceOfViews * kScreenWidth;
    CGFloat w = self.collectionView.width - 2 * kMargin * kScreenWidth;
    CGFloat h = self.collectionView.height;
    self.itemSize = CGSizeMake(w, h);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, kMargin * kScreenWidth, 0, kMargin * kScreenWidth);

//    CGFloat marginOfHAndW = ABS(ABS(kScreenHeight - kScreenWidth) - kTabBarHeight);
//    self.sectionInset = UIEdgeInsetsMake(-marginOfHAndW, 0, -marginOfHAndW, 0);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *attrs = [super layoutAttributesForElementsInRect:rect];
    
    CGRect visiableRect;
    visiableRect.origin = self.collectionView.contentOffset;
    visiableRect.size = self.collectionView.frame.size;
    
    CGPoint center;
    center.x = self.collectionView.contentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    //设置透明度
    for (UICollectionViewLayoutAttributes *attr in attrs) {
        if (!CGRectIntersectsRect(rect, visiableRect)) {
            continue;
        }else {
            CGFloat distance = ABS(attr.center.x - center.x);
            CGFloat alphaDistance = attr.frame.size.width + kMargin * kScreenWidth;
            attr.alpha = (1 - distance / alphaDistance) * 3;
        }
    }
    return attrs;
}

@end



















