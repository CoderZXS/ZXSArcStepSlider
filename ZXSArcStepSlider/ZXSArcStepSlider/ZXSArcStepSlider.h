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

@property (nonatomic, assign) CGFloat sectorsRadius;// 扇形半径
@property (nonatomic, assign) CGFloat startAngle;// 开始的角度
@property (nonatomic, assign) CGFloat markRadius;// 标记半径
@property (nonatomic, assign) CGFloat circleLineWidth;// 圆弧宽度
@property (nonatomic, assign) CGFloat lineWidth;// 线宽
@property (nonatomic, strong) UIColor *color;// 填充颜色
@property (nonatomic, assign) CGFloat minValue;// 最小
@property (nonatomic, assign) CGFloat maxValue;// 最大
@property (nonatomic, assign) CGFloat startValue;// 开始值
@property (nonatomic, assign) CGFloat endValue;// 结束值
@property (nonatomic, copy) void (^drowNumber)(CGFloat radius, CGFloat x, CGFloat y);// 如果需要在圆弧上面写上字，需要给该block赋值，其中radius为圆弧直径，x,y中心点

@end

NS_ASSUME_NONNULL_END
