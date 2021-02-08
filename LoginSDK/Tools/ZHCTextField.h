//
//  ZHCTextField.h
//  HungryTools
//
//  Created by 张海川 on 2019/4/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZHCFieldType) {
    ZHCFieldTypeDefault,
    ZHCFieldTypeNumber,
    ZHCFieldTypePhoneNumber,
    ZHCFieldTypePhoneNumberWithoutSpacing,
    ZHCFieldTypePassword,                   // 半角字符 包括字母，数字，标点符号
    ZHCFieldTypeMoney,
    ZHCFieldTypeIDCardNumber,
    ZHCFieldTypeName,                       // 人名 可以输入汉字、英文字母和数字
    ZHCFieldTypeBankCardNumber,
};

@interface ZHCTextField : UITextField

@property (nonatomic, assign) ZHCFieldType  fieldType;

/// 删除空格后的手机号码，在 ZHCFieldType 为 ZHCFieldTypePhoneNumber 时有效。
@property (nonatomic, strong) NSString *    phoneNumberString;

/// 文本长度限制
@property (nonatomic, assign) int           maxLength;

/// 左视图文字颜色，需在leftText之前赋值
@property (nonatomic, strong) UIColor *     leftTextColor;

/// 左视图文字颜色，需在leftText之前赋值
@property (nonatomic, assign) float         leftTextFontSize;

@property (nonatomic, copy) NSString *      leftText;

@property (nonatomic, copy) NSString *      leftImageName;

@property (nonatomic, strong) UIImage *     leftImage;



/// 密码明暗文切换图片数组，需包含两个UIImage，第一个代表明文，第二个代表暗文。
@property (nonatomic, strong) NSArray<UIImage *> *  secureButtonImages;
/// clearButton 按钮图片
@property (nonatomic, strong) UIImage *     clearButtonImage;


@property (nonatomic, assign) BOOL          showBottomLine;
/// 正在输入时下划线颜色
@property (nonatomic, strong) UIColor *     bottomLineActiveColor;
/// 失去焦点时下划线颜色
@property (nonatomic, strong) UIColor *     bottomLinePassiveColor;
/// 下划线高度，默认0.5
@property (nonatomic, assign) float         bottomLineHeight;



@property (nonatomic, strong) UIColor *     placeholderColor;
@property (nonatomic, strong) UIFont *      placeholderFont;

@end

NS_ASSUME_NONNULL_END
