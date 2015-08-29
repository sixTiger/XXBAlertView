//
//  ViewController.m
//  XXBAlertViewDemo
//
//  Created by 杨小兵 on 15/8/21.
//  Copyright (c) 2015年 杨小兵. All rights reserved.
//

#import "ViewController.h"
#import "XXBAlertView.h"

@interface ViewController ()<XXBAlertViewDelegate>
- (IBAction)normalAction:(UIButton *)sender;
- (IBAction)inputAction:(id)sender;

@end

@implementation ViewController


- (IBAction)normalAction:(UIButton *)sender {
    XXBAlertView *alertView = [[XXBAlertView alloc] initWithTitle:@"我是标题" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",@"取消",@"确定",@"取消",nil];
    alertView.alertViewStyle = XXBAlertViewStyleSecureTextInput;
    [alertView show];
}

- (IBAction)inputAction:(id)sender {
}
- (void)alertView:(XXBAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%@",@(buttonIndex));
}
@end
