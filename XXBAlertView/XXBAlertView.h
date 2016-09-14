//
//  XXBAlertView.h
//  XXBAlertViewDemo
//
//  Created by 杨小兵 on 15/8/21.
//  Copyright (c) 2015年 杨小兵. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XXBAlertView;
typedef NS_ENUM(NSInteger, XXBAlertViewStyle) {
    XXBAlertViewStyleDefault,               //  默认的
    XXBAlertViewStyleSecureTextInput,       //  一个输入文本框
    XXBAlertViewStylePlainTextInput,        //  输入密码的
    XXBAlertViewStyleLoginAndPasswordInput  //  两个输入框
};
@protocol XXBAlertViewDelegate <NSObject>
- (void)alertView:(XXBAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@interface XXBAlertView : UIView
@property(nonatomic , copy) NSString                    *title;
@property(nonatomic , weak)id<XXBAlertViewDelegate>     delegate;
@property(nonatomic , assign) XXBAlertViewStyle         alertViewStyle;
@property(nonatomic , strong)UIColor                    *backgroundShowColor;
@property(nonatomic , strong)UIColor                    *buttonTitleColor;
@property(nonatomic , strong)UIColor                    *buttonTitleColorHighlighted;
@property(nonatomic , strong)UIColor                    *buttonTitleColorDisable;

- (instancetype)initWithTitle:(NSString *)title  andMessage:(NSString *)message delegate:(id <XXBAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION NS_EXTENSION_UNAVAILABLE_IOS("Use XXBAlertView instead.");

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex NS_AVAILABLE_IOS(5_0);
- (void)show;
@end
