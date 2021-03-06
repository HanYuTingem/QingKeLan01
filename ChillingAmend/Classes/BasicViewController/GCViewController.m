//
//  GCViewController.m
//  dreamWorks
//
//  Created by dreamRen on 13-6-23.
//  Copyright (c) 2013年 dreamRen. All rights reserved.
//

#import "GCViewController.h"
#import "WXApi.h"
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaHandler.h"
#import "SVProgressHUD.h"
@interface GCViewController ()

{
    NSMutableArray *imageNames;
    NSMutableArray *shareTitle;
    NSMutableArray *shareName;
}
//分享面板
@property (nonatomic, strong) UIView *shadeView;

//分享所在控制器
@property (nonatomic, strong) UIViewController *delegateController;
@end

@implementation GCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
  imageNames = [[NSMutableArray alloc]init];
    shareTitle =[[NSMutableArray alloc]init];
    shareName = [[NSMutableArray alloc]init];
    
    // 自定义导航栏的bar
    self.bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 64)];
    _bar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_bar];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = YES;
    
    mainRequest = [[GCRequest alloc] init];
    mainRequest.delegate=self;
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
}

/**
 *  设置导航栏
 *
 *  @param state    0 红色 1 白色
 *  @param leftHide 是否隐藏返回
 *  @param title    标题
 */
- (void)setNavigationBarWithState:(int)state andIsHideLeftBtn:(BOOL)leftHide andTitle:(NSString *)title
{
    // 标题
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, SCREENWIDTH, 44)];
    label.font = [UIFont systemFontOfSize:17.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:61/255.0 green:66/255.0 blue:69/255.0 alpha:1.0];
    label.text = title;
    self.titleLabel = label;
    [self.bar addSubview:self.titleLabel];
    
    // 自定义导航栏的返回按钮
    if (state == 0) {
        self.titleLabel.textColor = [UIColor whiteColor];
        [self.bar setBackgroundImage:[UIImage imageNamed:@"title_red_bg.png"] forBarMetrics:UIBarMetricsDefault];
        // 扫一扫
        
        backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 33, 20, 19)];
        backImageView.image = [UIImage imageNamed:@"home_title_btn_richscan.png"];
        [self.bar addSubview:backImageView];
        
       self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.leftButton.frame=CGRectMake(0, 20, 60, 44);
//        [self.leftButton setImage:[UIImage imageNamed:@"home_title_btn_richscan.png"] forState:UIControlStateNormal];
        [self.bar addSubview:self.leftButton];
    } else {
        self.titleLabel.textColor = [UIColor colorWithRed:61/255.0 green:66/255.0 blue:69/255.0 alpha:1.0];
        [self.bar setBackgroundImage:[UIImage imageNamed:@"title_white_bg.png"] forBarMetrics:UIBarMetricsDefault];
        // 返回
        if (leftHide == NO) {
           backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 33, 10, 18)];
            backImageView.image = [UIImage imageNamed:@"title_btn_back.png"];
            [self.bar addSubview:backImageView];
            
            self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.leftButton.frame=CGRectMake(0, 20, 80, 44);
            [self.leftButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//            [self.leftButton setImage:[UIImage imageNamed:@"title_btn_back.png"] forState:UIControlStateNormal];
            [self.bar addSubview:self.leftButton];
        }
    }
}


/**
 *  返回键
 */
