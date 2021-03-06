//  个人中心
//  PersonalCenterViewController.m
//  ChillingAmend
//
//  Created by 许文波 on 14/12/19.
//  Copyright (c) 2014年 SinoGlobal. All rights reserved.
//

#import "PersonalCenterViewController.h"
#import "EditPersonalMessageViewController.h"
#import "CollectionViewController.h"
#import "PrizeViewController.h"
#import "MessageViewController.h"
#import "ScoreExplainViewController.h"
#import "AboutUsViewController.h"
#import "UserFeedbackViewController.h"
#import "UIImageView+WebCache.h"
#import "GTMBase64.h"
#import "ITTPictureDealWithObject.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "LYQMyMallViewController.h"
#import "SINOMyActionViewController.h"
#import "HomeViewController.h"
#import "mineWalletViewController.h"

#import "MyBookSeatViewController.h"
#import "MyCouponViewController.h"
#import "MyTakeoutOrderViewController.h"
#import "SSCollectionViewController.h"
//#import "NewCollectionViewController.h"

// 提示框偏移量
#define kYOffset 0

@interface PersonalCenterViewController () <UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate>
{
    NSString *updateUrl; // 更新地址
    UIImage *backgroundImage; // 背景图片
}

@property (weak, nonatomic) IBOutlet UIScrollView *personalCenterScrollView; // 整个界面的scrollview
@property (weak, nonatomic) IBOutlet UIImageView *personalHeadImageView; // 头像
@property (weak, nonatomic) IBOutlet UIImageView *topHeadImageView; // 顶部背景图片
@property (weak, nonatomic) IBOutlet UILabel *chiliCoinLabel; // 积分
@property (weak, nonatomic) IBOutlet UILabel *nickName; // 昵称
@property (weak, nonatomic) IBOutlet UIView *topHeadBgAction;// 背景图片切换
@property (weak, nonatomic) IBOutlet UIButton *collectionBtn; // 收藏
@property (weak, nonatomic) IBOutlet UIButton *prizeBtn; // 奖品
@property (weak, nonatomic) IBOutlet UIButton *messageBtn; // 消息
@property (weak, nonatomic) IBOutlet UIButton *mallBtn; // 商城
@property (weak, nonatomic) IBOutlet UIButton *myActionBtn; // 我的活动
@property (weak, nonatomic) IBOutlet UIButton *MyBookSeatBtn; // 我的订座
@property (weak, nonatomic) IBOutlet UIButton *MyCouponBtn; // 我的优惠券

@property (weak, nonatomic) IBOutlet UIButton *MyTakeoutOrderBtn; // 我的外卖

@property (weak, nonatomic) IBOutlet UIButton *scoreBtn; // 积分
@property (weak, nonatomic) IBOutlet UIButton *aboutBtn; // 关于我们
@property (weak, nonatomic) IBOutlet UIButton *feedbackBtn; // 反馈
@property (weak, nonatomic) IBOutlet UIButton *updateBtn; // 更新
@property (weak, nonatomic) IBOutlet UIButton *login_outBtn; // 退出登录

- (IBAction)collectionAction:(id)sender; // 收藏
- (IBAction)prizeAction:(id)sender; // 奖品
- (IBAction)messageAction:(id)sender; // 消息
- (IBAction)personMallAction:(id)sender; // 我的商城
- (IBAction)myAction:(UIButton *)sender; //我的活动
- (IBAction)MyBookSeatButtonClcikAction:(id)sender; //我的订座
- (IBAction)MyCouponButtonClcikAction:(id)sender; //我的优惠券
- (IBAction)MyTakeoutOrderButtonClcikAction:(id)sender; //我的外卖
- (IBAction)scoreExplainAction:(id)sender; // 积分说明
- (IBAction)aboutUsAction:(id)sender; // 关于我们
- (IBAction)feedbackAction:(id)sender; // 意见反馈
- (IBAction)checkUpdateAction:(id)sender; // 检查更新
- (IBAction)loginOutAction:(id)sender; // 退出登录

@end

