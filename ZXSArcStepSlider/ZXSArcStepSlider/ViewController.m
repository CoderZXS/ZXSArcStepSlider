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
    
    self.view.backgroundColor = [UIColor blackColor];
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 375, 375)];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:150];
    self.label.textColor = [UIColor redColor];
    self.label.text = @"0";
    [self.view addSubview:self.label];
    
    ZXSArcStepSlider *slder = [[ZXSArcStepSlider alloc] initWithFrame:CGRectMake(0, 100, 375, 375)];
    [self.view addSubview:slder];
    [slder addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
}

- (void)valueChange:(ZXSArcStepSlider *)slder {
    self.label.text = [NSString stringWithFormat:@"%d",(int)slder.startValue];
}



@end
