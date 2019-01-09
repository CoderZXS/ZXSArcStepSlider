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

@property (nonatomic, assign) CGPoint circleCenter;
@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, assign) CGFloat fullLine;
@property (nonatomic, assign) CGFloat circleOffset;
@property (nonatomic, assign) CGFloat circleLine;
@property (nonatomic, assign) CGFloat circleEmpty;

@property (nonatomic, assign) CGFloat circleOffsetAngle;
@property (nonatomic, assign) CGFloat circleLineAngle;
@property (nonatomic, assign) CGFloat circleEmptyAngle;

@property (nonatomic, assign) CGPoint startMarkerCenter;
@property (nonatomic, assign) CGPoint endMarkerCenter;

@property (nonatomic, assign) CGFloat startMarkerRadius;
@property (nonatomic, assign) CGFloat endMarkerRadius;

@property (nonatomic, assign) CGFloat startMarkerFontSize;
@property (nonatomic, assign) CGFloat endMarkerFontize;

@property (nonatomic, assign) CGFloat startMarkerAlpha;
@property (nonatomic, assign) CGFloat endMarkerAlpha;

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
    [self sectorToDrawInf];
    
    if ([self touchInCircleWithPoint:touchPoint circleCenter:self.endMarkerCenter]) {
        self.trackingSectorStartMarker = NO;
        return YES;
    }
    
    if ([self touchInCircleWithPoint:touchPoint circleCenter:self.startMarkerCenter]) {
        self.trackingSectorStartMarker = YES;
        return YES;
    }
    
    return NO;
}

//持续
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:self];
    CGPoint ceter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    ZXSPolarCoordinate polar = decartToPolar(ceter, touchPoint);
    
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
    // 1.获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 2.绘图
    CGContextSetLineWidth(ctx, self.circleLineWidth);
    
    UIColor *startCircleColor = self.color;
    UIColor *markBackcolor = [UIColor whiteColor];
    
    [self sectorToDrawInf];
    CGFloat x = self.circleCenter.x;
    CGFloat y = self.circleCenter.y;
    CGFloat r = self.radius;
    
    //start circle line
    [startCircleColor setStroke];
    
    CGContextAddArc(ctx, x, y, r, self.startAngle, self.circleOffsetAngle, 0);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    // 3.渲染
    CGContextStrokePath(ctx);
    
    //clearing place for start marker
    CGContextSaveGState(ctx);
    CGContextAddArc(ctx, self.startMarkerCenter.x, self.startMarkerCenter.y, self.startMarkerRadius - (self.lineWidth / 2.0), 0.0, 6.28, 0);
    CGContextClip(ctx);
    CGContextClearRect(ctx, self.bounds);
    CGContextRestoreGState(ctx);
    
    //clearing place for end marker
    CGContextSaveGState(ctx);
    CGContextAddArc(ctx, self.endMarkerCenter.x, self.endMarkerCenter.y, self.endMarkerRadius - (self.lineWidth / 2.0), 0.0, 6.28, 0);
    CGContextClip(ctx);
    CGContextClearRect(ctx, self.bounds);
    CGContextRestoreGState(ctx);
    
    CGFloat len = r / sqrt(2);
    
    //外圆弧
    CGContextSetLineWidth(ctx, self.lineWidth);
    CGContextAddArc(ctx, x, y, r + 10, self.startAngle, M_PI_4, 0);
    CGContextStrokePath(ctx);
    
    //左端点
    CGContextSaveGState(ctx);
    CGContextAddArc(ctx, x - len, y + len, 10, -M_PI_4, M_PI_4*3, 0);
    CGContextStrokePath(ctx);
    
    //内圆弧
    CGContextSaveGState(ctx);
    CGContextAddArc(ctx, x, y, r - 10, self.startAngle, M_PI_4, 0);
    CGContextStrokePath(ctx);
    //右端点
    CGContextSaveGState(ctx);
    CGContextAddArc(ctx, x + len, y + len, 10, M_PI_4, M_PI_4 * 5, 0);
    CGContextStrokePath(ctx);
    
    //如果需要圆弧上面有字
    if (self.drowNumber) {
        self.drowNumber(r,x,y);
    }
    
    //标记
    CGContextSetLineWidth(ctx, self.lineWidth);
    [[startCircleColor colorWithAlphaComponent:self.startMarkerAlpha] setStroke];
    CGContextAddArc(ctx, self.startMarkerCenter.x, self.startMarkerCenter.y, self.startMarkerRadius, 0.0, 6.28, 0);
    //标记背景色
    CGContextStrokePath(ctx);
    [markBackcolor setFill];
    [[startCircleColor colorWithAlphaComponent:self.startMarkerAlpha] setStroke];
    CGContextAddArc(ctx, self.startMarkerCenter.x, self.startMarkerCenter.y, self.startMarkerRadius - 1, 0.0, 6.28, 0);
    CGContextFillPath(ctx);
    //标记上面的字
    NSString *startMarkerStr = [NSString stringWithFormat:@"%.0f", self.startValue + 16];
    [self drawString:startMarkerStr
            withFont:self.startMarkerFontSize
               color:[startCircleColor colorWithAlphaComponent:self.startMarkerAlpha]
          withCenter:self.startMarkerCenter];
}

- (void)sectorToDrawInf {
    self.circleCenter = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    self.radius = self.sectorsRadius;// 圆半径
    
    self.fullLine = self.maxValue - self.minValue;
    self.circleOffset = self.startValue - self.minValue;
    self.circleLine = self.endValue - self.startValue;
    self.circleEmpty = self.maxValue - self.endValue;
    
    self.circleOffsetAngle = (self.circleOffset / self.fullLine) * M_PI * 2 + self.startAngle;
    self.circleLineAngle = (self.circleLine / self.fullLine) * M_PI * 2 + self.circleOffsetAngle;
    self.circleEmptyAngle = M_PI * 2 + self.startAngle;
    
    self.startMarkerCenter = polarToDecart(self.circleCenter, self.radius, self.circleOffsetAngle);
    
    self.startMarkerRadius = self.markRadius;
    
    self.startMarkerFontSize = 18;
    self.startMarkerAlpha = 1.0;
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
