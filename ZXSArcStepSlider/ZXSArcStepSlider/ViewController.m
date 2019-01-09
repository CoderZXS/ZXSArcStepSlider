//
//  ViewController.m
//  ZXSArcStepSlider
//
//  Created by bi xu on 2019/1/7.
//  Copyright © 2019 Cammus. All rights reserved.
//

#import "ViewController.h"
#import "ZXSArcStepSlider.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 375, 375)];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:150];
    self.label.textColor = [UIColor redColor];
    self.label.text = @"16";
    [self.view addSubview:self.label];
    
    ZXSArcStepSlider *slder = [[ZXSArcStepSlider alloc] initWithFrame:CGRectMake(0, 100, 375, 375)];
    [self.view addSubview:slder];
    slder.startAngle = M_PI_4 * 3;
    slder.color = [UIColor colorWithRed:29.0 / 255.0 green:207.0 / 255.0 blue:0.0 alpha:1.0];
    slder.maxValue = 19;
    slder.startValue = 0;
    slder.endValue = 14;
    slder.sectorsRadius = 135;
    [slder addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    
    slder.drowNumber = ^(CGFloat radius, CGFloat x, CGFloat y) {
        NSArray *angleArray = @[@36, @18, @0];
        NSInteger num = 16;
        for (NSNumber *number in angleArray) {
            CGFloat angle = number.floatValue;
            CGPoint point = [self getPointWithAngle:angle radius:radius];
            CGFloat xx = x - point.x;
            CGFloat yy = y + point.y;
            CGRect textRect = CGRectMake(xx - 10, yy - 6, 20, 12);
            NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
            paragraph.alignment = NSTextAlignmentCenter;
            NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:12],
                                  NSForegroundColorAttributeName : [UIColor blackColor],
                                  NSParagraphStyleAttributeName : paragraph};
            [[NSString stringWithFormat:@"%ld",(long)num] drawInRect:textRect withAttributes:dic];
            num++;
        }
        angleArray = @[@18, @36, @54, @72, @90];
        
        for (NSNumber *number in angleArray) {
            CGFloat angle = number.floatValue;
            CGPoint point = [self getPointWithAngle:angle radius:radius];
            CGFloat xx = x-point.x;
            CGFloat yy = y-point.y;
            CGRect textRect = CGRectMake(xx - 10, yy - 6, 20, 12);
            NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
            paragraph.alignment = NSTextAlignmentCenter;
            NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:12],
                                  NSForegroundColorAttributeName : [UIColor blackColor],
                                  NSParagraphStyleAttributeName : paragraph};
            [[NSString stringWithFormat:@"%ld",(long)num] drawInRect:textRect withAttributes:dic];
            num++;
        }
        angleArray = @[@72, @54, @36, @18, @0];
        
        for (NSNumber *number in angleArray) {
            CGFloat angle = number.floatValue;
            CGPoint point = [self getPointWithAngle:angle radius:radius];
            CGFloat xx = x + point.x;
            CGFloat yy = y - point.y;
            CGRect textRect = CGRectMake(xx - 10, yy - 6, 20, 12);
            NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
            paragraph.alignment = NSTextAlignmentCenter;
            NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:12],
                                  NSForegroundColorAttributeName : [UIColor blackColor],
                                  NSParagraphStyleAttributeName : paragraph};
            [[NSString stringWithFormat:@"%ld",(long)num] drawInRect:textRect withAttributes:dic];
            num++;
        }
        angleArray = @[@18, @36];
        
        for (NSNumber *number in angleArray) {
            CGFloat angle = number.floatValue;
            CGPoint point = [self getPointWithAngle:angle radius:radius];
            CGFloat xx = x + point.x;
            CGFloat yy = y + point.y;
            CGRect textRect = CGRectMake(xx - 10, yy - 6, 20, 12);
            NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
            paragraph.alignment = NSTextAlignmentCenter;
            NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:12],
                                  NSForegroundColorAttributeName : [UIColor blackColor],
                                  NSParagraphStyleAttributeName : paragraph};
            [[NSString stringWithFormat:@"%ld",(long)num] drawInRect:textRect withAttributes:dic];
            num++;
        }
    };
}
- (void)valueChange:(ZXSArcStepSlider *)slder {
    self.label.text = [NSString stringWithFormat:@"%d",(int)slder.startValue + 16];
}

//通过角度获得x,y值
- (CGPoint)getPointWithAngle:(CGFloat)angle radius:(CGFloat)r {
    CGFloat y = r * sin(angle * M_PI / 180.0);
    CGFloat x = r * cos(angle * M_PI / 180.0);
    return CGPointMake(x, y);
}



@end
