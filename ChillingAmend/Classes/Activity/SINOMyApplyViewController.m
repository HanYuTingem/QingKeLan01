//
//  SINOMyApplyViewController.m
//  LANSING
//
//  Created by yll on 15/7/20.
//  Copyright (c) 2015年 DengLu. All rights reserved.
//

#import "SINOMyApplyViewController.h"
#import "SINOMyApplyTableViewCell.h"
#import "SINOActionDetailViewController.h"
#import "MyApplyModel.h"
#import "CommomListModel.h"
#import "NoListDataView.h"
#import "MJRefresh.h"
#import "SINOActionListViewController.h"
#import "HTTPClientAPI.h"
#import "ASThemeColor.h"

@interface SINOMyApplyViewController ()
{
    __weak IBOutlet UILabel *navLineLable;
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
#pragma mark==============********//userId: 用户id，对应各自项目中存的,自行替换
    NSString *userId;
}
@property (strong, nonatomic) IBOutlet UITableView *applyTableView;
@property (nonatomic, strong) MyApplyModel *myApplyModel;
@property (nonatomic, strong) NSMutableArray *listArray; //数组
@property (nonatomic, assign) NSInteger  currentPage;//判断当前页数

@property (nonatomic, strong) NoListDataView *endView;//NoDataView

@end

@implementation SINOMyApplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#pragma mark==============********//userId: 用户id，对应各自项目中存的,自行替换
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults]objectForKey:usernameMessagePHP];
    userId = [dic objectForKey:@"id"];
    
//    [self.bar addSubview:navLineLable];
    self.listArray = [[NSMutableArray alloc]initWithCapacity:1];
    // Do any additional setup after loading the view from its nib.
    //适配时需要设置，后期可以在根试图中适配
//    titleButton.frame = CGRectMake((KProjectScreenWidth - titleButton.width)/2, titleButton.top, titleButton.width, titleButton.height);
//    [titleButton setTitle:@"我报名的" forState:UIControlStateNormal];
    [self setNavigationBarWithState:1 andIsHideLeftBtn:NO andTitle:@"我报名的"];
    if (self.whetherHaveData > 0) {
        self.applyTableView.frame = CGRectMake(0, self.bar.frame.size.height, ScreenWidth, ScreenHeight - self.bar.frame.size.height);
        [self.view addSubview:self.applyTableView];
        
        // 3.集成刷新控件
        // 3.1.下拉刷新
        [self addHeader];
        
        // 3.2.上拉加载更多
        [self addFooter];
    }else{
        [self addNotDataView];
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    if (self.whetherHaveData > 0) {
//        self.applyTableView.frame = CGRectMake(0, self.bar.frame.size.height, ScreenWidth, ScreenHeight - self.bar.frame.size.height);
//        [self.view addSubview:self.applyTableView];
//        
//        // 3.集成刷新控件
//        // 3.1.下拉刷新
//        [self addHeader];
//        
//        // 3.2.上拉加载更多
//        [self addFooter];
    }else{
        
//孙瑞 2015.9.9 单独编写函数

//        NoListDataView *endView = [[[NSBundle mainBundle]loadNibNamed:@"NoListDataView" owner:nil options:nil] lastObject];
//        endView.frame = CGRectMake(0, self.bar.frame.size.height, ScreenWidth, ScreenHeight - self.bar.frame.size.height);
//        [endView.intoActionList addTarget:self action:@selector(intoActionListButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
//        endView.oneLable.text = @"目前还没有参加任何活动哦";
//        //*活动场*引用业务平台对活动区的名称定义
//        endView.twoLable.text = @"快去*活动场*pia~pia~的参与活动吧";
//        [self.view addSubview:endView];
        [self addNotDataView];
        
//代码结束
    }
}

//孙瑞 2015.9.9 封装添加NoData代码

