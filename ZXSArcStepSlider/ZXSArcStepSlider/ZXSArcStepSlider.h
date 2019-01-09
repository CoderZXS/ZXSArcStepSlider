//
//  ZXSArcStepSlider.h
//  ZXSArcStepSlider
//
//  Created by bi xu on 2019/1/7.
//  Copyright © 2019 Cammus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZXSArcStepSlider : UIControl

@property (strong, nonatomic) UIColor *color;

@property (nonatomic, readwrite) double minValue;// 最小
@property (nonatomic, readwrite) double maxValue;// 最大

@property (nonatomic, readwrite) double startValue;// 开始值
@property (nonatomic, readwrite) double endValue;// 结束值

@property (nonatomic, readwrite) double sectorsRadius;// 扇形半径
@property (nonatomic, readwrite) double startAngle;// 开始的角度
@property (nonatomic, assign) double markRadius;// 标记半径
@property (nonatomic, copy) void (^drowNumber)(CGFloat radius, CGFloat x, CGFloat y);// 如果需要在圆弧上面写上字，需要给该block赋值，其中radius为圆弧直径，x,y中心点
@property (nonatomic, assign) double circleLineWidth;// 圆弧宽度
@property (nonatomic, assign) double lineWidth;// 线宽

@end

NS_ASSUME_NONNULL_END
