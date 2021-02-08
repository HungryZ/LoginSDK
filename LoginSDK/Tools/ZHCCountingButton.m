//
//  ZHCCountingButton.m
//  HungryTools
//
//  Created by 张海川 on 2020/8/26.
//

#import "ZHCCountingButton.h"

#pragma mark - ZHCWeakProxy
/**
 Copy from YYTextWeakProxy
 
 A proxy used to hold a weak object.
 It can be used to avoid retain cycles, such as the target in NSTimer or CADisplayLink.
 
 sample code:
 
     @implementation MyView {
        NSTimer *_timer;
     }
     
     - (void)initTimer {
        YYTextWeakProxy *proxy = [YYTextWeakProxy proxyWithTarget:self];
        _timer = [NSTimer timerWithTimeInterval:0.1 target:proxy selector:@selector(tick:) userInfo:nil repeats:YES];
     }
     
     - (void)tick:(NSTimer *)timer {...}
     @end
 */
@interface ZHCWeakProxy : NSProxy

/**
 The proxy target.
 */
@property (nullable, nonatomic, weak, readonly) id target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
- (instancetype)initWithTarget:(id)target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
+ (instancetype)proxyWithTarget:(id)target;

@end

@implementation ZHCWeakProxy

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

+ (instancetype)proxyWithTarget:(id)target {
    return [[ZHCWeakProxy alloc] initWithTarget:target];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *null = NULL;
    [invocation setReturnValue:&null];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector:aSelector];
}

- (BOOL)isEqual:(id)object {
    return [_target isEqual:object];
}

- (NSUInteger)hash {
    return [_target hash];
}

- (Class)superclass {
    return [_target superclass];
}

- (Class)class {
    return [_target class];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_target conformsToProtocol:aProtocol];
}

- (BOOL)isProxy {
    return YES;
}

- (NSString *)description {
    return [_target description];
}

- (NSString *)debugDescription {
    return [_target debugDescription];
}

@end

#pragma mark - ZHCCountingButton

@interface ZHCCountingButton ()

@property (nonatomic, assign) int countingSeconds;
@property (nonatomic, assign) int nowSeconds;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ZHCCountingButton
/// 用于防重置处理
static NSMutableDictionary *allStamps;

- (void)dealloc {
    NSLog(@"%s", __func__);
    [_timer invalidate];
}

- (instancetype)initWithNormalTitle:(NSString *)normalTitle
                      countingTitle:(NSString *)countingTitle
                     recoveredTitle:(NSString *)recoveredTitle
                   normalTitleColor:(UIColor *)normalTitleColor
                 countingTitleColor:(UIColor *)countingTitleColor
                           fontSize:(CGFloat)fontSize
                    countingSeconds:(int)countingSeconds
                              stamp:(NSString * _Nullable)stamp {
    self = [super init];
    if (self) {
        _countingTitle = countingTitle;
        _recoveredTitle = recoveredTitle;
        _nowSeconds = countingSeconds;
        _countingSeconds = countingSeconds;
        _stamp = stamp;
        
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:fontSize];
        [self setTitleColor:normalTitleColor forState:UIControlStateNormal];
        [self setTitleColor:countingTitleColor forState:UIControlStateDisabled];
        [self setTitle:normalTitle forState:UIControlStateNormal];
        
        if (stamp && allStamps[stamp]) {
            NSTimeInterval interval = [allStamps[stamp] doubleValue];
            int speedSeconds = (int)([[NSDate date] timeIntervalSince1970] - interval);
            int leftSeconds = countingSeconds - speedSeconds;
            if (leftSeconds > 0) {
                _nowSeconds = leftSeconds;
                [self startCounting];
            }
        }
    }
    return self;
}

- (void)startCounting {
    _countingStatus = ZHCButtonCountingStatusCounting;
    self.enabled = NO;
    
    if (_stamp && _nowSeconds == _countingSeconds) {
        if (!allStamps) {
            allStamps = [NSMutableDictionary new];
        }
        allStamps[_stamp] = @([[NSDate date] timeIntervalSince1970]);
    }
    
    ZHCWeakProxy *proxy = [ZHCWeakProxy proxyWithTarget:self];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:proxy selector:@selector(countingEvent) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate date]];
}

- (void)countingEvent {
    if (--_nowSeconds == 0) {
        // 计时结束，重置时间
        _nowSeconds = _countingSeconds;
        [_timer invalidate];
        _timer = nil;
        
        self.enabled = true;
        [self setTitle:_recoveredTitle forState:UIControlStateNormal];
        
        if (_stamp) {
            [allStamps removeObjectForKey:_stamp];
            if ([allStamps allKeys].count == 0) {
                allStamps = nil;
            }
        }
        return;
    }
    
    [self setTitle:[NSString stringWithFormat:_countingTitle, _nowSeconds] forState:UIControlStateDisabled];
}

@end