- (void)addNotDataView {
    self.endView = [[[NSBundle mainBundle]loadNibNamed:@"NoListDataView" owner:nil options:nil] lastObject];
    self.endView.frame = CGRectMake(0, self.bar.frame.size.height, ScreenWidth, ScreenHeight - self.bar.frame.size.height);
    [self.endView.intoActionList addTarget:self action:@selector(intoActionListButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
    self.endView.oneLable.text = @"目前还没有收藏任何活动哦";
    //*活动场*引用业务平台对活动区的名称定义
    self.endView.twoLable.text = @"快去青稞蓝pia~pia~的添加收藏吧";
    [self.view addSubview:self.endView];
}


- (void) intoActionListButtonClickAction{
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        
        if ([vc isKindOfClass:NSClassFromString(@"SINOMyActionViewController")]) {
            
            [vc removeFromParentViewController];
        }
        
        
    }
    
    [self removeFromParentViewController];
    [self.appDelegate.homeTabBarController.homeTabBar onKnowledgeButtonClicked:nil];
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)addFooter
{
    __unsafe_unretained SINOMyApplyViewController *vc = self;
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.applyTableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        self.currentPage++;
        if (self.currentPage <= [self.myApplyModel.pageCount integerValue]) {
//            NSLog(@"===========%ld",self.currentPage);
            [mainRequest requestHttpWithPost:[NSString stringWithFormat:@"%@%@",Http,SINOApplyActionList] withDict:[HTTPClientAPI mytheListOfActivitiesFormUserId:userId size:ActionSize page:[NSString stringWithFormat:@"%ld",(long)self.currentPage]]];
            [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:0];
        }else{
            [self showMsg:@"没有更多数据"];
            [self doneWithView:_footer];
        }
        
    };
    _footer = footer;
}

- (void)addHeader
{
    __unsafe_unretained SINOMyApplyViewController *vc = self;
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = self.applyTableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        self.currentPage = 1;
        // 进入刷新状态就会回调这个Block
        [mainRequest requestHttpWithPost:[NSString stringWithFormat:@"%@%@",Http,SINOApplyActionList] withDict:[HTTPClientAPI mytheListOfActivitiesFormUserId:userId size:ActionSize page:[NSString stringWithFormat:@"%ld",(long)self.currentPage]]];
        
        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是header
        [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:0.1];
        
        NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
        NSLog(@"%@----刷新完毕", refreshView.class);
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
                NSLog(@"%@----切换到：普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
                NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
                NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
    [header beginRefreshing];
    _header = header;
}

- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
//    // 刷新表格
//    [self.applyTableView reloadData];
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
}



-(void)GCRequest:(GCRequest *)aRequest Finished:(NSString *)aString
{
    aString = [aString stringByReplacingOccurrencesOfString:@"null"withString:@"\"\""];
    NSMutableDictionary *dict=[aString JSONValue];
    
    if (dict) {
        if ([[dict objectForKey:@"code"] intValue] == 0) {
            self.myApplyModel = [MyApplyModel initWithMyApplyModelInforApplyListWithJSONDic:dict];
            if (self.currentPage == 1) {
                [self.listArray removeAllObjects];
//                [self doneWithView:_header];
            }else if (self.currentPage > 1){
//                [self doneWithView:_footer];
            }
            [self.listArray addObjectsFromArray:self.myApplyModel.myApplyArray];
            // 刷新表格
            [self.applyTableView reloadData];
            
            //孙瑞 2015.9.9 根据self.listArray.count的值设置NoDataView的显示和隐藏
            
            if (self.listArray.count <= 0) {
                [self addNotDataView];
            }
            else {
                [self.endView removeFromSuperview];
            }
            
            //代码结束

            
        }else{
            switch ([[dict objectForKey:@"code"] intValue]) {
                case 100:{
                    [self showMsg:@"用户名不存在!"];
                    break;
                }
                case 102:{
                    [self showMsg:@"密码错误!"];
                    break;
                }
                case 103:{
                    [self showMsg:@"没有登录平台权限!"];
                    break;
                }
                case 203:{
                    [self showMsg:@"系统异常!"];
                    break;
                }
                case 2:{
                    [self showMsg:@"用户锁定!"];
                    break;
                }
                    
                default:{
                    [self showMsg:[dict objectForKey:@"message"]];
                    break;
                }
            }
            if (self.currentPage > 1){
                self.currentPage--;
            }
        }
    }else{
        [self showMsg:@"服务器去月球了!"];
        if (self.currentPage > 1){
            self.currentPage--;
        }
    }
}

