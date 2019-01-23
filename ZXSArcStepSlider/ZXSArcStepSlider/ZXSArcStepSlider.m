//
//  ZXSArcStepSlider.m
//  ZXSArcStepSlider
//
//  Created by bi xu on 2019/1/7.
//  Copyright © 2019 Cammus. All rights reserved.
//

#import "ZXSArcStepSlider.h"

// 极坐标
typedef struct {
    CGFloat radius;
    CGFloat angle;
} ZXSPolarCoordinate;

@interface ZXSArcStepSlider ()

@property (nonatomic, assign) CGFloat startAngle;// 开始弧度
@property (nonatomic, assign) CGFloat endAngle;// 结束弧度
@property (nonatomic, assign) CGFloat circleRadius;// 圆半径
@property (nonatomic, assign) CGPoint circleCenter;// 圆心
@property (nonatomic, assign) CGPoint thumbCenter;// 滑块中心点
@property (nonatomic, assign) CGFloat value;// 当前值
@property (nonatomic, assign) BOOL enableExternalGestureRecognizers;// 是否启用外界手势（外界手势会影响滑块滑动）

@end


@implementation ZXSArcStepSlider

#pragma mark - 系统

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.borderWidth = frame.size.width * 0.025;
        self.unfillColor = [UIColor whiteColor];
        self.fillColor = [UIColor orangeColor];
        self.stepRadius = self.borderWidth;
        self.stepCount = 10;
        self.thumbRadius = self.stepRadius * 1.5;
        self.thumbColor = self.fillColor;
        self.minValue = 0.0;
        self.maxValue = 9.0;
        self.value = 0.0;
        self.index = 0;
        self.startAngle = M_PI_4 * 3;
        self.endAngle = M_PI_4 + M_PI * 2;
        CGFloat halfSliderWidth = frame.size.width * 0.5;
        self.circleRadius = halfSliderWidth - self.thumbRadius - 10;
        self.circleCenter = CGPointMake(halfSliderWidth, halfSliderWidth);
        _enableExternalGestureRecognizers = YES;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    // 值偏移量
    CGFloat valueWidth = self.maxValue - self.minValue;
    CGFloat angleWidth = self.endAngle - self.startAngle;
    CGFloat currentAngle = ((self.value - self.minValue) / valueWidth) * angleWidth + self.startAngle;
    CGPoint thumbCenter = polarCoordinateToPoint(self.circleCenter, self.circleRadius, currentAngle);
    /*
     1.获取图形上下文
     2.绘图
     2.1画图
     2.2设置参数(颜色、线宽、线段样式等)
     3.渲染
     */
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 1.背景圆弧
    CGContextAddArc(ctx, self.circleCenter.x, self.circleCenter.y, self.circleRadius, self.startAngle, self.endAngle, 0);
    CGContextSetLineWidth(ctx, self.borderWidth);
    [self.unfillColor setStroke];
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextStrokePath(ctx);
    
    // 2.填充圆弧
    CGContextAddArc(ctx, self.circleCenter.x, self.circleCenter.y, self.circleRadius, self.startAngle, currentAngle, 0);
    [self.fillColor setStroke];
    CGContextStrokePath(ctx);
    
    // 3.节点
    NSInteger stepCount = self.stepCount;
    for (NSInteger i = 0; i < stepCount; i++) {
        CGFloat stepAngle = ((i - self.minValue) / valueWidth) * angleWidth + self.startAngle;
        CGPoint stepCenter = polarCoordinateToPoint(self.circleCenter, self.circleRadius, stepAngle);
        CGContextAddArc(ctx, stepCenter.x, stepCenter.y, self.stepRadius, 0.0, M_PI * 2, 0);
        UIColor *stepColor = stepAngle < currentAngle ? self.fillColor : self.unfillColor;
        [stepColor setFill];
        CGContextFillPath(ctx);
    }
    
    // 4.滑轮
    CGContextAddArc(ctx, thumbCenter.x, thumbCenter.y, self.thumbRadius, 0.0, M_PI * 2, 0);
    [self.thumbColor setFill];
    CGContextFillPath(ctx);
}


#pragma mark - UIControl事件

// 点击开始追踪
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    NSLog(@"beginTrackingWithTouch");
    // 当触点在滑块或者圆弧上可以开始跟踪
    CGPoint touchPoint = [touch locationInView:self];
    return [self isTrackingWithPoint:touchPoint];
}

// 追踪过程中
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    NSLog(@"continueTrackingWithTouch");
    // 当触点在滑块或者圆弧上可以继续跟踪
    CGPoint touchPoint = [touch locationInView:self];
    BOOL isTure = [self isTrackingWithPoint:touchPoint];
    if (isTure) {
        // 圆弧上
        ZXSPolarCoordinate polarCoordinate = pointToPolarCoordinate(self.circleCenter, touchPoint);
        double angleOffset = (polarCoordinate.angle < self.startAngle) ? (polarCoordinate.angle + 2 * M_PI - self.startAngle) : (polarCoordinate.angle - self.startAngle);
        double newValue = (angleOffset / (self.endAngle - self.startAngle)) * (self.maxValue - self.minValue) + self.minValue;
        NSLog(@"newValue = %f",newValue);
        
        // 过滤追踪到0节点附近时出现设置最大值bug
        newValue = MIN(MAX(newValue, self.minValue), self.maxValue);
        isTure = newValue == self.maxValue && touchPoint.x < self.frame.size.width * 0.5;
        if (isTure) {
            NSLog(@"追踪到0节点附近时出现设置最大值bug");
            self.value = self.minValue;
            [self endTrackingWithTouch:touch withEvent:event];
            return NO;
            
        } else {
            NSLog(@"圆弧上");
            self.value = newValue;
            return YES;
        }
        
    } else {
        // 圆弧外
        NSLog(@"圆弧外");
        [self endTrackingWithTouch:touch withEvent:event];
        return NO;
    }
}

