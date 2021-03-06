//
//  GCUtil.m
//  iMagazine2
//
//  Created by dreamRen on 12-11-16.
//  Copyright (c) 2012年 iHope. All rights reserved.
//

#import "GCUtil.h"
#import "Reachability.h"
#include <CommonCrypto/CommonDigest.h>
#import <netdb.h>
#import <QuartzCore/QuartzCore.h>
#import "DXAlertView.h"
#import "JPCommonMacros.h"

@implementation GCUtil
+(void)connectedToNetwork:(connectedToNetBlock)type{
    
    [[AFNetworkReachabilityManager sharedManager]startMonitoring ];
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSString *Network = @"";
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
            {
                Network = NotReachable;
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                Network = WIFI;
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                Network = WWAN;
                break;
            }
            case AFNetworkReachabilityStatusUnknown:
            {
                NSLog(@"AFNetworkReachabilityStatusUnknown");
                break;
            }
            default:
                break;
        }
        
        type(Network);
    } ];
}


+ (NETWORK_TYPE)getNetworkTypeFromStatusBar
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSNumber *dataNetworkItemView = nil;
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]])     {
            dataNetworkItemView = subview;
            break;
        }
    }
    NETWORK_TYPE nettype = NETWORK_TYPE_NONE;
    NSNumber * num = [dataNetworkItemView valueForKey:@"dataNetworkType"];
    nettype = [num intValue];
    return nettype;
}

//显示提示框,只有一个确定按钮
+(void)showInfoAlert:(NSString*)aInfo{
    UIAlertView *tAlert=[[UIAlertView alloc] initWithTitle:@"提示" message:aInfo delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [tAlert show];
}

//是否连网
+ (BOOL)connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return NO;
    }
    
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}

// 判断手机号码格式是否正确
+ (BOOL)ThePhoneNumber:(NSString *)string
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((14[0-9])|(13[0-9])|(15[^4,\\D])|(17[0-9])|(18[0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:string];
}

// 邮箱格式
+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

// 获取随机位数
+ (NSString *)randomStrNumStr:(NSString*)numStr
{
    //自动生成随机密码
    NSTimeInterval random = [NSDate timeIntervalSinceReferenceDate];
    NSString *randomString = [NSString stringWithFormat:numStr,random];
    NSString *randomNick = [[randomString componentsSeparatedByString:@"."]objectAtIndex:1];
    NSLog(@"randompassword:%@",randomNick);
    return randomNick;
}

//正则判断中文英文，及数字
+ (BOOL)isTextFiledNumber:(NSString*)textField andCount:(NSInteger)count
{
    NSString * str = [NSString stringWithFormat:@"^\\w{0,%ld}$", (long)count];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",str];
    if ([predicate evaluateWithObject:textField]== YES) {
        return YES;
    }
    else{
        return NO;
    }
}

// 仅支持输入2~8位中、英文字符
+ (BOOL)isTextFiledChinaAndEnglish:(NSString*)textField
{
    NSString *strRegex = @"^[\\w]{2,12}|[\u4e00-\u9fa5]{2,8}$";
    NSPredicate *strTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strRegex];
    return [strTest evaluateWithObject:textField];
    
}


//由英文、字母或数字组成 6-18位
+ (BOOL)isEvaluateWithObject:(NSString*)textField
{
    NSString * regex = @"^[A-Za-z0-9_]{6,18}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:textField];
}

// 判断登录账号是否正确
+ (BOOL)isMobileNumberOrEmail:(NSString*)loginString
{
    if (loginString.length == 11) {
        if ([self ThePhoneNumber:loginString]) {
            return YES;
        } else return NO;
    } else {
        if ([self isValidateEmail:loginString]) {
            return YES;
        } else return NO;
    }
}

//***需要过滤的特殊字符：~￥#&#&amp;*&#&amp;*&lt;&#&amp;*&lt;&gt;《》()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&#￥&amp;*（）——+|《》$_€。
+ (BOOL)isIncludeSpecialCharact:(NSString *)str
{
    NSRange urgentRange = [str rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @"~￥#&*<>《》()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&*（）——+|《》$_€"]];
    if (urgentRange.location == NSNotFound)
    {
        return NO;
    }
    return YES;
}