- (void)backButtonClick:(UIButton *)button
{
    if (mainRequest) {
        [mainRequest cancelRequest];
        [self hide];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 添加导航栏右边按钮
- (void)addRightBarButtonItemWithImageName:(NSString *)imageName andTargate:(SEL)selector andRightItemFrame:(CGRect)frame andButtonTitle:(NSString *)title andTitleColor:(UIColor *)BtnTitleColor
{
   self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightButton setExclusiveTouch:YES];
    self.rightButton.frame = frame;
    [self.rightButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self.rightButton setTitle:title forState:UIControlStateNormal];
    [self.rightButton setTitleColor:BtnTitleColor forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self.bar addSubview:self.rightButton];
}

- (void)dealloc
{
    [mainRequest release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 提示框(带风火轮的)
- (void)showMsg:(NSString *)msg
{
   
    HUD.labelText = msg;
    [HUD show:YES];
    if (msg) {

        [self performSelector:@selector(hide) withObject:nil afterDelay:1.0f];
    }
}
#pragma mark 提示框(带风火轮的)
- (void)showMsgDetailsLabelText:(NSString *)msg succeed:(void (^)())succeed
{//下面开启的GCD延迟调用和GCD异步回主线程调用，都能成功回调succeed()。不开启的话，succeed()失败
//    HUD.detailsLabelText = msg;
//    [HUD show:YES];
    [self showStringMsg:msg andYOffset:0];
    if (msg) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [self hideDetailsLabelTextSucceed:succeed];
        }) ;
//        dispatch_after(1 *DISPATCH_TIME_NOW, dispatch_get_main_queue(), ^{
//        
////        dispatch_async(dispatch_get_main_queue(), ^{
//            
////            [self performSelector:@selector(hideDetailsLabelTextSucceed:) withObject:succeed afterDelay:1.0f];
//            [self hideDetailsLabelTextSucceed:succeed];
////        });
//        }) ;
    }
}

- (void)hideDetailsLabelTextSucceed:(void (^)())succeed
{
    
    [HUD removeFromSuperview];
    [HUD hide:YES];
    HUD =nil;
    succeed();
}

#pragma mark 提示框(带风火轮的)并且自动延时隐藏
- (void)showMsg:(NSString *)msg hideTime:(NSInteger)hideTime
{
    HUD.labelText = msg;
    [HUD show:YES];
    [self performSelector:@selector(hide) withObject:nil afterDelay:hideTime];

}

#pragma mark 仅带提示信息且自动消失
- (void)showStringMsg:(NSString *)msg andYOffset:(float)y
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    // Y轴偏移
    HUD.yOffset = y;
    // 外边框
    HUD.margin = 10;
    // 大小
    HUD.minSize = CGSizeMake(150, 40);
    // 透明度
    HUD.opacity = 0.7;
    // 样式
	HUD.mode = MBProgressHUDModeText;
    // 文字
    HUD.labelText = msg;
    [self.view addSubview:HUD];
	[HUD show:YES];
	[HUD hide:YES afterDelay:1.8];
    HUD = nil;
}

#pragma mark 隐藏加载页面
- (void)hide
{
//    [HUD removeFromSuperview];
    [HUD hide:YES];
//    HUD =nil;
}

