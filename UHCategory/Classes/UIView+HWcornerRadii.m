//
//  UIView+HWcornerRadii.m
//  UIDemo
//
//  Created by 郑振兴 on 2017/8/22.
//  Copyright © 2017年 郑振兴. All rights reserved.
//

#import "UIView+HWcornerRadii.h"

@implementation UIView (HWcornerRadii)
- (void)rectCornerWithUIRectCorner:(UIRectCorner)rectCorner cornerSize:(CGSize)size
{

    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:size];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}
@end