+ (void)showDxalertTitle:(NSString*)title andMessage:(NSString*)message cancel:(NSString*)cancel andOk:(NSString*)amend
{
    DXAlertView *alert = [[DXAlertView alloc] initWithnoTitle:title contentText:message leftButtonTitle:cancel rightButtonTitle:amend];
    [alert show];
    alert.rightBlock = ^() {
        NSLog(@"right button clicked");
    };
    alert.dismissBlock = ^() {
        NSLog(@"Do something interesting after dismiss block");
    };
    
}

/**
 *  游戏提示框
 *
 *  @param title   标题（空或nil的时候是没有中奖）
 *  @param content 内容
 *  @param cancel  取消 （空或nil的时候是没有）
 *  @param amend   确认
 */
+ (GameAlertView*) showGameAlertTitle:(NSString*)title andContent:(NSString*)content cancel:(NSString*)cancel andOK:(NSString*)amend
{
    // 没中奖
    //    GameAlertView *alert = [[GameAlertView alloc] initWithTitle:nil contentText:@"没中奖!\n可以再次参与获得抽奖机会" leftButtonTitle:nil rightButtonTitle:@"确认"];
    // 中奖
    //    GameAlertView *alert = [[GameAlertView alloc] initWithTitle:@"太给力了！亲~" contentText:@"获得30积分" leftButtonTitle:nil rightButtonTitle:@"确认"];
    GameAlertView *alert = [[GameAlertView alloc] initWithTitle:title contentText:content leftButtonTitle:cancel rightButtonTitle:amend];
    [alert show];
    return alert;
}

//存贮积分
+ (void)saveLajiaobijifenWithJifen:(id)jifen
{
    if (jifen && ![jifen isKindOfClass:[NSNull class]]) {
        jifen = [NSString stringWithFormat:@"%@",jifen];
    }else{
        jifen = @"0";
    }
    if ([jifen isEqual:@""]) {
        jifen = @"0";
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:jifen forKey:B_JIFEN];
    [defaults synchronize];
}

// 获取积分
+ (NSString*)getlajiaobiJinfen
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:B_JIFEN];
    
}

//String宽度
+ (CGFloat)widthOfString:(NSString *)string withFont:(int)font {
    //    CGSize labsize = [string sizeWithFont:[UIFont systemFontOfSize:font] constrainedToSize:CGSizeMake(275, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    CGRect textRect = [string boundingRectWithSize:CGSizeMake(275, 9999)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]}
                                           context:nil];
    
    CGSize size = textRect.size;
    
    return size.width;
}

#pragma mark 积分
/**
 *  积分
 *
 *  @param coin      积分
 *  @param chiliView 积分三个字的view
 *  @param coinView  需要加积分图片的view
 *  @param imgArray  图片数组(0.png)
 */
+ (void) changeChiliCoinView:(int)coin andCoinImageView:(UIView*)coinView andImageArray:(NSArray*)imgArray
{
    for (UIView *v in coinView.subviews) {
        if ([v isKindOfClass:[UIImageView class]]) {
            [v removeFromSuperview];
        }
    }
    NSMutableArray *numArray = [[NSMutableArray alloc] initWithCapacity:50];
    int j ;
    while(1)
    {
        j = coin % 10; // 取到最低位（余数）
        coin= coin / 10; // 右移一位
        [numArray addObject:[NSString stringWithFormat:@"%d", j]];
        if(coin == 0)
            break;
    }
    UIImageView *chiliView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 49, 16)];
    [coinView addSubview:chiliView];
    [chiliView setImage:[UIImage imageNamed:@"zhuanpan_content_img_lajiaobi.png"]];
    chiliView.frame = CGRectMake((CGRectGetWidth(coinView.frame) - (10 * numArray.count + CGRectGetWidth(chiliView.frame) + 5)) / 2 , ORIGIN_Y(chiliView), CGRectGetWidth(chiliView.frame), CGRectGetHeight(chiliView.frame));
    for (int k = (int)[numArray count] - 1; k >= 0; k --) {
        int num = [[numArray objectAtIndex:k] intValue];
        UIImageView *numImg = [[UIImageView alloc] initWithFrame:CGRectMake((ORIGIN_X(chiliView) + CGRectGetWidth(chiliView.frame) + 5) + 10 *(numArray.count - k - 1), 9, 10, 13)];
        [numImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", [imgArray objectAtIndex:num]]]];
        [coinView addSubview:numImg];
    }
}

