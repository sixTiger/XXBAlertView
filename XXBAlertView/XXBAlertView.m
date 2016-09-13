//
//  XXBAlertView.m
//  XXBAlertViewDemo
//
//  Created by 杨小兵 on 15/8/21.
//  Copyright (c) 2015年 杨小兵. All rights reserved.
//

#import "XXBAlertView.h"

#define XXBColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0  blue:(b)/255.0  alpha:1]
#define XXBInputBGColor [UIColor colorWithRed:(226)/255.0 green:(226)/255.0  blue:(226)/255.0  alpha:1]
#define alertViewWidth 265

#define lineWidth 1

@interface XXBAlertView ()<UITextFieldDelegate>
@property(nonatomic , strong)UIView *alertView;
@property(nonatomic , strong)UILabel *titleLabel;
@property(nonatomic , strong)UIView *lineView;
@property(nonatomic , strong)UIView *inputView;
@property(nonatomic , strong)UIView *buttonView;
@property(nonatomic , strong)NSLayoutConstraint *lcTopInputView;
@property(nonatomic , strong)NSLayoutConstraint *lcHeightInputView;
@property(nonatomic , strong)NSLayoutConstraint *lcCenterYAlertView;
@property(nonatomic , strong)NSArray *textFiledArray;
@property(nonatomic , strong)NSMutableArray *buttonTitleArray;
@property(nonatomic , strong)NSMutableArray *buttonArray;
@property(nonatomic , strong)UIColor *lineColor;
@end

@implementation XXBAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self p_setupAlertView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self p_setupAlertView];
    }
    return self;
}

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex {
    return self.textFiledArray[textFieldIndex];
}

- (instancetype)initWithTitle:(NSString *)title delegate:(id<XXBAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    if (self = [super init]) {
        [self.buttonTitleArray removeAllObjects];
        self.delegate = delegate;
        CGSize oneLineSize = CGSizeZero;
        self.titleLabel.text = title;
        oneLineSize = [self.titleLabel systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        if (oneLineSize.width >= alertViewWidth - 40) {
            self.titleLabel.textAlignment = NSTextAlignmentLeft ;
        } else {
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
        }
        if (cancelButtonTitle) {
            [self.buttonTitleArray addObject:cancelButtonTitle];
        }
        NSString* curStr;
        va_list list;
        if(otherButtonTitles) {
            [self.buttonTitleArray addObject:[otherButtonTitles copy]];
            va_start(list, otherButtonTitles);
            while ((curStr = va_arg(list, NSString*))) {
                [self.buttonTitleArray addObject:[curStr copy]];
            }
            va_end(list);
        }
        [self p_creatButtons];
    }
    return self;
}

- (void)show {
    [self p_addKeyboardNote];
    [self p_setButtonsEnable];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.frame = [UIApplication sharedApplication].keyWindow.bounds;
    self.autoresizingMask = (1 << 6) -1;
    self.alpha = 0.0;
    self.backgroundColor = self.backgroundShowColor;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (self.alertViewStyle != XXBAlertViewStyleDefault) {
            [self.textFiledArray[0] becomeFirstResponder];
        }
    }];
    
    CABasicAnimation *scale = [CABasicAnimation animation];
    scale.keyPath = @"transform.scale";
    scale.fromValue = @(1.2);
    scale.toValue = @(1.0);
    CABasicAnimation *opacity = [CABasicAnimation animation];
    opacity.keyPath = @"opacity";
    opacity.fromValue = @(0);
    opacity.toValue = @(1);
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[scale, opacity];
    group.duration = 0.25;
    [self.layer addAnimation:group forKey:nil];
    
    
}

