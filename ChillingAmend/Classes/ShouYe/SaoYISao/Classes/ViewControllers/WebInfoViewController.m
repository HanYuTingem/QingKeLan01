//
//  WebInfoViewController.m
//  Saoyisao
//
//  Created by 宋鑫鑫 on 14-8-28.
//  Copyright (c) 2014年 pipixia. All rights reserved.
//

#import "WebInfoViewController.h"
#import "JPCommonMacros.h"
#import "YXSqliteHeader.h"
@interface WebInfoViewController () < UMSocialUIDelegate ,UIWebViewDelegate ,UIAlertViewDelegate >

//naviView                 自定义navigationBar
{
    UIView *naviView;
}

/*
 *actionSheetView           更多选项框
 *myWebView                 网页加载页面
 *myAlert                   加载网页动画提示框
 */
@property(strong, nonatomic) IBOutlet UIView *actionSheetView;
@property(nonatomic, strong)UIWebView *myWebView;
@property(nonatomic, strong)UIAlertView *myAlert;
@property (weak, nonatomic) IBOutlet UIButton *cancleButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *allButtons;

@end

@implementation WebInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    Boolean contains = [self.historyObject.title rangeOfString:@"null"].length > 0;

    if (self.historyObject.title && !contains) {
        [self setNavigationBarWithState:1 andIsHideLeftBtn:NO andTitle:self.historyObject.title];
    } else {
        [self setNavigationBarWithState:1 andIsHideLeftBtn:NO andTitle:@"网址"];
    }
//    [backImageView setImage:[UIImage imageNamed:@"videodetails_title_btn_back.png"]];
//    backImageView.frame = CGRectMake(10, 33, 10, 18);
    [self.leftButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREENWIDTH - 34, 40, 22, 6)];
    imageView.image = [UIImage imageNamed:@"richscan_title_btn_genduo.png"];
    [self.bar addSubview:imageView];
    
    UIButton* moreButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREENWIDTH - 44, 20, 44, 44)];
    //去除多个button同事点击的效果
    [moreButton setExclusiveTouch:YES];
    [self.bar addSubview:moreButton];
    [moreButton addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
   
    
    [super viewWillAppear:YES];
}

-(void)backButtonClick{
     [self.navigationController popViewControllerAnimated:YES];
}

//自定义navibar
-(void)setWebInfoNavigationBar
{
    naviView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, IOS7_HEGHT)];
    [self.view addSubview:naviView];
    naviView.backgroundColor = [UIColor colorWithRed:(float)234/255 green:(float)96/255 blue:(float)96/255 alpha:1];
    naviView.userInteractionEnabled = YES;
    
//    UIImageView *naviImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bar_bac.png"]];
//    [naviView addSubview:naviImageView];
//    naviImageView.frame = CGRectMake(0, 20, SCREENWIDTH, IOS7_HEGHT - 19);
    
    UIImageView *BtnimageView = [[UIImageView alloc]init];
    BtnimageView.frame = CGRectMake(0, 20, 45, 45);
    BtnimageView.image = [UIImage imageNamed:@"返回按钮-IOS.png"];
    
    UIButton* backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, IOS7_HEGHT)];
    [naviView addSubview:backButton];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton addSubview:BtnimageView];
    [backButton addTarget:self action:@selector(dismissOverlayView:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* moreButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREENWIDTH - 44, 20, 44, 44)];
    [naviView addSubview:moreButton];
    [moreButton setImage:[UIImage imageNamed:@"moreBtnBgg.png"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, IOS7_HEGHT_27, 200, 25)];
    titleLabel.center = CGPointMake(self.view.center.x, IOS7_HEGHT_27 + 10 + 5)  ;
    [naviView addSubview:titleLabel];
    Boolean contains = [self.historyObject.title rangeOfString:@"null"].length > 0;
    if (self.historyObject.title && !contains) {
        titleLabel.text = self.historyObject.title;
    } else {
        titleLabel.text = @"网址";
    }
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:19.0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (UIButton *btn in self.allButtons) {
        //去除多个button同事点击的效果
        [btn setExclusiveTouch:YES];
    }
    //添加加载网页页面
    self.myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0 , IOS7_HEGHT, SCREENWIDTH, SCREENHEIGHT - 64)];
    self.myWebView.opaque = 0;
    self.myWebView.backgroundColor = [UIColor colorWithRed:248.0/255 green:248.0/255 blue:248.0/255 alpha:1.0];
    NSURL *url = [NSURL URLWithString:self.historyObject.content];
     NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
     self.myWebView.scalesPageToFit = YES;
    self.myWebView.scrollView.bounces = YES;
     self.myWebView.delegate = self;
    [self.myWebView loadRequest:request];
    [self.myWebView setUserInteractionEnabled:YES];
    [self.view addSubview:self.myWebView];
    
    [self showMsg:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ISPL"];
        }
            break;
        case 1:
        {
            NSString *str = [NSString stringWithFormat:
                             @"https://itunes.apple.com/us/app/la-jiao-quan/id715491678?ls=1&mt=8"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ISPL"];
        }
            break;
        case 2:
        {
            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"ISPL"]){
                NSString* date;
                NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"YYYYMMdd"];
                date = [formatter stringFromDate:[NSDate date]];
                NSLog(@"date %@", [date description]);
                [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"REMIND_DATE"];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
        }
            break;
    }
}

//更多点击事件
- (void)moreButtonClick
{
    [self.view bringSubviewToFront:self.actionSheetView];
    self.actionSheetView.frame = CGRectMake(0, SCREENHEIGHT - self.actionSheetView.frame.size.height- IOS7_HEGHT_20, self.actionSheetView.frame.size.width, self.actionSheetView.frame.size.height);
}

//刷新点击事件
- (IBAction)refreshButtonClick:(id)sender
{
    [self.myWebView reload];
    [self hiddenActionSheetView];
}

//复制点击事件
- (IBAction)copyAddressButtonClick:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.historyObject.content;
    [self hiddenActionSheetView];
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"提示" message:@"网址已经复制到剪切板。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [av show];
}

//sara打开网页点击事件
- (IBAction)openInSafariButtonClick:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.historyObject.content]];
    [self hiddenActionSheetView];
}

#pragma 分享
- (IBAction)shareButtonClick:(id)sender
{
#pragma mark 分享 @[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToQQ,UMShareToQzone]
    self.shareContent =  [NSString stringWithFormat:@"%@     (来自《青稞蓝APP》-扫一扫结果) http://qkl.sinosns.cn/",self.historyObject.content];
    [self callOutShareViewWithUseController:self andSharedUrl:@"http://qkl.sinosns.cn/"];
   [self hiddenActionSheetView];
}

//取消点击事件
- (IBAction)cancelButtonClick:(id)sender
{
    [self hiddenActionSheetView];
}

//隐藏选项框
- (void)hiddenActionSheetView
{
    self.actionSheetView.frame = CGRectMake(0, 800, self.actionSheetView.frame.size.width, self.actionSheetView.frame.size.height);
}
 
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hide];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hide];
    [self showStringMsg:@"网络连接失败" andYOffset:0];
}
//返回上一个界面
- (void)dismissOverlayView:(UIButton *)button
{
    if (naviView) {
        [naviView removeFromSuperview];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
