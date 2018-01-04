//
//  UIView+HWcornerRadii.m
//  UIDemo
//
//  Created by 郑振兴 on 2017/8/22.
//  Copyright © 2017年 郑振兴. All rights reserved.
//

#import "UIView+HWcornerRadii.h"
#import <objc/runtime.h>
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
@implementation NSObject (_UHAdd)

+ (void)xw_swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel {
    Method originalMethod = class_getInstanceMethod(self, originalSel);
    Method newMethod = class_getInstanceMethod(self, newSel);
    if (!originalMethod || !newMethod) return;
    method_exchangeImplementations(originalMethod, newMethod);
}

- (void)xw_setAssociateValue:(id)value withKey:(void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)xw_getAssociatedValueForKey:(void *)key {
    return objc_getAssociatedObject(self, key);
}

- (void)xw_removeAssociateWithKey:(void *)key {
    objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_ASSIGN);
}

@end

@implementation UIImage (HWcornerRadii)

+ (UIImage *)xw_imageWithSize:(CGSize)size drawBlock:(void (^)(CGContextRef context))drawBlock {
    if (!drawBlock) return nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return nil;
    drawBlock(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)xw_maskRoundCornerRadiusImageWithColor:(UIColor *)color cornerRadii:(CGSize)cornerRadii size:(CGSize)size corners:(UIRectCorner)corners borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth{
    return [UIImage xw_imageWithSize:size drawBlock:^(CGContextRef  _Nonnull context) {
        CGContextSetLineWidth(context, 0);
        [color set];
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:CGRectInset(rect, -0.3, -0.3)];
        UIBezierPath *roundPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 0.3, 0.3) byRoundingCorners:corners cornerRadii:cornerRadii];
        [rectPath appendPath:roundPath];
        CGContextAddPath(context, rectPath.CGPath);
        CGContextEOFillPath(context);
        if (!borderColor || !borderWidth) return;
        [borderColor set];
        UIBezierPath *borderOutterPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:cornerRadii];
        UIBezierPath *borderInnerPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, borderWidth, borderWidth) byRoundingCorners:corners cornerRadii:cornerRadii];
        [borderOutterPath appendPath:borderInnerPath];
        CGContextAddPath(context, borderOutterPath.CGPath);
        CGContextEOFillPath(context);
    }];
}

@end



static void *const _UHMaskCornerRadiusLayerKey = "_UHMaskCornerRadiusLayerKey";
static NSMutableSet<UIImage *> *maskCornerRaidusImageSet;

@implementation CALayer (HWcornerRadii)

+ (void)load{
    [CALayer uh_swizzleInstanceMethod:@selector(layoutSublayers) with:@selector(_uh_layoutSublayers)];
}

- (UIImage *)contentImage{
    return [UIImage imageWithCGImage:(__bridge CGImageRef)self.contents];
}

- (void)setContentImage:(UIImage *)contentImage{
    self.contents = (__bridge id)contentImage.CGImage;
}

- (void)uh_roundedCornerWithRadius:(CGFloat)radius cornerColor:(UIColor *)color{
    [self uh_roundedCornerWithRadius:radius cornerColor:color corners:UIRectCornerAllCorners];
}

- (void)uh_roundedCornerWithRadius:(CGFloat)radius cornerColor:(UIColor *)color corners:(UIRectCorner)corners{
    [self uh_roundedCornerWithCornerRadii:CGSizeMake(radius, radius) cornerColor:color corners:corners borderColor:nil borderWidth:0];
}

- (void)uh_roundedCornerWithCornerRadii:(CGSize)cornerRadii cornerColor:(UIColor *)color corners:(UIRectCorner)corners borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth{
    if (!color) return;
    CALayer *cornerRadiusLayer = [self uh_getAssociatedValueForKey:_UHMaskCornerRadiusLayerKey];
    if (!cornerRadiusLayer) {
        cornerRadiusLayer = [CALayer new];
        cornerRadiusLayer.opaque = YES;
        [self uh_setAssociateValue:cornerRadiusLayer withKey:_XWMaskCornerRadiusLayerKey];
    }
    if (color) {
        [cornerRadiusLayer uh_setAssociateValue:color withKey:"_uh_cornerRadiusImageColor"];
    }else{
        [cornerRadiusLayer uh_removeAssociateWithKey:"_uh_cornerRadiusImageColor"];
    }
    [cornerRadiusLayer uh_setAssociateValue:[NSValue valueWithCGSize:cornerRadii] withKey:"_uh_cornerRadiusImageRadius"];
    [cornerRadiusLayer uh_setAssociateValue:@(corners) withKey:"_uh_cornerRadiusImageCorners"];
    if (borderColor) {
        [cornerRadiusLayer uh_setAssociateValue:borderColor withKey:"_uh_cornerRadiusImageBorderColor"];
    }else{
        [cornerRadiusLayer uh_removeAssociateWithKey:"_uh_cornerRadiusImageBorderColor"];
    }
    [cornerRadiusLayer uh_setAssociateValue:@(borderWidth) withKey:"_uh_cornerRadiusImageBorderWidth"];
    UIImage *image = [self _uh_getCornerRadiusImageFromSet];
    if (image) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        cornerRadiusLayer.contentImage = image;
        [CATransaction commit];
    }
    
}

