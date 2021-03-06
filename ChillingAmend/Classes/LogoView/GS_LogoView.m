//  广告界面
//  GS_LogoView.m
//  Medlar_v2.0
//
//  Created by 程国帅 on 14-7-16.
//  Copyright (c) 2014年 程国帅. All rights reserved.
//
/*
 UIViewAutoresizingNone就是不自动调整。
 UIViewAutoresizingFlexibleLeftMargin 自动调整与superView左边的距离，保证与superView右边的距离不变。
 UIViewAutoresizingFlexibleRightMargin 自动调整与superView的右边距离，保证与superView左边的距离不变。
 UIViewAutoresizingFlexibleTopMargin 自动调整与superView顶部的距离，保证与superView底部的距离不变。
 UIViewAutoresizingFlexibleBottomMargin 自动调整与superView底部的距离，也就是说，与superView顶部的距离不变。
 UIViewAutoresizingFlexibleWidth 自动调整自己的宽度，保证与superView左边和右边的距离不变。
 UIViewAutoresizingFlexibleHeight 自动调整自己的高度，保证与superView顶部和底部的距离不变。
 UIViewAutoresizingFlexibleLeftMargin  |UIViewAutoresizingFlexibleRightMargin 自动调整与superView左边的距离，保证与左边的距离和右边的距离和原来距左边和右边的距离的比例不变。比如原来距离为20，30，调整后的距离应为68，102，即68/20=102/30。
 */
#import "GS_LogoView.h"
#import "UIImageView+WebCache.h"
#define TIME 4
#import "JPCommonMacros.h"
#import "BXAPI.h"

@implementation GS_LogoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {


    
    }
    return self;
}

- (void)layoutSubviews
{
    if (iPhone5) {
        self.loadingBg.image = [UIImage imageNamed:@"Default-568h@2x"];
        self.loadingImage.image = [UIImage imageNamed:@"Default-568h@2x"];
    } else {
        self.loadingBg.image = [UIImage imageNamed:@"Default"];
        self.loadingImage.image = [UIImage imageNamed:@"Default"];
        if (IOS7) {
            self.loadingBg.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight); 
            self.loadingImage.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        } else {
            self.loadingBg.frame = CGRectMake(0, 20, ScreenWidth, ScreenHeight - 20);
            self.loadingImage.frame = CGRectMake(0, 20, ScreenWidth, ScreenHeight - 20);
        }
    }
}

- (void)hiddenLoadingImage
{
        [UIView animateWithDuration:.8 animations:^{
            self.alpha = 0;
            
        }completion:^(BOOL finished) {
            [self removeFromSuperview];
            // 检测更新
            [[NSNotificationCenter defaultCenter] postNotificationName:@"checkUpdate" object:nil];
            // 提示评价
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showUsersEvaluate" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"adDisappear" object:nil];
        }];
}
 
 - (void)hiddenLoadingImage11
{
     if (self.adUrl.length > 0) {
         UIImage *image;
         if (iPhone5) {
             image = [UIImage imageNamed:@"Default-568h@2x"];
         } else {
             image = [UIImage imageNamed:@"Default"];
         }
         SDWebImageManager *manager = [SDWebImageManager sharedManager];
//         UIImage *cachedImage = [manager imageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", img_url, self.adUrl]]];
         BOOL iscachedImage = [manager cachedImageExistsForURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",img_url,self.adUrl]]];
         if (iscachedImage) {
            // self.loadingImage.image = cachedImage;
             [self.loadingImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",img_url,self.adUrl]]];
         } else {
             [self.loadingImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", img_url, self.adUrl]]
                               placeholderImage:image];
         }
         self.loadingImage.hidden = NO;
         self.loadingBg.hidden = YES;
     }
     [self performSelector:@selector(hiddenLoadingImage) withObject:self afterDelay:1]; // 广告消失时间
     
}

- (void)setImageUrl:(NSString *)imageUrl
{
    [self performSelector:@selector(hiddenLoadingImage11) withObject:self afterDelay:1]; // 启动消息时间
}

@end