@implementation PersonalCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.bar.hidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    // 设置圆角 头像
    [_personalHeadImageView.layer setCornerRadius:_personalHeadImageView.frame.size.width/2];
    [_personalHeadImageView.layer setMasksToBounds:YES];
    [_personalHeadImageView.layer setBorderWidth:2];
    [_personalHeadImageView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    // 多个button同时点击
    _collectionBtn.exclusiveTouch = YES;
    _messageBtn.exclusiveTouch = YES;
    _prizeBtn.exclusiveTouch = YES;
    _mallBtn.exclusiveTouch = YES;
    _myActionBtn.exclusiveTouch = YES;
    _MyBookSeatBtn.exclusiveTouch = YES;
    _MyCouponBtn.exclusiveTouch = YES;
    _MyTakeoutOrderBtn.exclusiveTouch = YES;
    _scoreBtn.exclusiveTouch = YES;
    _aboutBtn.exclusiveTouch = YES;
    _feedbackBtn.exclusiveTouch = YES;
    _updateBtn.exclusiveTouch = YES;
    _login_outBtn.exclusiveTouch = YES;
    // 背景图片添加手势
    [self headerImageViewAddTapGesture];
    // 头像添加手势
    [self personalHeadImageViewAddTapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.personalCenterScrollView setContentOffset:CGPointMake(0, 0)];
    self.navigationController.navigationBarHidden = YES;
    // 界面scrollview大小
    [_personalCenterScrollView setContentSize:CGSizeMake(self.view.frame.size.width, 640 - 90)];
    [self.appDelegate.homeTabBarController showTabBarAnimated:YES];
    // 请求用户数据
    if (mainRequest.tag != 111) {
        [self sendRequest];
    }
    
    [super viewWillAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if (mainRequest) {
        [mainRequest cancelRequest];
        [self hide];
    }
}

#pragma mark 请求用户数据
- (void)sendRequest
{
    if (![GCUtil connectedToNetwork]) {
        [self showStringMsg:@"网络连接失败" andYOffset:0];
    } else {
        [mainRequest requestHttpWithPost:CHONG_url withDict:[BXAPI personMessageUserId:kkUserId]];
        [self showMsg:nil];
        mainRequest.tag = 99;
    }
}

#pragma mark 设置用户信息
- (void)setUserMessage
{
    [_topHeadImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", img_url, kkUserbackground]] placeholderImage:[UIImage imageNamed:@"common_background.png"]];
    [_personalHeadImageView setImageWithURL:[NSURL URLWithString:kkUserImage] placeholderImage:[UIImage imageNamed:@"defaultimgmy_img.png"]];
    _nickName.text = kkUserNickName;
    _chiliCoinLabel.text = [GCUtil getlajiaobiJinfen] ? [GCUtil getlajiaobiJinfen] : [NSString stringWithFormat:@"0"];;
}

#pragma mark 隐藏tabBar
- (void) hideTabBar
{
    [self.appDelegate.homeTabBarController hideTabBarAnimated:YES];
}

#pragma mark 状态栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark headerImageView添加手势
- (void)headerImageViewAddTapGesture
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(theHeadGesture:)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [_topHeadBgAction setUserInteractionEnabled:YES];
    [_topHeadBgAction setExclusiveTouch:YES];
    [_topHeadBgAction addGestureRecognizer:tap];
}

#pragma mark 头像添加手势
- (void)personalHeadImageViewAddTapGesture
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(personalHeadGesture:)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [_personalHeadImageView setUserInteractionEnabled:YES];
    [_personalHeadImageView setExclusiveTouch:YES];
    [_personalHeadImageView addGestureRecognizer:tap];
}

#pragma mark 点击背景图片调用的方法
- (void)theHeadGesture:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"上传图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择" ,nil];
    actionSheet.tag = 100;
    [actionSheet showInView:self.view];
}

#pragma mark 点击头像调用的方法
- (void)personalHeadGesture:(id)sender
{
    // 跳转编辑资料界面
    EditPersonalMessageViewController *editPersonMessage = [[EditPersonalMessageViewController alloc] initWithNibName:@"EditPersonalMessageViewController" bundle:nil];
    [self hideTabBar];
    [self.navigationController pushViewController:editPersonMessage animated:YES];
}

#pragma mark actionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // for iphone
        [self snapImage];
    } else if (buttonIndex ==1) {
        [self pickImage];
    }
}

#pragma mark 拍照
- (void) snapImage
{
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerImage.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage,nil];
        
    }
    pickerImage.delegate = self;
    pickerImage.allowsEditing = YES; // 自定义照片样式
    [self presentViewController:pickerImage animated:YES completion:nil];
}

