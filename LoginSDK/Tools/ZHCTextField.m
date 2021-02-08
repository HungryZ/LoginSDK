//
//  ZHCTextField.m
//  HungryTools
//
//  Created by 张海川 on 2019/4/25.
//

#ifndef ThemeColor
    #define ThemeColor [UIColor colorWithRed:45/255.f green:160/255.f blue:247/255.f alpha:1]
#endif

#import "ZHCTextField.h"

@interface ZHCTextField() <UITextFieldDelegate>

@property (nonatomic, strong) UIView *      bottomLineView;
@property (nonatomic, strong) UIView *      secureView;
@property (nonatomic, strong) UIButton *    secureButton;

@property (nonatomic, assign) CGFloat       bottomLineLeftPadding;
@property (nonatomic, assign) CGFloat       bottomLineRightPadding;

@end

@implementation ZHCTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initConfig];
    }
    return self;
}

- (void)initConfig {
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.delegate = self;
    self.font = [UIFont systemFontOfSize:14];
    
    _bottomLineLeftPadding = 0;
    _bottomLineRightPadding = 0;
    _bottomLineHeight = 0.5;
    
    [self addBottomLine];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // 删除
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    NSInteger comingTextLength = textField.text.length + string.length - range.length;
    
    if (_maxLength) {
        if (comingTextLength > _maxLength) {
            return NO;
        }
    }
    
    switch (_fieldType) {
        case ZHCFieldTypeDefault: {
            return YES;
        }
        case ZHCFieldTypeNumber: {
            return [self checkString:string withRegexString:@"[0-9]+"];
        }
        case ZHCFieldTypePhoneNumber: {
            if (self.text.length == 3 || self.text.length == 8) {
                self.text = [self.text stringByAppendingString:@" "];
            }
            return [self checkString:string withRegexString:@"[0-9]+"];
        }
        case ZHCFieldTypePhoneNumberWithoutSpacing: {
            return [self checkString:string withRegexString:@"[0-9]+"];
        }
        case ZHCFieldTypePassword: {
            // 半角字符 包括字母，数字，标点符号
            return [self checkString:string withRegexString:@"[\\x00-\\xff]+"];
        }
        case ZHCFieldTypeMoney: {
            return [self checkString:string withRegexString:@"[0-9.]+"];
        }
        case ZHCFieldTypeIDCardNumber: {
            return [self checkString:string withRegexString:@"[0-9Xx]+"];
        }
        case ZHCFieldTypeName: {
            // \\u4e00-\\u9fa5 中文字符
            // \\u278B-\\u2792 ➋-➒ 适配原生九宫格输入法
            return [self checkString:string withRegexString:@"[A-Za-z0-9\\u4e00-\\u9fa5\\u278B-\\u2792]+"];
        }
        case ZHCFieldTypeBankCardNumber: {
            return [self checkString:string withRegexString:@"[0-9]+"];
        }
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.25 animations:^{
        if (self.bottomLineActiveColor) {
            self.bottomLineView.backgroundColor = self.bottomLineActiveColor;
        } else {
            self.bottomLineView.backgroundColor = ThemeColor;
        }
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.25 animations:^{
        if (self.bottomLinePassiveColor) {
            self.bottomLineView.backgroundColor = self.bottomLinePassiveColor;
        } else {
            self.bottomLineView.backgroundColor = [UIColor lightGrayColor];
        }
    }];
}

#pragma mark - Action

- (void)secureBtnClicked {
    self.secureTextEntry ^= 1;
    self.secureButton.selected = !self.isSecureTextEntry;
}

#pragma mark - Private Method

- (void)addBottomLine {
    [self addSubview:self.bottomLineView];
    [self updateBottomLineConstraints];
}

- (void)updateBottomLineConstraints {
    [self removeConstraints:self.constraints];
    [self addConstraints:@[
        [NSLayoutConstraint constraintWithItem:self.bottomLineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:self.bottomLineLeftPadding],
        [NSLayoutConstraint constraintWithItem:self.bottomLineView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:self.bottomLineView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-self.bottomLineRightPadding],
        [NSLayoutConstraint constraintWithItem:self.bottomLineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:self.bottomLineHeight],
    ]];
}

- (void)setLeftViewConstraints:(UIView *)subView withLeftView:(UIView *)leftView {
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    [leftView addConstraints:@[
        [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:leftView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:leftView attribute:NSLayoutAttributeLeft multiplier:1 constant:10],
        [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:leftView attribute:NSLayoutAttributeRight multiplier:1 constant:-10],
    ]];
}

- (void)setPlaceholderAttribute:(id)value {
    
    NSMutableAttributedString * attriString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedPlaceholder];
    
    NSAttributedStringKey name;
    if ([value isKindOfClass:UIFont.class]) {
        name = NSFontAttributeName;
    } else if ([value isKindOfClass:UIColor.class]) {
        name = NSForegroundColorAttributeName;
    }
    [attriString addAttribute:name value:value range:NSMakeRange(0, self.placeholder.length)];
    
    self.attributedPlaceholder = attriString;
}