- (UIImage *)_uh_getCornerRadiusImageFromSet{
    if (!self.bounds.size.width || !self.bounds.size.height) return nil;
    CALayer *cornerRadiusLayer = [self uh_getAssociatedValueForKey:_UHMaskCornerRadiusLayerKey];
    UIColor *color = [cornerRadiusLayer uh_getAssociatedValueForKey:"_uh_cornerRadiusImageColor"];
    if (!color) return nil;
    CGSize radius = [[cornerRadiusLayer uh_getAssociatedValueForKey:"_uh_cornerRadiusImageRadius"] CGSizeValue];
    NSUInteger corners = [[cornerRadiusLayer uh_getAssociatedValueForKey:"_uh_cornerRadiusImageCorners"] unsignedIntegerValue];
    CGFloat borderWidth = [[cornerRadiusLayer uh_getAssociatedValueForKey:"_uh_cornerRadiusImageBorderWidth"] floatValue];
    UIColor *borderColor = [cornerRadiusLayer uh_getAssociatedValueForKey:"_uh_cornerRadiusImageBorderColor"];
    if (!maskCornerRaidusImageSet) {
        maskCornerRaidusImageSet = [NSMutableSet new];
    }
    __block UIImage *image = nil;
    [maskCornerRaidusImageSet enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, BOOL * _Nonnull stop) {
        CGSize imageSize = [[obj uh_getAssociatedValueForKey:"_uh_cornerRadiusImageSize"] CGSizeValue];
        UIColor *imageColor = [obj uh_getAssociatedValueForKey:"_uh_cornerRadiusImageColor"];
        CGSize imageRadius = [[obj uh_getAssociatedValueForKey:"_uh_cornerRadiusImageRadius"] CGSizeValue];
        NSUInteger imageCorners = [[obj uh_getAssociatedValueForKey:"_uh_cornerRadiusImageCorners"] unsignedIntegerValue];
        CGFloat imageBorderWidth = [[obj uh_getAssociatedValueForKey:"_uh_cornerRadiusImageBorderWidth"] floatValue];
        UIColor *imageBorderColor = [obj uh_getAssociatedValueForKey:"_uh_cornerRadiusImageBorderColor"];
        BOOL isBorderSame = (CGColorEqualToColor(borderColor.CGColor, imageBorderColor.CGColor) && borderWidth == imageBorderWidth) || (!borderColor && !imageBorderColor) || (!borderWidth && !imageBorderWidth);
        BOOL canReuse = CGSizeEqualToSize(self.bounds.size, imageSize) && CGColorEqualToColor(imageColor.CGColor, color.CGColor) && imageCorners == corners && CGSizeEqualToSize(radius, imageRadius) && isBorderSame;
        if (canReuse) {
            image = obj;
            *stop = YES;
        }
    }];
    if (!image) {
        image = [UIImage uh_maskRoundCornerRadiusImageWithColor:color cornerRadii:radius size:self.bounds.size corners:corners borderColor:borderColor borderWidth:borderWidth];
        [image uh_setAssociateValue:[NSValue valueWithCGSize:self.bounds.size] withKey:"_uh_cornerRadiusImageSize"];
        [image uh_setAssociateValue:color withKey:"_uh_cornerRadiusImageColor"];
        [image uh_setAssociateValue:[NSValue valueWithCGSize:radius] withKey:"_uh_cornerRadiusImageRadius"];
        [image uh_setAssociateValue:@(corners) withKey:"_uh_cornerRadiusImageCorners"];
        if (borderColor) {
            [image uh_setAssociateValue:color withKey:"_uh_cornerRadiusImageBorderColor"];
        }
        [image uh_setAssociateValue:@(borderWidth) withKey:"_uh_cornerRadiusImageBorderWidth"];
        [maskCornerRaidusImageSet addObject:image];
    }
    return image;
}

#pragma mark - exchage Methods

- (void)_uh_layoutSublayers{
    [self _uh_layoutSublayers];
    CALayer *cornerRadiusLayer = [self uh_getAssociatedValueForKey:_UHMaskCornerRadiusLayerKey];
    if (cornerRadiusLayer) {
        UIImage *aImage = [self _uh_getCornerRadiusImageFromSet];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        cornerRadiusLayer.contentImage = aImage;
        cornerRadiusLayer.frame = self.bounds;
        [CATransaction commit];
        [self addSublayer:cornerRadiusLayer];
    }
}

@end

@implementation UIView (HWcornerRadii)

- (void)uh_roundedCornerWithRadius:(CGFloat)radius cornerColor:(UIColor *)color{
    [self.layer uh_roundedCornerWithRadius:radius cornerColor:color];
}

- (void)uh_roundedCornerWithRadius:(CGFloat)radius cornerColor:(UIColor *)color corners:(UIRectCorner)corners{
    [self.layer uh_roundedCornerWithRadius:radius cornerColor:color corners:corners];
}

- (void)uh_roundedCornerWithCornerRadii:(CGSize)cornerRadii cornerColor:(UIColor *)color corners:(UIRectCorner)corners borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth{
    [self.layer uh_roundedCornerWithCornerRadii:cornerRadii cornerColor:color corners:corners borderColor:borderColor borderWidth:borderWidth];
}

@end