#pragma mark 相册选取
- (void) pickImage
{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        ipc.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:ipc.sourceType];
    }
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark Delegate method UIImagePickerControllerDelegate
// 图像选取器的委托方法，选完图片后回调该方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    // 当图片不为空时显示图片并保存图片
    if (image != nil) {
        // 压缩图片
        CGSize imagesize = image.size;
        imagesize.height = 313;
        imagesize.width = 313;
        //对图片大小进行压缩--
        image = [ITTPictureDealWithObject scaleToSize:image size:imagesize];
        backgroundImage = image;
        NSData *imageData = UIImageJPEGRepresentation(image, 0.00001);
        if (image == nil)
        {
            image = [UIImage imageWithData:imageData];
            return ;
        }
        // 转化为data
        NSData *data;
        // 判断图片是不是png格式的文件
        if (UIImagePNGRepresentation(image)) {
            //返回为png图像。
            data = UIImagePNGRepresentation(image);
        } else {
            //返回为JPEG图像。
            data = UIImageJPEGRepresentation(image, 1.0);
        }
        // 上传头像
        [self requestChangeBackgroundImage:data];
    }
    //关闭相册界面
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark 修改背景
- (void) requestChangeBackgroundImage:(NSData*)data
{
    if ([GCUtil connectedToNetwork]) {
        [self showMsg:@"上传中"];
        mainRequest.tag = 111;
        [mainRequest requestHttpWithPost:CHONG_url withDict:[BXAPI changeBgImageUserId:kkUserId andBackground:[GTMBase64 stringByEncodingData:data] andType:@"1"]];
    } else [self showStringMsg:@"网络连接失败" andYOffset:0];
}

#pragma mark 检查更新
- (void) requestCheckUpdate
{
    if ([GCUtil connectedToNetwork]) {
        [self showMsg:nil];
        mainRequest.tag = 112;
        [mainRequest requestHttpWithPost:CHONG_url withDict:[BXAPI checkUpdateType:@"1"]];
    } else [self showStringMsg:@"网络连接失败" andYOffset:0];
}

#pragma mark GCRequestDelegate
- (void)GCRequest:(GCRequest *)aRequest Finished:(NSString *)aString
{
    NSLog(@"personcenter = %@", aString);
    [self hide];
    NSMutableDictionary *dict = [aString JSONValue];
    if ( !dict ) {
        [self showStringMsg:@"网络连接失败" andYOffset:0];
        return;
    }
    if ([[dict objectForKey:@"code"] isEqual:@"0"]) {
        switch (mainRequest.tag) {
            case 111: // 修改背景
                // 设置单利 保存数据 模型 NSUserDefaults
                [kkUserInfo resetInfo:dict];
                [BSaveMessage saveUserMessage:dict];
                [GCUtil saveLajiaobijifenWithJifen:[dict objectForKey:@"jifen"]];
                mainRequest.tag = 0;
//                [self setUserMessage];
                _topHeadImageView.image = backgroundImage;
                [self showStringMsg:[dict valueForKey:@"message"] andYOffset:kYOffset];
                break;
            case 112: // 检查更新
                {
                    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
                    NSString *VersionKey = [infoDict objectForKey:@"CFBundleShortVersionString"];
                    if ([VersionKey compare:[dict valueForKey:@"version"] options:NSNumericSearch] == NSOrderedAscending) {
                        updateUrl = [dict objectForKey:@"url"];
                        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:@"现在有新版本"
                                                                       delegate:self
                                                              cancelButtonTitle:@"不更新"
                                                              otherButtonTitles:@"现在更新", nil];
                        alert.delegate = self;
                        [alert show];
                    } else {
                        [self showStringMsg:@"已经是最新版本" andYOffset:kYOffset];
                    }
                }
                break;
            case 99: // 用户数据
                    // 设置单利 保存数据 模型 NSUserDefaults
                    [kkUserInfo resetInfo:dict];
                    [BSaveMessage saveUserMessage:dict];
                    [GCUtil saveLajiaobijifenWithJifen:[dict objectForKey:@"jifen"]];
                    [self setUserMessage];
                break;
            default:
                break;
        }
    } else [self showStringMsg:[dict valueForKey:@"message"] andYOffset:kYOffset];
}

- (void)GCRequest:(GCRequest *)aRequest Error:(NSString *)aError
{
    [self hide];
    NSLog(@"%@", aError);
    mainRequest.tag = 0;
    [self showStringMsg:@"网络连接失败！" andYOffset:kYOffset];
}