// 游戏部分网络连接出错  无兑换情况下的弹窗
+ ( GameAlertView * )showGameErrorMessageWithContent:(NSString *)content
{
    GameAlertView *alert = [[GameAlertView alloc] initGameErrorMessageWithContent:content];
    [alert show];
    
    return alert;
}

#pragma mark 改变frame的大小
/**
 *
 *
 *  @param label 要改变fram的label
 *  @param size  最大宽高
 *  @param font  字体大小
 *
 *  @return 改变frame的大小
 */
+ (CGRect) changeLabelFrame:(UILabel*)label andSize:(CGSize)size andFontSize:(UIFont*)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize actualSize = [label.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    CGRect frame = CGRectMake(ORIGIN_X(label), ORIGIN_Y(label), ceil(actualSize.width), ceil(actualSize.height));
    return frame;
}

/**
 *
 *
 *  @param text 文字
 *  @param size 大小
 *  @param font 字体大小
 *
 *  @return CGSize
 */
+ (CGSize)changeSize:(NSString*)text andSize:(CGSize)size andFontSize:(CGFloat)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:font], NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize actualSize = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return actualSize;
}


#pragma mark 限制字符长度，中文两个字符，英文一个字符
+ (BOOL)convertToBool:(NSString*)strtemp andLength:(NSInteger)length
{
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i = 0; i < [strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding];i++) {
        if (*p) {
            p++;
            strlength++;
        } else {
            p++;
        }
    }
    
    if (strlength > length) {
        return  NO;
    } else {
        return  YES;
    }
}

+(UIImage *)getResizebalImageFormOldImageWithImageName:(NSString *)imageName andEdgeInsets:(UIEdgeInsets)edgeInset andState:(int)state
{
    UIImage* image = [UIImage imageNamed:imageName];
    //    resizableImage 就是九切片过后的 新图片
    
    UIImageResizingMode mode;
    if (state == 0) {
        mode = UIImageResizingModeStretch;
    }else{
        mode = UIImageResizingModeTile;
    }
    UIImage* resizableImage = [image
                               resizableImageWithCapInsets:edgeInset
                               resizingMode:mode];
    //UIImageResizingModeStretch:  变化时拉伸
    //    //
    //    UIImageResizingModeTile :   变化时复制
    
    return resizableImage;
}


//MD5加密
+(NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

//把时间嘬转换为时间的格式
+(NSString*)getDataZuoGeshi:(NSString*)timeDate
{
    double create = [timeDate doubleValue];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:create];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyy年MM月dd日"];
    NSString *showtimeNew = [formatter1 stringFromDate:confromTimesp];
    return showtimeNew;
    
}

//时间改变后的值
+(NSString*)getDateChanged:(NSString*)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"y-M-d HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    NSLog(@"timeSp:%@",timeSp); //时间戳的值
    [dateFormatter setDateFormat:@"y年M月d日"];
    NSString *str = [dateFormatter stringFromDate:date];
    
    return str;
}

// 正则判断手机号码地址格式
+(BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,178,182,187,188
     * 联通：130,131,132,152,155,156,176,185,186
     * 电信：133,1349,153,177,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|4[7]|5[0-35-9]|7[0678]|8[0-9])\\d{8}$";
    //NSString * MOBILE = @"^1(70|3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(78|34[0-8]|(3[5-9]|5[017-9]|8[278]|78)\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(76|3[0-2]|5[256]|8[56]|76)\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 177,133,1349,153,180,189
     22         */
    NSString * CT = @"^1((77|33|53|8[039])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+  (int)convertToInt:(NSString*)strtemp {
    
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
    
}

//TextView行间距
+(void)lineSpacingTextView:(UITextView *)textView fontInt:(int )fontInt{
    //    textview 改变字体的行间距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = fontInt;// 字体的行间距
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:16],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    textView.attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:attributes];
}

@end