#pragma mark 分享
- (void)callOutShareViewWithUseController:(UIViewController *)addController andSharedUrl:(NSString*)url
{
    //url= @"http://qkl.sinosns.cn/";
    [UMSocialData defaultData].extConfig.qqData.title=@"来自青稞蓝的分享";//qq
    [UMSocialData defaultData].extConfig.qzoneData.title=@"来自青稞蓝的分享";//qq空
    [UMSocialData defaultData].extConfig.wechatSessionData.title=@"来自青稞蓝的分享";//微信好友
    [UMSocialData defaultData].extConfig.tencentData.title=@"来自青稞蓝的分享";//腾讯
    
    [UMSocialData defaultData].extConfig.sinaData.shareText = [NSString stringWithFormat:@"%@ %@",@"来自青稞蓝的分享",url];//微博
    [UMSocialData defaultData].extConfig.qzoneData.shareText = self.shareContent;//qq空间
    [UMSocialData defaultData].extConfig.qqData.shareText = self.shareContent;
    [UMSocialData defaultData].extConfig.wechatSessionData.shareText = self.shareContent;
    [UMSocialData defaultData].extConfig.wechatTimelineData.title= self.shareContent;
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeDefault url:nil];
    
    if (url == nil) {
        url = @"http://qkl.sinosns.cn/";
    }
    //    // 友盟分享  5328fbfa56240b9ada067458
    [UMSocialData setAppKey:@"5644063667e58ef2fc000dc2"];
    // 设置是否打开log输出，默认不打开，如果打开的话可以看到此sdk网络或者其他操作，有利于调试
    [UMSocialData openLog:YES];
    // 设置sdk所有页面需要支持屏幕方向
    [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll];
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:@"wxd3d24608e8b6ddf0" appSecret:@"d4624c36b6795d1d99dcf0547af5443d" url:url];
    //wx6d0909c80b91d3b3
    //打开新浪微博的SSO开关
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:@"1104889321" appKey:@"PifA5MEspac23ctX" url:url];
    //1101224913   sLPV0fKCWIVYXy3r
    
    if (self.shadeView) {
        [self.shadeView removeFromSuperview];
    }
    
    self.delegateController = addController;
     [imageNames removeAllObjects];
     [shareTitle removeAllObjects];
    [shareName removeAllObjects];

    
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
        [imageNames addObject:@"videodetails_pop_btn_wixin.png"];
        [imageNames addObject:@"videodetails_pop_btn_pengyouquan.png"];
        [shareTitle addObject:@"微信"];
        [shareTitle addObject:@"朋友圈"];
        [shareName addObject:UMShareToWechatSession];
        [shareName addObject:UMShareToWechatTimeline];


    }
    [imageNames addObject:@"videodetails_pop_btn_xinlang.png"];
    [shareTitle addObject:@"新浪微博"];
    [shareName addObject:UMShareToSina];

     if([QQApiInterface isQQInstalled]){
         [imageNames addObject:@"videodetails_pop_btn_qq.png"];
         [imageNames addObject:@"videodetails_pop_btn_qqkongjian.png"];
         [shareTitle addObject:@"QQ"];
         [shareTitle addObject:@"QQ空间"];
         
         [shareName addObject:UMShareToQQ];
         [shareName addObject:UMShareToQzone];

     }

    
    
    UIView *shareView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height + 242, 320, 242)];
    shareView.backgroundColor = [UIColor whiteColor];
    
    for (int i = 0; i < imageNames.count; i ++ ) {
        
        UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(80 * (i % 4), ( i  / 4 * 80), 80, 80)];
        
        UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, 50, 50)];
        [shareButton setBackgroundImage:[UIImage imageNamed:imageNames[i]] forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        shareButton.tag = i;
        [buttonView addSubview:shareButton];
        
        UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 66, 80, 14)];
        titlelabel.font = [UIFont systemFontOfSize:12.0];
        titlelabel.textAlignment = NSTextAlignmentCenter;
        titlelabel.text =shareTitle[i];
        [buttonView addSubview:titlelabel];
        
        [shareView addSubview:buttonView];
    }
    
    UIButton *cancleButton = [[UIButton alloc] initWithFrame:CGRectMake(22, 182, 320 - 44, 36)];
    cancleButton.tag = 5;
    [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancleButton setTitle:@"取消" forState:UIControlStateHighlighted];
    [cancleButton setTitleColor:[UIColor colorWithRed:184.0/255 green:6.0/255 blue:6.0/255 alpha:1.0] forState:UIControlStateNormal];
    [cancleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [cancleButton setBackgroundImage:[UIImage imageNamed:@"videodetails_pop_btn_cancel.png"] forState:UIControlStateNormal];
    [cancleButton setBackgroundImage:[UIImage imageNamed:@"videodetails_pop_btn_cancel_selected.png"] forState:UIControlStateHighlighted];
    [cancleButton addTarget:addController action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:cancleButton];
    
    self.shadeView = [[UIView alloc] initWithFrame:addController.view.bounds];
    
    UIView *blackView = [[UIView alloc] initWithFrame:addController.view.bounds];
    blackView.backgroundColor = [UIColor blackColor];
    blackView.alpha = 0.5;
    [self.shadeView addSubview:blackView];
    [self.shadeView addSubview:shareView];
    
    [addController.view addSubview:self.shadeView];
    
    
    [UIView animateWithDuration:0.6 animations:^{
        shareView.frame = CGRectMake(0, self.view.frame.size.height - 242, 320, 242);
    }];
}