- (void)setAlertViewStyle:(XXBAlertViewStyle)alertViewStyle {
    _alertViewStyle = alertViewStyle;
    switch (alertViewStyle) {
        case XXBAlertViewStyleDefault: {
            self.lcTopInputView.constant = 4;
            self.lcHeightInputView.constant = 0;
            break;
        }
        case XXBAlertViewStyleSecureTextInput: {
            self.lcTopInputView.constant = 22;
            self.lcHeightInputView.constant = 44;
            UITextField *textFiled = self.textFiledArray[0];
            textFiled.secureTextEntry = YES;
            textFiled.placeholder = @"请输入密码";
            break;
        }
        case XXBAlertViewStylePlainTextInput: {
            self.lcTopInputView.constant = 22;
            self.lcHeightInputView.constant = 44;
            UITextField *textFiled = self.textFiledArray[0];
            textFiled.secureTextEntry = NO;
            textFiled.placeholder = @"请输入用户名";
            break;
        }
        case XXBAlertViewStyleLoginAndPasswordInput: {
            self.lcTopInputView.constant = 22;
            self.lcHeightInputView.constant = 100;
            UITextField *textFiled = self.textFiledArray[0];
            textFiled.secureTextEntry = NO;
            textFiled.placeholder = @"请输入用户名";
            textFiled = self.textFiledArray[1];
            textFiled.secureTextEntry = YES;
            textFiled.placeholder = @"请输入用密码";
            break;
        }
            
        default:
            break;
    }
}

- (void)dealloc {
    [self p_removeObserverOfTextView];
}

- (UIColor *)backgroundShowColor {
    if (_backgroundShowColor == nil) {
        _backgroundShowColor = [UIColor colorWithWhite:0.0 alpha:0.36];
    }
    return _backgroundShowColor;
}

- (UIColor *)buttonTitleColor {
    if (_buttonTitleColor == nil) {
        _buttonTitleColor = XXBColor(234, 123, 79);
    }
    return _buttonTitleColor;
}

- (UIColor *)buttonTitleColorHighlighted {
    if (_buttonTitleColorHighlighted == nil)
    {
        _buttonTitleColorHighlighted = XXBColor(210, 110, 71);
    }
    return _buttonTitleColorHighlighted;
}

- (UIColor *)buttonTitleColorDisable {
    if (_buttonTitleColorDisable == nil)
    {
        _buttonTitleColorDisable = [UIColor grayColor];
    }
    return _buttonTitleColorDisable;
}

- (UIColor *)lineColor {
    if (_lineColor == nil) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            _lineColor = [UIColor colorWithRed:(186)/255.0 green:(186)/255.0  blue:(186)/255.0  alpha:1];
        } else {
            _lineColor = [UIColor colorWithRed:(226)/255.0 green:(226)/255.0  blue:(226)/255.0  alpha:1];
        }
    }
    return _lineColor;
}

- (NSMutableArray *)buttonTitleArray {
    if (_buttonTitleArray == nil) {
        _buttonTitleArray = [NSMutableArray array];
        [_buttonTitleArray addObject:@"取消"];
        [_buttonTitleArray addObject:@"确定"];
        
        [_buttonTitleArray addObject:@"取消"];
        [_buttonTitleArray addObject:@"确定"];
    }
    return _buttonTitleArray;
}

- (NSMutableArray *)buttonArray {
    if (_buttonArray == nil) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

#pragma mark - 私有方法
- (void)p_setupAlertView {
    self.frame = [UIScreen mainScreen].bounds;
    self.autoresizingMask = (1 << 6) -1;
    self.backgroundColor = [UIColor clearColor];
    _alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, alertViewWidth, alertViewWidth)];
    _alertView.layer.cornerRadius = 5;
    _alertView.clipsToBounds = YES;
    [self addSubview:_alertView];
    [self p_creatAlertView];
    [self p_craetInputView];
    [self p_creatButtons];
    [self setAlertViewStyle:XXBAlertViewStyleDefault];
    [self p_addObserverOfTextView];
}

