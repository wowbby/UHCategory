//
//  UIView+RectCorner.h
//  Pods-WOWKit_Example
//
//  Created by 郑振兴 on 2017/11/7.
//

#import <UIKit/UIKit.h>

@interface UIView (RectCorner)
/**
 * setCornerRadius   给view设置圆角
 * @param value      圆角大小
 * @param rectCorner 圆角位置
 **/
- (void)setCornerRadius:(CGFloat)value addRectCorners:(UIRectCorner)rectCorner;
@end
