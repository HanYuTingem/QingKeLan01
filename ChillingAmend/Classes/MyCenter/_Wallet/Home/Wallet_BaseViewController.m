//
//  Wallet_BaseViewController.m
//  dreamWorks
//
//  Created by dreamRen on 13-6-23.
//  Copyright (c) 2013年 dreamRen. All rights reserved.
//

#import "Wallet_BaseViewController.h"
#import "JPCommonMacros.h"
#import "SVProgressHUD.h"
#import "UIImageScale.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
#import "UIImageView+WebCache.h"
#import "SINOAFNetWorking.h"
#import "MBProgressHUD+Add.h"
#import "ZXYWarmingView.h"
#import "AFNetworking.h"
#import "mineWalletViewController.h"

//提示框的文字的大小
#define TooltipFontSize 16
@interface Wallet_BaseViewController ()
{
    ZXYWarmingView *WarmingView;
    /** 提示框label */
    UILabel *_tooltipLabel;
}
@end

@implementation Wallet_BaseViewController
@synthesize backView;
#pragma mark -
#pragma mark - 初始化


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    return self;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [SVProgressHUD dismiss];
    AFHTTPRequestOperationManager* manager=[AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self makeTooltipSelf];
}

/** 添加提示框 */
- (void)makeTooltipSelf
{
    UILabel *label = [[UILabel alloc] init];
    label.bounds = CGRectMake(0, 0, 120, 40);
    label.center = CGPointMake(ScreenWidth * 0.5, ScreenHeight * 0.5);
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:TooltipFontSize];
    label.numberOfLines = 0;
    label.hidden = YES;
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 3;
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    [self.view addSubview:label];
    [label bringSubviewToFront:[[UIApplication sharedApplication] keyWindow]];
    _tooltipLabel = label;
}
/** 提示框 */
-(void)showMsg:(NSString *)msg
{
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:TooltipFontSize],};
    CGSize textSize = [msg boundingRectWithSize:CGSizeMake(ScreenWidth - 100, 150) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    [_tooltipLabel setBounds:CGRectMake(0, 0, textSize.width + 40, textSize.height + 20)];
    _tooltipLabel.text = msg;
    _tooltipLabel.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _tooltipLabel.hidden = YES;
    });
 
#if 0
    WarmingView.msgViewH = 35;
    [WarmingView showMsg:msg];
#endif
}

//绘制navigationController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    WarmingView = [ZXYWarmingView shareInstance];
    
// 初始化共有类
    self.navigationItem.hidesBackButton=YES;
    self.navigationController.navigationBarHidden = YES;
//  标题栏颜色
//    NSDate *stringDate = [ZHColorConversionObject dateString:@"16:00:00"];
    
    
//  标题栏ImageView
    backView = [[UIView alloc]init];
    backView.frame = CGRectMake(0, 0, ScreenWidth, 65);
    backView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    [self.view addSubview:backView];
    
//  返回按钮
    self.leftBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftBackButton.frame=CGRectMake(0, 20, 44, 44);
    [self.leftBackButton setImage:[UIImage imageNamed:@"ico_back_s@2x.png"] forState:UIControlStateHighlighted];
    [self.leftBackButton setImage:[UIImage imageNamed:@"ico_back_n@2x.png.png"] forState:UIControlStateNormal];
    self.leftBackButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    [self.leftBackButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    self.leftBackButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.leftBackButton];
    
//  界面背景View
    mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    mainView.backgroundColor = RGBACOLOR(226, 225, 232, 1);
    [self.view addSubview:mainView];
    [self.view sendSubviewToBack:mainView];
    
    //右边的按钮
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    
    _rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_rightButton setFrame:CGRectMake(ScreenWidth-54, 20, 44, 44)];
    _rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [backView addSubview:_rightButton];
      _rightButton.backgroundColor= [UIColor clearColor];
    [_rightButton addTarget:self action:@selector(rightBackCliked) forControlEvents:UIControlEventTouchUpInside];
    
    
    //标题
    _mallTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(54, 20,ScreenWidth-54*2, 44)];
    _mallTitleLabel.textAlignment = NSTextAlignmentCenter;
    _mallTitleLabel.backgroundColor = [UIColor clearColor];
    [backView addSubview:_mallTitleLabel];
    
    
    // 没有网络时  10.15 添加
    [GCUtil connectedToNetwork:^(NSString *connectedToNet) {
        if ([connectedToNet isEqualToString:NotReachable2]) {
            [MBProgressHUD showConnectNetWork:connectedToNet toView:self.view];
            return ;
        }
    }];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
}

#pragma mark - 菊花
/** 开启 */
-(void)chrysanthemumOpen{
    [SVProgressHUD show];
}

/** 关闭 */
-(void)chrysanthemumClosed{
    [SVProgressHUD dismiss];

}

#pragma mark - 按钮方法