#pragma mark UIAlertView 代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) { // 更新
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:updateUrl]];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark  收藏
- (IBAction)collectionAction:(id)sender
{
    CollectionViewController *collectionView = [[CollectionViewController alloc] init];
//    SSCollectionViewController *collectionView = [[SSCollectionViewController alloc] init];
//    NewCollectionViewController *collectionView = [[NewCollectionViewController alloc] init];
    [self hideTabBar];
    [self.navigationController pushViewController:collectionView animated:YES];
}

#pragma mark 奖品
- (IBAction)prizeAction:(id)sender
{
    PrizeViewController *prizeView = [[PrizeViewController alloc] init];
    [self hideTabBar];
    [self.navigationController pushViewController:prizeView animated:YES];
}

#pragma mark 消息
- (IBAction)messageAction:(id)sender
{
    [self hideTabBar];
    MessageViewController *message = [[MessageViewController alloc] init];
    [self.navigationController pushViewController:message animated:YES];
}

#pragma mark 我的商城
- (IBAction)personMallAction:(id)sender
{
    LYQMyMallViewController * mymall = [[LYQMyMallViewController  alloc] initWithNibName:@"LYQMyMallViewController" bundle:nil];
    [self.appDelegate.homeTabBarController hideTabBarAnimated:YES];
    [self.navigationController pushViewController:mymall animated:YES];
}
#pragma mark --我的钱包
- (IBAction)qianbao:(id)sender {
    
    if ([kkUserId isEqual:@""] || !kkUserId) {
        //去登陆
        LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        login.viewControllerIndex = 4;
        [self.navigationController pushViewController:login animated:YES];
    }
    mineWalletViewController *mineView = [[mineWalletViewController alloc] init];
    [self.appDelegate.homeTabBarController hideTabBarAnimated:YES];
    [self.navigationController pushViewController:mineView animated:YES];
}

#pragma mark 我的活动
- (IBAction)myAction:(UIButton *)sender {
    
    SINOMyActionViewController *mymall = [[SINOMyActionViewController alloc]init];
    [self.appDelegate.homeTabBarController hideTabBarAnimated:YES];
    [self.navigationController pushViewController:mymall animated:YES];
}

#pragma mark 食物模块
- (IBAction)foodButtonClcikAction:(id)sender {
    [self hideTabBar];
    HomeViewController * home = [[HomeViewController alloc] init];
    [self.navigationController pushViewController:home animated:YES];
}

#pragma mark 我的订座
- (IBAction)MyBookSeatButtonClcikAction:(id)sender {
    [self hideTabBar];
    MyBookSeatViewController * vc = [[MyBookSeatViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark 我的优惠券
- (IBAction)MyCouponButtonClcikAction:(id)sender {
    [self hideTabBar];
    MyCouponViewController * vc = [[MyCouponViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 我的外卖
- (IBAction)MyTakeoutOrderButtonClcikAction:(id)sender {
    [self hideTabBar];
    MyTakeoutOrderViewController * vc = [[MyTakeoutOrderViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 积分说明
- (IBAction)scoreExplainAction:(id)sender
{
    ScoreExplainViewController *scoreExplain = [[ScoreExplainViewController alloc] init];
    [self.navigationController pushViewController:scoreExplain animated:YES];
    [self hideTabBar];
}

#pragma mark 关于我们
- (IBAction)aboutUsAction:(id)sender
{
    AboutUsViewController *aboutUs = [[AboutUsViewController alloc] init];
    [self.navigationController pushViewController:aboutUs animated:YES];
    [self hideTabBar];
}

#pragma mark 意见反馈
- (IBAction)feedbackAction:(id)sender
{
    [self hideTabBar];
    UserFeedbackViewController *userFeed = [[UserFeedbackViewController alloc] init];
    [self.navigationController pushViewController:userFeed animated:YES];
    
}

#pragma mark 检查更新
- (IBAction)checkUpdateAction:(id)sender
{
    [self requestCheckUpdate];
}

#pragma mark 退出登录
- (IBAction)loginOutAction:(id)sender
{
    // 点击退出登录
    [kkUserInfo clearInfo];
    [BSaveMessage clear];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:B_JIFEN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserIDKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LoginPhoneKey];
    [self.appDelegate.homeTabBarController.homeTabBar onHomePageButtonClicked:nil];
}
@end
