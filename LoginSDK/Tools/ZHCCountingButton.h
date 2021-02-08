//
//  ZHCCountingButton.h
//  HungryTools
//
//  Created by 张海川 on 2020/8/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHCCountingButton : UIButton

typedef NS_ENUM(NSInteger, ZHCButtonCountingStatus) {
    /// 未触发倒计时状态
    ZHCButtonCountingStatusNormal,
    /// 正在倒计时
    ZHCButtonCountingStatusCounting,
    /// 倒计时结束
    ZHCButtonCountingStatusRecovered,
};

@property (nonatomic, assign) ZHCButtonCountingStatus countingStatus;

@property (nonatomic, copy) NSString *recoveredTitle;

@property (nonatomic, copy) NSString *countingTitle;

/// 用于防重置标记，每个按钮不同
@property (nonatomic, copy) NSString *stamp;

// countingTitle 需要包含%d，比如@"%d秒"
- (instancetype)initWithNormalTitle:(NSString *)normalTitle
                      countingTitle:(NSString *)countingTitle
                     recoveredTitle:(NSString *)recoveredTitle
                   normalTitleColor:(UIColor *)normalTitleColor
                 countingTitleColor:(UIColor *)countingTitleColor
                           fontSize:(CGFloat)fontSize
                    countingSeconds:(int)countingSeconds
                              stamp:(NSString * _Nullable)stamp;

- (void)startCounting;

@end

NS_ASSUME_NONNULL_END