// 取消分享
- (void)cancleIndicateShareView
{
    [UIView animateWithDuration:0.8 animations:^{
        //取消
        [self.shadeView removeFromSuperview];
    }];
}

// 分享按钮点击事件
- (void)shareButtonClicked:(UIButton *)btn
{
   
    
    UIImage *shareImage;
    if (self.shareImageName) {
        shareImage  = self.shareImageName;
    } else {
        shareImage = [UIImage imageNamed:@"Icon.png"];
    }

    
//    [[UMSocialControllerService defaultControllerService] setShareText:self.shareContent shareImage:shareImage socialUIDelegate:self];

    
    if (btn.tag < 5) {
        NSLog(@"------------------%@",shareName[btn.tag]);
//        UMSocialSnsPlatform *snsPlatForm = [UMSocialSnsPlatformManager getSocialPlatformWithName:shareName[btn.tag]];
//        snsPlatForm.snsClickHandler(self, [UMSocialControllerService defaultControllerService], YES);
        
        [[UMSocialControllerService defaultControllerService] setShareText:self.shareContent shareImage:shareImage socialUIDelegate:self];        //设置分享内容和回调对象
        [UMSocialSnsPlatformManager getSocialPlatformWithName:shareName[btn.tag]].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
    }
    [UIView animateWithDuration:0.8 animations:^{
        //取消
        [self.shadeView removeFromSuperview];
    }];
}

#pragma mark UMSocialUIDelegate
/**
 *      UMSResponseCodeSuccess            = 200,        //成功
 UMSREsponseCodeTokenInvalid       = 400,        //授权用户token错误
 UMSResponseCodeBaned              = 505,        //用户被封禁
 UMSResponseCodeFaild              = 510,        //发送失败（由于内容不符合要求或者其他原因）
 UMSResponseCodeArgumentsError     = 522,        //参数错误,提供的参数不符合要求
 UMSResponseCodeEmptyContent       = 5007,       //发送内容为空
 UMSResponseCodeShareRepeated      = 5016,       //分享内容重复
 UMSResponseCodeGetNoUidFromOauth  = 5020,       //授权之后没有得到用户uid
 UMSResponseCodeAccessTokenExpired = 5027,       //token过期
 UMSResponseCodeNetworkError       = 5050,       //网络错误
 UMSResponseCodeGetProfileFailed   = 5051,       //获取账户失败
 UMSResponseCodeCancel             = 5052,        //用户取消授权
 UMSResponseCodeNotLogin           = 5053,       //用户没有登录
 UMSResponseCodeNoApiAuthority     = 100031      //QQ空间应用没有在QQ互联平台上申请上传图片到相册的权限
 *
 *  @param response
 */
- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    NSLog(@"aaaaa = %d", response.responseCode);
    NSString *string;
    switch (response.responseCode) {
        case 200:
            string = @"分享成功";
            if (self.shareDelegate != nil && [self.shareDelegate respondsToSelector:@selector(shareSuccess)]) {
                [self.shareDelegate shareSuccess];
            }
            break;
        case 400:
            string = @"授权用户token错误";
            break;
        case 510:
            string = @"分享失败";
            break;
        case 5007:
            string = @"分享内容不能为空";
            break;
        case 5016:
            string = @"分享内容重复";
            break;
        case 5020:
            string = @"用户uid获取失败";
            break;
        case 5027:
            string = @"token过期";
            break;
        case 5050:
            string = @"网络错误";
            break;
        case 5051:
            string = @"获取账户失败";
            break;
        case 5052:
            string = @"取消分享";
            break;
        case 5053:
            string = @"用户没有登录";
            break;
        case 100031:
            string = @"没有上传相册权限";
            break;
        default:
            string = @"";
            break;
    }
    [self showStringMsg:string andYOffset:0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;//只支持这一个方向(正常的方向)
}
@end