- (BOOL)checkString:(NSString *)string withRegexString:(NSString *)regexString {
    return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexString] evaluateWithObject:string];
}

#pragma mark - Public Method

#pragma mark - Setter

- (void)setFieldType:(ZHCFieldType)fieldType {
    
    _fieldType = fieldType;
    
    switch (_fieldType) {
        case ZHCFieldTypeDefault: {
            
            break;
        }
        case ZHCFieldTypeNumber: {
            self.keyboardType = UIKeyboardTypeNumberPad;
            break;
        }
        case ZHCFieldTypePhoneNumber: {
            self.keyboardType = UIKeyboardTypePhonePad;
            self.maxLength = 13;
            break;
        }
        case ZHCFieldTypePhoneNumberWithoutSpacing: {
            self.keyboardType = UIKeyboardTypePhonePad;
            self.maxLength = 11;
            break;
        }
        case ZHCFieldTypePassword:{
            self.secureTextEntry = YES;
            self.rightView = self.secureView;
            self.rightViewMode = UITextFieldViewModeAlways;
            self.keyboardType = UIKeyboardTypeAlphabet;
            self.maxLength = 18;
            break;
        }
        case ZHCFieldTypeMoney: {
            self.keyboardType = UIKeyboardTypeDecimalPad;
            self.maxLength = 8;
            break;
        }
        case ZHCFieldTypeIDCardNumber: {
            self.maxLength = 18;
            break;
        }
        case ZHCFieldTypeName: {
            
            break;
        }
        case ZHCFieldTypeBankCardNumber: {
            self.keyboardType = UIKeyboardTypeNumberPad;
            self.maxLength = 19;
            break;
        }
    }
}

- (void)setLeftView:(UIView *)leftView {
    [super setLeftView:leftView];
    self.bottomLineLeftPadding = 10;
    [self updateBottomLineConstraints];
}

- (void)setRightView:(UIView *)rightView {
    [super setRightView:rightView];
    self.bottomLineRightPadding = 10;
    [self updateBottomLineConstraints];
}

- (void)setLeftText:(NSString *)leftText {
    
    UILabel * textLabel = [UILabel new];
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.text = leftText;
    if (_leftTextColor) {
        textLabel.textColor = _leftTextColor;
    }
    if (_leftTextFontSize > 0) {
        textLabel.font = [UIFont systemFontOfSize:_leftTextFontSize];
    }
    
    CGFloat textWidth = [textLabel.text sizeWithAttributes:@{NSFontAttributeName : textLabel.font}].width;
    UIView * leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, textWidth + 21, self.bounds.size.height)];
    
    [leftView addSubview:textLabel];
    [self setLeftViewConstraints:textLabel withLeftView:leftView];
    
    self.leftView = leftView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setLeftImageName:(NSString *)leftImageString {
    
    UIImage * image = [UIImage imageNamed:leftImageString];
    UIImageView * subView = [[UIImageView alloc] initWithImage:image];
    
    UIView * leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width + 20, self.bounds.size.height)];
    
    [leftView addSubview:subView];
    [self setLeftViewConstraints:subView withLeftView:leftView];
    
    self.leftView = leftView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setLeftImage:(UIImage *)leftImage {
    
    UIImageView * subView = [[UIImageView alloc] initWithImage:leftImage];
    
    UIView * leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftImage.size.width + 20, self.bounds.size.height)];
    
    [leftView addSubview:subView];
    [self setLeftViewConstraints:subView withLeftView:leftView];
    
    self.leftView = leftView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setShowBottomLine:(BOOL)isShowBottomLine {
    
    _showBottomLine = isShowBottomLine;
    self.bottomLineView.hidden = !_showBottomLine;
}

