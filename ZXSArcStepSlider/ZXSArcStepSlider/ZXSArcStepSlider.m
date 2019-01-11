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
@property (nonatomic, assign) CGFloat lineWidth;// 线宽度
@property (nonatomic, strong) UIColor *tintColor;// 背景颜色
@property (nonatomic, strong) UIColor *onTintColor;// 填充颜色
@property (nonatomic, assign) CGFloat startAngle;// 开始弧度
@property (nonatomic, assign) CGFloat endAngle;// 结束弧度
@property (nonatomic, assign) CGFloat angleWidth;// 弧度宽度

@property (nonatomic, assign) CGFloat thumbRadius;// 滑块半径
@property (nonatomic, strong) UIColor *thumbColor;// 滑块颜色
@property (nonatomic, assign) CGPoint thumbCenter;// 滑块中心点

@property (nonatomic, assign) CGFloat minValue;// 最小值
@property (nonatomic, assign) CGFloat maxValue;// 最大值
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

//开始
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:self];
    return [self touchInCircleWithPoint:touchPoint circleCenter:self.thumbCenter];
}

//持续
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:self];
    ZXSPolarCoordinate polar = decartToPolar(self.circleCenter, touchPoint);
    double angleOffset = (polar.angle < self.startAngle) ? (polar.angle + 2 * M_PI - self.startAngle) : (polar.angle - self.startAngle);
    double newValue = (angleOffset / self.angleWidth) * self.valueWidth + self.minValue;
    NSLog(@"newValue = %f",newValue);
    
    // 过滤不合理的新值
    BOOL isTure = newValue < self.minValue || newValue > self.maxValue;
    if (isTure) return NO;
    
    self.value = newValue;
    [self valueChangedNotification];
    [self setNeedsDisplay];
    return YES;
}

//结束
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
}


#pragma mark - 自定义

- (void)setupInit {
    self.backgroundColor = [UIColor clearColor];
    self.circleRadius = 135;
    self.lineWidth = 10;
    self.tintColor = [UIColor grayColor];
    self.onTintColor = [UIColor orangeColor];
    self.startAngle = M_PI_4 * 3;
    self.endAngle = M_PI_4 + M_PI * 2;
    self.angleWidth = self.endAngle - self.startAngle;
    
    self.thumbRadius = 15;
    self.thumbColor = [UIColor whiteColor];
    
    self.value = 0.0;
    self.minValue = 0.0;
    self.maxValue = 9;
    self.valueWidth = self.maxValue - self.minValue;
}

- (void)setCircleRadius:(CGFloat)circleRadius {
    _circleRadius = circleRadius;
    [self setNeedsDisplay];
}

- (void)draw {
    self.circleCenter = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    // 值偏移量
    CGFloat currentAngle = ((self.value - self.minValue) / self.valueWidth) * self.angleWidth + self.startAngle;
    self.thumbCenter = polarToDecart(self.circleCenter, self.circleRadius, currentAngle);
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
    CGContextSetLineWidth(ctx, self.lineWidth);
    [self.tintColor setStroke];
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextStrokePath(ctx);
    
    // 2.填充圆弧
    CGContextAddArc(ctx, self.circleCenter.x, self.circleCenter.y, self.circleRadius, self.startAngle, currentAngle, 0);
    [self.onTintColor setStroke];
    CGContextStrokePath(ctx);
    
    // 3.滑轮
    CGContextAddArc(ctx, self.thumbCenter.x, self.thumbCenter.y, self.thumbRadius, 0.0, M_PI * 2, 0);
    [self.thumbColor setFill];
    CGContextFillPath(ctx);
}

//判断点击的位置是否是mark内
- (BOOL)touchInCircleWithPoint:(CGPoint)touchPoint circleCenter:(CGPoint)circleCenter {
    ZXSPolarCoordinate polar = decartToPolar(circleCenter, touchPoint);
    return polar.radius < self.thumbRadius;
}

- (void)valueChangedNotification {
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

//通过角度获得x,y值
- (CGPoint)getPointWithAngle:(CGFloat)angle radius:(CGFloat)r {
    CGFloat y = r * sin(angle * M_PI / 180.0);
    CGFloat x = r * cos(angle * M_PI / 180.0);
    return CGPointMake(x, y);
}

CGFloat toDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
}

CGFloat toRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

CGFloat segmentAngle(CGPoint startPoint, CGPoint endPoint) {
    CGPoint v = CGPointMake(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
    float vmag = sqrt(powf(v.x, 2.0) + powf(v.y, 2.0));
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y, v.x);
    return radians;
}

CGFloat segmentLength(CGPoint startPoint, CGPoint endPoint) {
    return decartToPolar(startPoint, endPoint).radius;
}

CGPoint polarToDecart(CGPoint startPoint, CGFloat radius, CGFloat angle) {
    CGFloat x = radius * cos(angle) + startPoint.x;
    CGFloat y = radius * sin(angle) + startPoint.y;
    return CGPointMake(x, y);
}

ZXSPolarCoordinate decartToPolar(CGPoint center, CGPoint point) {
    double x = point.x - center.x;
    double y = point.y - center.y;
    ZXSPolarCoordinate polar;
    polar.radius = sqrt(pow(x, 2.0) + pow(y, 2.0));
    polar.angle = acos(x / (sqrt(pow(x, 2.0) + pow(y, 2.0))));
    
    if (y < 0) {
        polar.angle = 2 * M_PI - polar.angle;
    }
    
    return polar;
}



@end