- (void)p_craetInputView {
    _inputView.clipsToBounds = YES;
    UITextField *textField1 = [UITextField new];
    textField1.delegate = self;
    textField1.layer.cornerRadius = 3;
    textField1.clipsToBounds = YES;
    textField1.backgroundColor = XXBInputBGColor;
    textField1.font = [UIFont systemFontOfSize:16];
    textField1.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    textField1.leftViewMode = UITextFieldViewModeAlways;
    textField1.placeholder = @"亲输入用户名";
    [_inputView addSubview:textField1];
    textField1.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *lcRightTextField1 = [NSLayoutConstraint constraintWithItem:textField1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_inputView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *lcLeftTextField1 = [NSLayoutConstraint constraintWithItem:textField1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_inputView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *lcTopTextField1 = [NSLayoutConstraint constraintWithItem:textField1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem: _inputView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *lcHeightTextField1 = [NSLayoutConstraint constraintWithItem:textField1 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:44];
    [self.alertView addConstraints:@[lcRightTextField1, lcLeftTextField1,lcTopTextField1]];
    [textField1 addConstraint:lcHeightTextField1];
    
    
    UITextField *textField2 = [UITextField new];
    textField2.delegate = self;
    textField2.backgroundColor =XXBInputBGColor;
    textField2.layer.cornerRadius = 3;
    textField2.clipsToBounds = YES;
    textField2.font = [UIFont systemFontOfSize:16];
    textField2.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    textField2.leftViewMode = UITextFieldViewModeAlways;
    textField2.placeholder = @"请输入密码";
    [_inputView addSubview:textField2];
    textField2.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *lcRightTextField2 = [NSLayoutConstraint constraintWithItem:textField2 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_inputView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *lcLeftTextField2 = [NSLayoutConstraint constraintWithItem:textField2 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_inputView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *lcTopTextField2 = [NSLayoutConstraint constraintWithItem:textField2 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem: textField1 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:12];
    NSLayoutConstraint *lcHeightTextField2 = [NSLayoutConstraint constraintWithItem:textField2 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:44];
    [self.alertView addConstraints:@[lcRightTextField2, lcLeftTextField2,lcTopTextField2]];
    [textField2 addConstraint:lcHeightTextField2];
    self.textFiledArray = @[textField1,textField2];
}

- (void)p_creatAlertView {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        UIVisualEffectView  *visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        visualEfView.frame = _alertView.bounds;
        visualEfView.alpha = 1.0;
        visualEfView.autoresizingMask = (1 << 6) -1;
        [_alertView addSubview:visualEfView];
        _alertView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    } else {
        _alertView.backgroundColor = [UIColor whiteColor];
    }
    
    _alertView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *lcWidthAlertView = [NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:alertViewWidth];
    NSLayoutConstraint *lcCenterXAlertView = [NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem: self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    _lcCenterYAlertView = [NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem: self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [_alertView addConstraint:lcWidthAlertView];
    [self addConstraint:lcCenterXAlertView];
    [self addConstraint:_lcCenterYAlertView];
    _titleLabel = [UILabel new];
    [self.alertView addSubview:_titleLabel];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _titleLabel.numberOfLines = 0;
    _titleLabel.text = @"是否确认删除该博文，您和其他人都不可见？";
    
    NSLayoutConstraint *lcRightTitleLabel = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_alertView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20];
    NSLayoutConstraint *lcLeftTitleLabel = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_alertView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20];
    NSLayoutConstraint *lcTopTitleLabel = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem: _alertView attribute:NSLayoutAttributeTop multiplier:1.0 constant:36];
    [self.alertView addConstraints:@[lcRightTitleLabel, lcLeftTitleLabel,lcTopTitleLabel]];
    
    _inputView = [UIView new];
    _inputView.translatesAutoresizingMaskIntoConstraints = NO;
    [_alertView addSubview:_inputView];
    
    NSLayoutConstraint *lcRightInputView = [NSLayoutConstraint constraintWithItem:_inputView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_alertView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-12];
    NSLayoutConstraint *lcLeftInputView = [NSLayoutConstraint constraintWithItem:_inputView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_alertView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:12];
    _lcTopInputView = [NSLayoutConstraint constraintWithItem:_inputView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem: _titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:22];
    _lcHeightInputView = [NSLayoutConstraint constraintWithItem:_inputView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0];
    [self.alertView addConstraints:@[lcRightInputView, lcLeftInputView,_lcTopInputView]];
    [_inputView addConstraint:_lcHeightInputView];
    
    
    _lineView = [UIView new];
    [_alertView addSubview:_lineView];
    _lineView.backgroundColor = self.lineColor;
    _lineView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *lcRightLineView = [NSLayoutConstraint constraintWithItem:_lineView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_alertView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    
    NSLayoutConstraint *lcLeftLineView = [NSLayoutConstraint constraintWithItem:_lineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_alertView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *lcTopLineView = [NSLayoutConstraint constraintWithItem:_lineView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem: _inputView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:22];
    NSLayoutConstraint *lcHeightLineView = [NSLayoutConstraint constraintWithItem:_lineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:lineWidth];
    [self.alertView addConstraints:@[lcRightLineView, lcLeftLineView,lcTopLineView]];
    [_lineView addConstraint:lcHeightLineView];
    
    _buttonView = [UIView new];
    _buttonView.translatesAutoresizingMaskIntoConstraints = NO;
    [_alertView addSubview:_buttonView];
    NSLayoutConstraint *lcRightButtonView = [NSLayoutConstraint constraintWithItem:_buttonView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_alertView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *lcLeftButtonView = [NSLayoutConstraint constraintWithItem:_buttonView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_alertView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *lcTopBUttonView = [NSLayoutConstraint constraintWithItem:_buttonView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem: _lineView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *lcBotBUttonView = [NSLayoutConstraint constraintWithItem:_buttonView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem: _alertView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *lcHeightButtonview = [NSLayoutConstraint constraintWithItem:_buttonView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:44];
    [self.alertView addConstraints:@[lcRightButtonView, lcLeftButtonView,lcTopBUttonView,lcBotBUttonView]];
    [_buttonView addConstraint:lcHeightButtonview];
}

- (void)p_creatButtons {
    [self.buttonArray removeAllObjects];
    [self.buttonView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSInteger buttonCount = self.buttonTitleArray.count;
    CGFloat buttonWidth = (alertViewWidth - buttonCount + lineWidth)/(CGFloat)buttonCount;
    CGFloat buttonX;
    CGFloat buttonY = 0.0;
    CGFloat buttonHeight = 44.0;
    for (NSInteger i = 0; i < buttonCount; i++) {
        buttonX = i * buttonWidth + i;
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:self.buttonTitleArray[i] forState:UIControlStateNormal];
        
        [button setTitleColor:self.buttonTitleColor forState:UIControlStateNormal];
        [button setTitleColor:self.buttonTitleColorHighlighted forState:UIControlStateHighlighted];
        [button setTitleColor:self.buttonTitleColorDisable forState:UIControlStateDisabled];
        [self.buttonView addSubview:button];
        [self.buttonArray addObject:button];
        button.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(buttonX + buttonWidth, 0, lineWidth, buttonHeight)];
        lineView.backgroundColor = self.lineColor;
        [self.buttonView addSubview:lineView];
        [button addTarget:self action:@selector(p_buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)p_addKeyboardNote {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(p_keyBoardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)p_keyBoardWillChangeFrame:(NSNotification *)note {
    CGRect viewTransform =[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardEndY = viewTransform.origin.y;
    self.lcCenterYAlertView.constant = - (self.frame.size.height - keyboardEndY) * 0.5;
    CGFloat keyboardAnimation = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:keyboardAnimation animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)p_buttonClick:(UIButton *)clickedButton {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
            [self.delegate alertView:self clickedButtonAtIndex:[self.buttonArray indexOfObject:clickedButton]];
        }
        [self removeFromSuperview];
    }];
}

- (void)p_addObserverOfTextView {
    for (UITextField *textField in self.textFiledArray) {
        
        [textField addObserver:self forKeyPath:@"text" options:0 context:nil];
        [textField addTarget:self  action:@selector(textFileTextChage)  forControlEvents:UIControlEventAllEditingEvents];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFileTextChage) name:UITextFieldTextDidChangeNotification object:textField];
    }
}

- (void)p_removeObserverOfTextView {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (UITextField *textField in self.textFiledArray) {
        [textField removeObserver:self forKeyPath:@"text"];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self p_setButtonsEnable];
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self p_setButtonsEnable];
}

- (void)textFileTextChage {
    [self p_setButtonsEnable];
}

- (void)p_setButtonsEnable {
    NSInteger count = self.buttonArray.count;
    for (int i = 1; i < count; i++) {
        UIButton *button = self.buttonArray[i];
        switch (self.alertViewStyle) {
            case XXBAlertViewStyleDefault: {
                break;
            }
            case XXBAlertViewStyleSecureTextInput: {
                UITextField *textField1 = self.textFiledArray[0];
                button.enabled = textField1.text.length >0;
                break;
            }
            case XXBAlertViewStylePlainTextInput: {
                UITextField *textField1 = self.textFiledArray[0];
                button.enabled = textField1.text.length >0;
                break;
            }
            case XXBAlertViewStyleLoginAndPasswordInput: {
                UITextField *textField1 = self.textFiledArray[0];
                UITextField *textField2 = self.textFiledArray[1];
                button.enabled = (textField1.text.length >0)&&(textField2.text.length >0);
                break;
            }
            default:
                break;
        }
    }
}

@end
