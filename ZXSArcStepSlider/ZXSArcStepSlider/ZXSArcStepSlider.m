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

@property (nonatomic, assign) CGPoint circleCenter;// 圆心

@property (nonatomic, assign) CGFloat fullLine;// 总路径长度
@property (nonatomic, assign) CGFloat circleOffset;// 标识初始偏移量（距离原点最开始的位置）
@property (nonatomic, assign) CGFloat circleLine;// 标识可移动的长度
@property (nonatomic, assign) CGFloat circleEmpty;// 标识不可移动的长度（最大长度值与末尾值的差）

@property (nonatomic, assign) CGFloat circleOffsetAngle;// 标识起点弧度
@property (nonatomic, assign) CGFloat circleLineAngle;// 圆弧终点弧度
@property (nonatomic, assign) CGFloat circleEmptyAngle;// 标识不可滚动弧度

@property (nonatomic, assign) CGPoint markerCenter;

@property (nonatomic, assign) CGFloat markerFontSize;

@property (nonatomic, assign) CGFloat markerAlpha;

@property (nonatomic, assign) BOOL trackingSectorStartMarker;

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
    if ([self touchInCircleWithPoint:touchPoint circleCenter:self.markerCenter]) {
        self.trackingSectorStartMarker = YES;
        return YES;
    }
    
    return NO;
}

//持续
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:self];
    ZXSPolarCoordinate polar = decartToPolar(self.circleCenter, touchPoint);
    
    double correctedAngle;
    if(polar.angle < self.startAngle) correctedAngle = polar.angle + (2 * M_PI - self.startAngle);
    else correctedAngle = polar.angle - self.startAngle;
    
    double procent = correctedAngle / (M_PI * 2);
    
    double newValue = procent * (self.maxValue - self.minValue) + self.minValue;
    
    if (self.trackingSectorStartMarker) {
        if (newValue > self.startValue) {
            double diff = newValue - self.startValue;
            if (diff > ((self.maxValue - self.minValue)/2)) {
                self.startValue = self.minValue;
                [self valueChangedNotification];
                [self setNeedsDisplay];
                return YES;
            }
        }
        
        if (newValue >= self.endValue) {
            self.startValue = self.endValue;
            [self valueChangedNotification];
            [self setNeedsDisplay];
            return YES;
        }
        
        self.startValue = newValue;
        [self valueChangedNotification];
        
    } else {
        if (newValue < self.endValue) {
            double diff = self.endValue - newValue;
            if (diff > ((self.maxValue - self.minValue)/2)) {
                self.endValue = self.maxValue;
                [self valueChangedNotification];
                [self setNeedsDisplay];
                return YES;
            }
        }
        
        if (newValue <= self.startValue) {
            self.endValue = self.startValue;
            [self valueChangedNotification];
            [self setNeedsDisplay];
            return YES;
        }
        
        self.endValue = newValue;
        [self valueChangedNotification];
    }
    
    [self setNeedsDisplay];
    return YES;
}

//结束
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    self.trackingSectorStartMarker = NO;
}


#pragma mark - 自定义

- (void)setupInit {
    self.backgroundColor = [UIColor clearColor];
    self.sectorsRadius = 45.0;
    self.startAngle = toRadians(135);
    self.markRadius = 20;
    self.circleLineWidth = 20;
    self.lineWidth = 2;
    self.color = [UIColor greenColor];
    self.minValue = 0.0;
    self.maxValue = 100.0;
    self.startValue = 0.0;
    self.endValue = 50.0;
}

- (void)setSectorsRadius:(double)sectorsRadius {
    _sectorsRadius = sectorsRadius;
    [self setNeedsDisplay];
}

