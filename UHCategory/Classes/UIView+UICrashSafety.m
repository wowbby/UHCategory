//
//  UIView+UICrashSafety.m
//  Pods-UHCategory_Tests
//
//  Created by 郑振兴 on 2017/11/8.
//

#import "UIView+UICrashSafety.h"
#import <objc/runtime.h>
@implementation UIView (UICrashSafety)

+(void)load{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[self class]swizzlNeedLayout];
        [[self class]swizzlNeedsDisplay];
        [[self class]swizzlNeedsDisplayInRect];
    });
}

+ (void)swizzlNeedsDisplay {
    SEL originSel = @selector(setNeedsDisplay);
    SEL newSel  = @selector(mc_setNeedsDisplay);
    [self swizzleOriginMethod:originSel withNewMethod:newSel];
}
+ (void)swizzlNeedLayout {
    SEL originSel = @selector(setNeedsLayout);
    SEL newSel  = @selector(mc_setNeedsLayout);
    [self swizzleOriginMethod:originSel withNewMethod:newSel];
}
+ (void)swizzlNeedsDisplayInRect {
    SEL originSel = @selector(setNeedsDisplayInRect:);
    SEL newSel  = @selector(mc_setNeedsDisplayInRect:);
    [self swizzleOriginMethod:originSel withNewMethod:newSel];
}
+ (void)swizzleOriginMethod:(SEL)originMethod withNewMethod:(SEL)newMehtod {
    Method fromMethod = class_getInstanceMethod([self class], originMethod);
    Method toMethod = class_getInstanceMethod([self class], newMehtod);
    if (!class_addMethod([self class], newMehtod, method_getImplementation(toMethod), method_getTypeEncoding(toMethod))) {
        method_exchangeImplementations(fromMethod, toMethod);
    }
}


-(void)mc_setNeedsDisplay {
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
        NSLog(@"MAIN mc_setNeedsDisplay");
        [self mc_setNeedsDisplay];
    }else{
        NSLog(@"THREAD mc_setNeedsDisplay");
        dispatch_async(dispatch_get_main_queue(),^{
            [self mc_setNeedsDisplay];
        });
    }
}

- (void)mc_setNeedsLayout {
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
        NSLog(@"MAIN mc_setNeedsLayout" );
        [self mc_setNeedsLayout];
    }else{
        NSLog(@"THREAD mc_setNeedsLayout");
        dispatch_async(dispatch_get_main_queue(),^{
            [self mc_setNeedsLayout];
        });
    }
}

- (void)mc_setNeedsDisplayInRect:(CGRect)rect {
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
        NSLog(@"MAIN mc_setNeedsDisplayInRect");
        [self mc_setNeedsDisplayInRect:(CGRect)rect];
    }else{
        NSLog(@"THREAD mc_setNeedsDisplayInRect");
        dispatch_async(dispatch_get_main_queue(),^{
            [self mc_setNeedsDisplayInRect:(CGRect)rect];
        });
    }
    
    
}
@end