//返回按钮
-(void)backButtonClick{
    for (UIView *view in self.view.subviews) {
         //view = nil;
        [view removeFromSuperview];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
// 右侧按钮
-(void)rightBackCliked{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** 返回首页 */
-(void)poptoWalletHomeControllet{
    NSArray  * viewControls= self.navigationController.viewControllers;
    for (UIViewController * viewControl  in viewControls){
        if([viewControl isKindOfClass:[mineWalletViewController class]]){
            [self.navigationController popToViewController:viewControl animated:YES];
            return;
        }
    }
}


//跳转登陆
- (void)showLoginLabel:(NSString *)msg withViewController:(UIViewController *)viewController
{
    viewController.view.userInteractionEnabled = NO;
    if (!_loginShowLabel) {
        _loginShowLabel = [[UILabel alloc]init];
        _loginShowLabel.frame = CGRectMake(120, 220, 80, 40);
        _loginShowLabel.font = [UIFont systemFontOfSize:17];
        _loginShowLabel.backgroundColor = [UIColor blackColor];
        _loginShowLabel.textColor = [UIColor whiteColor];
        _loginShowLabel.textAlignment = NSTextAlignmentCenter;
        _loginShowLabel.numberOfLines = 0;
        _loginShowLabel.layer.masksToBounds = YES;
        _loginShowLabel.layer.cornerRadius = 6;
    }
    CGSize size = [msg sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    _loginShowLabel.frame = CGRectMake((ScreenWidth-size.width-20)/2, 200, size.width+20, size.height+20);
    _loginShowLabel.text = msg;
    
    _tempController = viewController;
    [_tempController.view addSubview:_loginShowLabel];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loginViewAction) userInfo:nil repeats:NO];
}

//时间跳转的登录事件
- (void)loginViewAction
{
    _tempController.view.userInteractionEnabled = YES;
    [_loginShowLabel removeFromSuperview];
   // LoginViewController *loginCon = [[LoginViewController alloc]init];
    
    //[_tempController.navigationController pushViewController:loginCon animated:YES];
}


#pragma mark -
#pragma mark -分享
- (void)shareTitle:(NSString *)title withUrl:(NSString *)idStr withContent:(NSString *)content withImageName:(NSString *)imagePath withShareType:(int)shareContentType ImgStr:(NSString *)AimgStr domainName:(NSString *)AdomainName
{
    _shareContentType = shareContentType;
    if (_shareContentType != 0) {
        // 分享标题
//        [UMSocialData defaultData].extConfig.wechatTimelineData.title=@"来自乐玩互动APP客户端";
       
    }
    [UMSocialData defaultData].extConfig.qzoneData.title=@"来自乐玩互动APP客户端";//qq空间
    [UMSocialData defaultData].extConfig.qqData.title=@"来自乐玩互动APP客户端";
    [UMSocialData defaultData].extConfig.wechatSessionData.title=@"来自乐玩互动APP客户端";
    
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeDefault url:nil];
    if(imagePath.length > 0) {
//        imagePath = [NSString stringWithFormat:@"%@%@",IMG_URL,imagePath];
        NSLog(@"shareSDK.image=%@",[NSString stringWithFormat:@"%@",imagePath]);
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imagePath];
    }else {
        
    }
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:@"wx68cbf500fcda3024" appSecret:@"ef37bd35b48296dfa2de86bb38841d43" url:idStr];
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:@"1104996522" appKey:@"fLQqwcFnOaY026fi" url:idStr];

    NSString *contentTitle = @"";
    if ([content isEqualToString:@""]) {
        contentTitle = @"乐玩互动是最火爆的电视、观众互动神器，多种互动玩法，瞬间收礼收到爆！马上注册乐玩，和我一起赢取丰富奖品呦~~。加下载微门户地址（点击进入下载微门户页面，页面上有当前用户的唯一邀请码）。";
    }else{
        //设置分享内容
        contentTitle = [NSString stringWithFormat:@"%@ %@ %@",title,content,idStr];
    }
    UIImage *shareImage;
    if ([AimgStr isEqualToString:@""]) {
        shareImage = [UIImage imageNamed:@"Icon_120x120.png"];
    }else{
        NSURL * imageURL = [NSURL URLWithString:AimgStr];
        NSData * data = [NSData dataWithContentsOfURL:imageURL];
        shareImage = [UIImage imageWithData:data];
    }
    
    //设置分享
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"5644063667e58ef2fc000dc2"
                                      shareText:contentTitle
                                     shareImage:shareImage
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToQQ,UMShareToQzone,nil]
                                       delegate:self];
    
}


-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{

}

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    _isShareLoading = NO;
    [UMSocialConfig setFinishToastIsHidden:YES position:UMSocialiToastPositionCenter];
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        [self showMsg:@"分享成功"];
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        NSLog(@"分享成功");
        
        // 需要展示分享数量的界面在这里发送通知~~~~~~~
        //shareContentType 投票首页1 投票详情2  报名详情3 节目首页4 节目详情5  爆料首页6 爆料详情7 活动详情8 资讯详情9 评论分享10  个人足迹分享11  获奖详情分享12 邀请分享13 关于界面的分享14  扫一扫分享15 魔幻拼图分享16
        if (_shareContentType == 6) {//爆料首页
            [self.turnDelegate discloseIndexTurnCount];
        }else if (_shareContentType == 7) {//爆料详情
            [self.turnDelegate discloseDetailTurnCount];
        }
    }else {
        if (response.responseCode == UMSResponseCodeShareRepeated) {
            [self showMsg:@"这条信息您已分享过了"];
        }else if (response.responseCode == UMSResponseCodeCancel) {
            [self showMsg:@"您已取消此次分享"];
        }else{
            [self showMsg:@"分享失败"];
        }
    }
}
@end