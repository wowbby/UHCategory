//
//  UIView+HWcornerRadii.h
//  UIDemo
//
//  Created by 郑振兴 on 2017/8/22.
//  Copyright © 2017年 郑振兴. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (HWcornerRadii)
/**
 设置一个四角圆角
 @param radius 圆角半径
 @param color  圆角背景色
 */
- (void)uh_roundedCornerWithRadius:(CGFloat)radius cornerColor:(UIColor *)color;

/**
 设置一个普通圆角
 @param radius  圆角半径
 @param color   圆角背景色
 @param corners 圆角位置
 */
- (void)uh_roundedCornerWithRadius:(CGFloat)radius cornerColor:(UIColor *)color corners:(UIRectCorner)corners;

/**
 设置一个带边框的圆角
 @param cornerRadii 圆角半径cornerRadii
 @param color       圆角背景色
 @param corners     圆角位置
 @param borderColor 边框颜色
 @param borderWidth 边框线宽
 */
- (void)uh_roundedCornerWithCornerRadii:(CGSize)cornerRadii cornerColor:(UIColor *)color corners:(UIRectCorner)corners borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;
@end

@interface CALayer (HWcornerRadii)

@property (nonatomic, strong) UIImage *contentImage;//contents的便捷设置

/**如下分别对应UIView的相应API*/

- (void)uh_roundedCornerWithRadius:(CGFloat)radius cornerColor:(UIColor *)color;

- (void)uh_roundedCornerWithRadius:(CGFloat)radius cornerColor:(UIColor *)color corners:(UIRectCorner)corners;

- (void)uh_roundedCornerWithCornerRadii:(CGSize)cornerRadii cornerColor:(UIColor *)color corners:(UIRectCorner)corners borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;

@end
