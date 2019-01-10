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

@property (nonatomic, assign) CGFloat startValue;// 开始值
@property (nonatomic, copy) void (^drowNumber)(CGFloat radius, CGFloat x, CGFloat y);// 如果需要在圆弧上面写上字，需要给该block赋值，其中radius为圆弧直径，x,y中心点

@end

NS_ASSUME_NONNULL_END