- (void)draw {
    /*
     1.获取图形上下文
     2.绘图
       2.1画图
       2.2设置参数(颜色、线宽、线段样式等)
     3.渲染
     */
    self.circleCenter = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    
    self.fullLine = self.maxValue - self.minValue;
    self.circleOffset = self.startValue - self.minValue;
    self.circleLine = self.endValue - self.startValue;
    self.circleEmpty = self.maxValue - self.endValue;
    
    self.circleOffsetAngle = (self.circleOffset / self.fullLine) * M_PI * 2 + self.startAngle;
    self.circleLineAngle = (self.circleLine / self.fullLine) * M_PI * 2 + self.circleOffsetAngle;
    self.circleEmptyAngle = M_PI * 2 + self.startAngle;
    
    self.markerCenter = polarToDecart(self.circleCenter, self.sectorsRadius, self.circleOffsetAngle);
    self.markerFontSize = 18;
    self.markerAlpha = 1.0;
    UIColor *markBackcolor = [UIColor whiteColor];
    CGFloat len = self.sectorsRadius / sqrt(2);
    
    // 1.绿色填充圆弧
    // 1.1获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 1.2绘图
    CGContextAddArc(ctx, self.circleCenter.x, self.circleCenter.y, self.sectorsRadius, self.startAngle, self.circleOffsetAngle, 0);
    CGContextSetLineWidth(ctx, self.circleLineWidth);
    [self.color setStroke];
    CGContextSetLineCap(ctx, kCGLineCapRound);
    // 1.3渲染
    CGContextStrokePath(ctx);

    CGContextSaveGState(ctx);
    
    // 2.标识圆
    CGContextAddArc(ctx, self.markerCenter.x, self.markerCenter.y, self.markRadius - (self.lineWidth * 0.5), 0.0, M_PI * 2, 0);
    CGContextClip(ctx);
    
    CGContextClearRect(ctx, self.bounds);
    CGContextRestoreGState(ctx);
    
    // 3.外圆弧
    CGContextAddArc(ctx, self.circleCenter.x, self.circleCenter.y, self.sectorsRadius + (self.circleLineWidth * 0.5), self.startAngle, M_PI_4, 0);
    CGContextSetLineWidth(ctx, self.lineWidth);
    CGContextStrokePath(ctx);
    
    CGContextSaveGState(ctx);
    
    // 4.左端点圆弧
    CGContextAddArc(ctx, self.circleCenter.x - len, self.circleCenter.y + len, (self.circleLineWidth * 0.5), -M_PI_4, M_PI_4 * 3, 0);
    CGContextStrokePath(ctx);
    
    CGContextSaveGState(ctx);
    
    // 5.内圆弧
    CGContextAddArc(ctx, self.circleCenter.x, self.circleCenter.y, self.sectorsRadius - (self.circleLineWidth * 0.5), self.startAngle, M_PI_4, 0);
    CGContextStrokePath(ctx);
    
    CGContextSaveGState(ctx);
    
    // 6.右端点圆弧
    CGContextAddArc(ctx, self.circleCenter.x + len, self.circleCenter.y + len, self.circleLineWidth * 0.5, M_PI_4, M_PI_4 * 5, 0);
    CGContextStrokePath(ctx);
    
    // 7.圆弧字
    if (self.drowNumber) {
        self.drowNumber(self.sectorsRadius, self.circleCenter.x, self.circleCenter.y);
    }
    
    // 8.标记
    CGContextAddArc(ctx, self.markerCenter.x, self.markerCenter.y, self.markRadius, 0.0, M_PI * 2, 0);
    CGContextSetLineWidth(ctx, self.lineWidth);
    [[self.color colorWithAlphaComponent:self.markerAlpha] setStroke];
    CGContextStrokePath(ctx);
    
    // 9.标记背景色
    CGContextAddArc(ctx, self.markerCenter.x, self.markerCenter.y, self.markRadius - 1, 0.0, M_PI * 2, 0);
    [markBackcolor setFill];
    [[self.color colorWithAlphaComponent:self.markerAlpha] setStroke];
    CGContextFillPath(ctx);
    
    // 10.标记上面的字
    NSString *startMarkerStr = [NSString stringWithFormat:@"%.0f", self.startValue + 16];
    [self drawString:startMarkerStr
            withFont:self.markerFontSize
               color:[self.color colorWithAlphaComponent:self.markerAlpha]
          withCenter:self.markerCenter];
}

//mark上面的字
- (void)drawString:(NSString *)s withFont:(CGFloat)fontSize color:(UIColor *)color withCenter:(CGPoint)center {
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                          NSForegroundColorAttributeName : color,
                          NSParagraphStyleAttributeName : paragraph};
    
    CGFloat x = center.x - (self.markRadius);
    CGFloat y = center.y - (self.markRadius / 2);
    CGRect textRect = CGRectMake(x, y, self.markRadius * 2, self.markRadius);
    
    [s drawInRect:textRect withAttributes:dic];
}

//判断点击的位置是否是mark内
- (BOOL)touchInCircleWithPoint:(CGPoint)touchPoint circleCenter:(CGPoint)circleCenter {
    ZXSPolarCoordinate polar = decartToPolar(circleCenter, touchPoint);
    return polar.radius < self.markRadius;
}

- (void)valueChangedNotification {
    [self sendActionsForControlEvents:UIControlEventValueChanged];
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
    if(y < 0) polar.angle = 2 * M_PI - polar.angle;
    return polar;
}


@end
