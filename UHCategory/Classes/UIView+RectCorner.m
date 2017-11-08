//
//  UIView+RectCorner.m
//  Pods-WOWKit_Example
//
//  Created by 郑振兴 on 2017/11/7.
//

#import "UIView+RectCorner.h"

@implementation UIView (RectCorner)
/**
 * setCornerRadius   给view设置圆角
 * @param value      圆角大小
 * @param rectCorner 圆角位置
 **/
- (void)setCornerRadius:(CGFloat)value addRectCorners:(UIRectCorner)rectCorner
{

    [self layoutIfNeeded]; //这句代码很重要，不能忘了

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(value, value)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.path = path.CGPath;
    self.layer.mask = shapeLayer;
}
@end
