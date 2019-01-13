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


@property (nonatomic, assign) CGFloat borderWidth;// 线宽度
@property (nonatomic, strong) UIColor *unfillColor;// 背景颜色
@property (nonatomic, strong) UIColor *fillColor;// 填充颜色
@property (nonatomic, assign) CGFloat stepRadius;// 节点半径
@property (nonatomic, assign) NSInteger stepCount;// 节点个数
@property (nonatomic, assign) CGFloat thumbRadius;// 滑块半径
@property (nonatomic, strong) UIColor *thumbColor;// 滑块颜色
@property (nonatomic, assign) CGFloat minValue;// 最小值
@property (nonatomic, assign) CGFloat maxValue;// 最大值
@property (nonatomic, assign) NSInteger index;// 当前下标

@end

NS_ASSUME_NONNULL_END