- (void)setSecureButtonImages:(NSArray<UIImage *> *)secureButtonImages {
    if (secureButtonImages.count != 2) {
        return;
    }
    if ([secureButtonImages[0] isKindOfClass:[UIImage class]]) {
        [_secureButton setImage:secureButtonImages[0] forState:UIControlStateSelected];
        [_secureButton setImage:secureButtonImages[0] forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    if ([secureButtonImages[1] isKindOfClass:[UIImage class]]) {
        [_secureButton setImage:secureButtonImages[1] forState:UIControlStateNormal];
    }
}

- (void)setBottomLinePassiveColor:(UIColor *)bottomLinePassiveColor {
    _bottomLinePassiveColor = bottomLinePassiveColor;
    self.bottomLineView.backgroundColor = _bottomLinePassiveColor;
}

- (void)setBottomLineHeight:(float)bottomLineHeight {
    
    _bottomLineHeight = bottomLineHeight;
    
    [self updateBottomLineConstraints];
}

- (void)setClearButtonImage:(UIImage *)clearButtonImage {
    _clearButtonImage = clearButtonImage;
    
    UIButton *button =  [self valueForKey:@"_clearButton"];
    [button setImage:clearButtonImage forState:UIControlStateNormal];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    [self setPlaceholderAttribute:placeholderColor];
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont {
    _placeholderFont = placeholderFont;
    [self setPlaceholderAttribute:placeholderFont];
}

- (void)setPlaceholder:(NSString *)placeholder {
    [super setPlaceholder:placeholder];
    
    if (_placeholderColor) {
        [self setPlaceholderAttribute:_placeholderColor];
    }
    if (_placeholderFont) {
        [self setPlaceholderAttribute:_placeholderFont];
    }
}

#pragma mark - Getter

- (NSString *)phoneNumberString {
    
    NSString * string;
    
    if (self.fieldType == ZHCFieldTypePhoneNumber) {
        string = [self.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    return string;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [UIView new];
        _bottomLineView.backgroundColor = [UIColor colorWithRed:216/255.f green:216/255.f blue:216/255.f alpha:1];
        _bottomLineView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _bottomLineView;
}

- (UIView *)secureView {
    if (!_secureView) {
        _secureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 30)];
        
        self.secureButton.frame = CGRectMake(0, 0, 32, 30);
        [_secureView addSubview:self.secureButton];
    }
    return _secureView;
}

- (UIButton *)secureButton {
    if (!_secureButton) {
        _secureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_secureButton addTarget:self action:@selector(secureBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
        NSString *path1 = [currentBundle pathForResource:@"eye_close@2x.png" ofType:nil inDirectory:@"Resource.bundle"];
        NSString *path2 = [currentBundle pathForResource:@"eye_open@2x.png" ofType:nil inDirectory:@"Resource.bundle"];
        [_secureButton setImage:[UIImage imageWithContentsOfFile:path1] forState:UIControlStateNormal];
        [_secureButton setImage:[UIImage imageWithContentsOfFile:path2] forState:UIControlStateSelected];
        [_secureButton setImage:[UIImage imageWithContentsOfFile:path2] forState:UIControlStateSelected | UIControlStateHighlighted];
        _secureButton.adjustsImageWhenHighlighted = NO;
    }
    return _secureButton;
}

@end
