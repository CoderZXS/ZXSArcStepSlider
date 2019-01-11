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

@property (nonatomic, assign) NSInteger index;// 当前下标
@property (nonatomic, assign) BOOL interaction;// 点击在限定的区域为YES，否则为NO.

@end

NS_ASSUME_NONNULL_END