-(void)GCRequest:(GCRequest *)aRequest Error:(NSString *)aError
{
//    [self showMsg:@"亲，网络不顺畅!"];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"listCell";
    SINOMyApplyTableViewCell *listCell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if(listCell == nil){
        listCell = [[[NSBundle mainBundle] loadNibNamed:@"SINOMyApplyTableViewCell" owner:nil options:nil] lastObject];
    }
    CommomListModel *commomModel = self.listArray[indexPath.row];
    if ([commomModel.apply_status integerValue] == 2) {
        listCell.whetherAuditLable.layer.borderColor = KOneOneSevenColor.CGColor;
        listCell.whetherAuditLable.textColor = KOneOneSevenColor;
        listCell.whetherAuditLable.text = @"审核通过";
        listCell.auditPromptLable.text = @"恭喜恭喜";
        listCell.whetherAuditLableWidth.constant = 53;
    }else if ([commomModel.apply_status integerValue] == 3){
        listCell.whetherAuditLable.layer.borderColor = KTwoFiveFourColor.CGColor;
        listCell.whetherAuditLable.textColor = KTwoFiveFourColor;
        listCell.whetherAuditLableWidth.constant = 43;
        listCell.whetherAuditLable.text = @"不匹配";
        listCell.auditPromptLable.text = @"感谢参与";
    }else{
        listCell.whetherAuditLable.layer.borderColor = KTwoFiveFiveColor.CGColor;
        listCell.whetherAuditLable.textColor = KTwoFiveFiveColor;
        listCell.whetherAuditLableWidth.constant = 43;
        listCell.whetherAuditLable.text = @"审核中";
        listCell.auditPromptLable.text = @"请耐心等待.......";
    }
    [listCell.listImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.myApplyModel.img_urlToApply,commomModel.list_url]]placeholderImage:[UIImage imageNamed:@""]];
    listCell.titleLable.text = commomModel.name;
    if ([commomModel.active_status integerValue] == 3) {
        listCell.bgView.hidden = NO;
//        listCell.userInteractionEnabled = NO;
        listCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else{
        listCell.bgView.hidden = YES;
        listCell.userInteractionEnabled = YES;
    }
    return listCell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listArray count];
//    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 99;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommomListModel *commomModel = self.listArray[indexPath.row];
    if ([commomModel.active_status integerValue] == 3) {
        [self showMsg:@"活动已结束"];
    }else{
        SINOActionDetailViewController *detailVC = [[SINOActionDetailViewController alloc]init];
        
#pragma mark==============********//userId: 用户id，对应各自项目中存的,自行替换
        NSString *userName;
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults]objectForKey:usernameMessagePHP];
        userName = [dic objectForKey:@"userName"];
        
        
        NSString *actionId = commomModel.actionId;
        
        detailVC.urlStr = [NSString stringWithFormat:@"%@?product_id=%@&id=%@&user_name=%@&user_id=%@",self.myApplyModel.active_url,LOGOAction,actionId,userName,userId];
        detailVC.shareContent = commomModel.share_content;
        detailVC.shareTitle = commomModel.name;
        detailVC.actionId = commomModel.actionId;
        detailVC.type = commomModel.type;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    
     [tableView deselectRowAtIndexPath:indexPath animated:NO]; 
}


- (void)didReceiveMemoryWarning {
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

@end