// 追踪结束
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    NSLog(@"endTrackingWithTouch");
    [self endTouch];
}

// 取消追踪
- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
    NSLog(@"cancelTrackingWithEvent");
    [self endTouch];
}


#pragma mark - 自定义

- (void)setBorderWidth:(CGFloat)borderWidth {
    if (_borderWidth != borderWidth) {
        _borderWidth = borderWidth;
        self.stepRadius = _borderWidth;
    }
}

- (void)setUnfillColor:(UIColor *)unfillColor {
    if (_unfillColor != unfillColor) {
        _unfillColor = unfillColor;
        [self setNeedsDisplay];
    }
}

- (void)setFillColor:(UIColor *)fillColor {
    if (_fillColor != fillColor) {
        _fillColor = fillColor;
        [self setNeedsDisplay];
    }
}

- (void)setThumbColor:(UIColor *)thumbColor {
    if (_thumbColor != thumbColor) {
        _thumbColor = thumbColor;
        [self setNeedsDisplay];
    }
}

- (void)setStepRadius:(CGFloat)stepRadius {
    if (_stepRadius != stepRadius) {
        _stepRadius = stepRadius;
        self.thumbRadius = _stepRadius * 2.0;
    }
}

- (void)setValue:(CGFloat)value {
    value = MIN(MAX(value, self.minValue), self.maxValue);
    if (_value != value) {
        _value = value;
        [self setNeedsDisplay];
    }
}

- (void)setIndex:(NSInteger)index {
    if (_index != index) {
        _index = index;
        self.value = index;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)setEnableExternalGestureRecognizers:(BOOL)enableExternalGestureRecognizers {
    if (_enableExternalGestureRecognizers != enableExternalGestureRecognizers) {
        _enableExternalGestureRecognizers = enableExternalGestureRecognizers;
        // 通知外界手势是否可用
        if (self.enableExternalGestureRecognizersCompletion) {
            self.enableExternalGestureRecognizersCompletion(enableExternalGestureRecognizers);
        }
    }
}

// 判断点击的位置是否在圆弧上
- (BOOL)isTrackingWithPoint:(CGPoint)touchPoint {
    // 排除点在圆外面点
    CGFloat maxX = CGRectGetWidth(self.frame);
    CGFloat maxY = CGRectGetHeight(self.frame) * 0.5 + sqrt(pow(self.circleRadius, 2) * 0.5) + 10.0;
    BOOL isTure = touchPoint.x < 0 || touchPoint.x > maxX || touchPoint.y < 0 || touchPoint.y > maxY;
    if (isTure) {
        NSLog(@"点在圆外面");
        return NO;
    }
    
    // 排除与圆心半径*0.6倍以内的点
    CGFloat distance = sqrt(pow((touchPoint.x - self.circleCenter.x), 2) + pow((touchPoint.y - self.circleCenter.y), 2));
    isTure = distance < self.circleRadius * 0.6;
    if (isTure) {
        NSLog(@"点在圆心半径*0.6倍以内");
        return NO;
    }
    
    // 禁用外界手势
    self.enableExternalGestureRecognizers = NO;
    return YES;
}

// 判断点击的位置是否是mark内
- (BOOL)touchInCircleWithPoint:(CGPoint)touchPoint circleCenter:(CGPoint)circleCenter {
    ZXSPolarCoordinate polarCoordinate = pointToPolarCoordinate(circleCenter, touchPoint);
    return polarCoordinate.radius < self.thumbRadius;
}

- (void)endTouch {
    self.index = roundf(self.value);
    self.value = self.index;
    
    // 启用外界手势
    self.enableExternalGestureRecognizers = YES;
}


#pragma mark - 工具函数

CGFloat toDegree(CGFloat radian) {
    return radian * 180 / M_PI;
}

CGFloat toRadian(CGFloat degree) {
    return degree * M_PI / 180;
}

/**
 极坐标转化成点
 
 @param center 圆心
 @param radius 圆半径
 @param angle 弧度
 @return 点（x,y)
 */
CGPoint polarCoordinateToPoint(CGPoint center, CGFloat radius, CGFloat angle) {
    CGFloat x = radius * cos(angle) + center.x;
    CGFloat y = radius * sin(angle) + center.y;
    return CGPointMake(x, y);
}

/**
 点转化为极坐标
 
 @param center 圆心
 @param point 点
 @return 极坐标
 */
ZXSPolarCoordinate pointToPolarCoordinate(CGPoint center, CGPoint point) {
    ZXSPolarCoordinate polarCoordinate;
    double x = point.x - center.x;
    double y = point.y - center.y;
    polarCoordinate.radius = sqrt(pow(x, 2.0) + pow(y, 2.0));
    polarCoordinate.angle = acos(x / (sqrt(pow(x, 2.0) + pow(y, 2.0))));
    if (y < 0) {
        polarCoordinate.angle = 2 * M_PI - polarCoordinate.angle;
    }
    
    return polarCoordinate;
}

CGFloat segmentAngle(CGPoint startPoint, CGPoint endPoint) {
    CGPoint v = CGPointMake(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
    float vmag = sqrt(powf(v.x, 2.0) + powf(v.y, 2.0));
    v.x /= vmag;
    v.y /= vmag;
    double radian = atan2(v.y, v.x);
    return radian;
}

CGFloat segmentLength(CGPoint startPoint, CGPoint endPoint) {
    return pointToPolarCoordinate(startPoint, endPoint).radius;
}

@end
