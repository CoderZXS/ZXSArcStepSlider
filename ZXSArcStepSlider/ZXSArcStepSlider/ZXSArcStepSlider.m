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

@property (nonatomic, assign) CGFloat circleRadius;// 圆半径
@property (nonatomic, assign) CGPoint circleCenter;// 圆心

// 圆弧
@property (nonatomic, assign) CGFloat borderWidth;// 线宽度
@property (nonatomic, strong) UIColor *unfillColor;// 背景颜色
@property (nonatomic, strong) UIColor *fillColor;// 填充颜色
@property (nonatomic, assign) CGFloat startAngle;// 开始弧度
@property (nonatomic, assign) CGFloat endAngle;// 结束弧度
@property (nonatomic, assign) CGFloat angleWidth;// 弧度宽度

// 节点
@property (nonatomic, assign) CGFloat stepRadius;// 节点半径

// 滑块
@property (nonatomic, assign) CGFloat thumbRadius;// 滑块半径
@property (nonatomic, strong) UIColor *thumbColor;// 滑块颜色
@property (nonatomic, assign) CGPoint thumbCenter;// 滑块中心点

@property (nonatomic, assign) CGFloat minValue;// 最小值
@property (nonatomic, assign) CGFloat maxValue;// 最大值
@property (nonatomic, assign) CGFloat value;// 当前值
@property (nonatomic, assign) CGFloat valueWidth;// 取值宽度

@end


@implementation ZXSArcStepSlider

#pragma mark - 系统

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupInit];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self draw];
}

// 点击开始
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    return [self handleBeginTrackingWithTouch:touch withEvent:event];
}

// 拖动过程中
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    return [self handleContinueTrackingWithTouch:touch withEvent:event];
}

// 拖动结束
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    return [self handleEndTrackingWithTouch:touch withEvent:event];
}


#pragma mark - 自定义

- (void)setupInit {
    self.backgroundColor = [UIColor clearColor];
    
    self.circleRadius = 135;
    
    self.borderWidth = 10;
    self.unfillColor = [UIColor whiteColor];
    self.fillColor = [UIColor orangeColor];
    self.startAngle = M_PI_4 * 3;
    self.endAngle = M_PI_4 + M_PI * 2;
    self.angleWidth = self.endAngle - self.startAngle;
    
    self.stepRadius = 10;
    
    self.thumbRadius = 15;
    self.thumbColor = self.unfillColor;

    self.minValue = 0.0;
    self.maxValue = 9.0;
    self.value = 0.0;
    self.index = 0;
    self.valueWidth = self.maxValue - self.minValue;
    
    self.interaction = NO;
}

- (void)draw {
    self.circleCenter = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    // 值偏移量
    CGFloat currentAngle = ((self.value - self.minValue) / self.valueWidth) * self.angleWidth + self.startAngle;
    self.thumbCenter = polarCoordinateToPoint(self.circleCenter, self.circleRadius, currentAngle);
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
    for (NSInteger i = 0; i < 10; i++) {
        CGFloat stepAngle = ((i - self.minValue) / self.valueWidth) * self.angleWidth + self.startAngle;
        CGPoint stepCenter = polarCoordinateToPoint(self.circleCenter, self.circleRadius, stepAngle);
        CGContextAddArc(ctx, stepCenter.x, stepCenter.y, 10, 0.0, M_PI * 2, 0);
        UIColor *stepColor = stepAngle < currentAngle ? self.fillColor : self.unfillColor;
        [stepColor setFill];
        CGContextFillPath(ctx);
    }
    
    // 4.滑轮
    CGContextAddArc(ctx, self.thumbCenter.x, self.thumbCenter.y, self.thumbRadius, 0.0, M_PI * 2, 0);
    [self.thumbColor setFill];
    CGContextFillPath(ctx);
}

- (BOOL)handleBeginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"handleBeginTrackingWithTouch");
    CGPoint touchPoint = [touch locationInView:self];
    return [self touchInCircleWithPoint:touchPoint circleCenter:self.thumbCenter];
}

- (BOOL)handleContinueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"handleContinueTrackingWithTouch");
    CGPoint touchPoint = [touch locationInView:self];
    ZXSPolarCoordinate polarCoordinate = pointToPolarCoordinate(self.circleCenter, touchPoint);
    double angleOffset = (polarCoordinate.angle < self.startAngle) ? (polarCoordinate.angle + 2 * M_PI - self.startAngle) : (polarCoordinate.angle - self.startAngle);
    double newValue = (angleOffset / self.angleWidth) * self.valueWidth + self.minValue;
    NSLog(@"newValue = %f",newValue);
    self.value = newValue;
    return YES;
}

- (void)handleEndTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"handleEndTrackingWithTouch");
    self.index = roundf(self.value);
    self.value = self.index;
}

- (void)setValue:(CGFloat)value {
    if (_value != value) {
        _value = MIN(MAX(value, 0.0), 9.0);
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

// 判断点击的位置是否是mark内
- (BOOL)touchInCircleWithPoint:(CGPoint)touchPoint circleCenter:(CGPoint)circleCenter {
    ZXSPolarCoordinate polarCoordinate = pointToPolarCoordinate(circleCenter, touchPoint);
    return polarCoordinate.radius < self.thumbRadius;
}


#pragma mark - 工具函数

CGFloat toDegree(CGFloat radian) {
    return radian * 180 / M_PI;
}

CGFloat toRadian(CGFloat degree) {
    return degree * M_PI / 180;
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

@end
