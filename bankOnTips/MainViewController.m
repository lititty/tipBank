//
//  MainViewController.m
//  bankOnTips
//
//  Created by 全宝蓝萌萌哒 on 16/6/4.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import "MainViewController.h"
#define Kheight [UIScreen mainScreen].bounds.size.height
#define Kwidth [UIScreen mainScreen].bounds.size.width

@interface MainViewController ()

@property (strong, nonatomic) MyScrollView *rollView;
@property (strong, nonatomic) UIView *centerView;
@property (strong, nonatomic) NSDictionary *dic;
@property (strong, nonatomic) NSUserDefaults *userDef;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    
}

- (NSString *)addUserName:(NSString *)str
{
    
    return [[_userDef objectForKey:@"username"] stringByAppendingString:str];
}

- (void)billBtnFunc
{
    BillListTableViewController *billListVc = [[BillListTableViewController alloc] init];
    [self.navigationController pushViewController:billListVc animated:YES];
}

- (void)payBtnFunc
{
    //如果没有绑定银行卡，要先绑定银行卡
    NSString *defaultNum = [_userDef objectForKey:[self addUserName:@"default_bank_number"]];
    if ([defaultNum isEqualToString:@""]) {
        DSToast *toast = [[DSToast alloc] initWithText:@"请先设置默认银行卡"];
        [toast showInView:self.view];
        return;
    }
    NSLog(@"默认银行卡 %@",[_userDef objectForKey:[self addUserName:@"default_bank_number"]]);
    PayView *payView = [[PayView alloc] init];
    [self.navigationController pushViewController:payView animated:YES];
}

- (void)cardBtnFunc
{
    CardsTableViewController *cardVC = [[CardsTableViewController alloc] init];
    [self.navigationController pushViewController:cardVC animated:YES];
}

- (void)creatSession
{
    
    
    //gcd异步实现
    dispatch_queue_t ql = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(ql, ^{
        //加载一个NSURL对象
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.best8023.com:8080/FingerBank/user_logout.do"]];
        
        request.HTTPMethod = @"POST";
        NSString *args = [NSString stringWithFormat:@"user_id=%@&user_token=%@",[_userDef objectForKey:@"id"],[_userDef objectForKey:@"token"]];
        request.HTTPBody = [args dataUsingEncoding:NSUTF8StringEncoding];
        
        //使用NSURLSession获取网络返回的Json并处理
        NSURLSession *session = [NSURLSession sharedSession];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data,NSURLResponse *_Nullable response,NSError *_Nullable error){
            //网络错误
            if (data == nil) {
                NSLog(@"网络错误");
                return ;
            }
            //从网络返回了Json数据，我们调用NSJSONSerialization解析它，将JSON数据转换为Foundation对象（这里是一个字典）
            _dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            //更新UI操作需要在主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([_dic objectForKey:@"status"] != nil) {
                    NSString *str = [NSString stringWithFormat:@"%@",[_dic objectForKey:@"status"]];
                    if ([str isEqualToString:@"1"]) {
                        
                        
                    } else{
                        DSToast *toast = [[DSToast alloc] initWithText:@"退出失败"];
                        [toast showInView:self.view];
                        
                        NSLog(@"退出错误，%@",[_dic objectForKey:@"msg"]);
                    }
                }
            });
        }];
        //调用任务
        [task resume];
    });
}


//定时器操作
- (void)timeFunc
{
    [_rollView roll];
}

//退出
- (void)quitFunc
{
    UIAlertController *sheetAlert = [UIAlertController alertControllerWithTitle:@"退出" message:@"您将退出指纹银行" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *quitAct = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //退出代码
        
        [self creatSession];
        
        //设登录状态为NO
        [_userDef setBool:NO forKey:@"loginState"];
        
        ViewController *loginView = [ViewController new];
        [self.navigationController presentViewController:loginView animated:NO completion:nil];
        
        DSToast *toast = [[DSToast alloc] initWithText:@"退出成功"];
        [toast showInView:loginView.view];
    }];
    [sheetAlert addAction:cancelAct];
    [sheetAlert addAction:quitAct];
    
    [self presentViewController:sheetAlert animated:YES completion:nil];
}

- (void)setupUI
{
    CGFloat edge = 20.f;
    UIColor *color = [UIColor colorWithRed:32/255.0 green:118/255.0 blue:175/255.0 alpha:1.0];
    
    self.title = @"个人中心";
    self.navigationController.navigationBar.barTintColor = color;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(quitFunc)];
    rightBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    //滚动视图
    _rollView = [[MyScrollView alloc] initWithFrame:CGRectMake(0, edge, Kwidth, Kheight*0.3)];
//    _rollView.backgroundColor = [UIColor redColor];
    _rollView.center = CGPointMake(_rollView.centerX, _rollView.centerY+64);
    //解决加入navigation里后会向下偏移的问题
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:_rollView];
    
    _centerView = [[UIView alloc] initWithFrame:CGRectMake(0, _rollView.origin.y+_rollView.frame.size.height+edge, Kwidth, 120)];
    _centerView.center = CGPointMake(self.view.centerX, _centerView.centerY);
    [self.view addSubview:_centerView];
    
    CGFloat centerViewHeight = _centerView.frame.size.height;
    
    SEL billSel = @selector(billBtnFunc);
    SEL paySel = @selector(payBtnFunc);
    SEL cardSel = @selector(cardBtnFunc);
    
    CGFloat leftEdge = (Kwidth/3.0 - Kwidth/4.0)/2.0;
    CGFloat buttonWidth = Kwidth/4.0;
    CGFloat buttonWrepWidth = Kwidth/3.0;
    
    [self creatCenterBtn:@"账单" imageName:@"bill1.png" imageHeightLight:@"bill.png" andRect:CGRectMake(leftEdge, 0, buttonWidth ,centerViewHeight)selected:billSel];
    [self creatCenterBtn:@"支付" imageName:@"pay1.png" imageHeightLight:@"pay.png" andRect:CGRectMake(leftEdge+buttonWrepWidth, 0, buttonWidth ,centerViewHeight)selected:paySel];
    [self creatCenterBtn:@"银行卡" imageName:@"card1.png" imageHeightLight:@"card.png" andRect:CGRectMake(leftEdge+buttonWrepWidth*2, 0, buttonWidth ,centerViewHeight)selected:cardSel];
    
    //设置_centerView上下横线
    [self setBorderWithView:_centerView top:YES left:NO bottom:YES right:NO borderColor:color borderWith:.5f];
    
    //设置定时器，让滚动视图自动滚动
    [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(timeFunc) userInfo:nil repeats:YES];
    
    //NSUserfault
    _userDef = [NSUserDefaults standardUserDefaults];
}


// 创建按钮

- (void)creatCenterBtn:(NSString *)title imageName:(NSString *)imageName
       imageHeightLight:(NSString *)imageHeightLight
                andRect:(CGRect)rect
               selected:(SEL)selector
{
    UIButton *button = [[UIButton alloc] initWithFrame:rect];
//    [button setBackgroundImage:[UIImage imageNamed:imageHeightLight] forState:UIControlStateHighlighted];
    //    [button setBackgroundColor:[UIColor lightGrayColor]];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIImageView *btnImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width*0.5, rect.size.width*0.5)];
    [btnImage setImage:[UIImage imageNamed:imageName]];
    //    btnImage.backgroundColor = [UIColor blueColor];
    btnImage.center = CGPointMake(rect.size.width/2.0, rect.size.height*0.35);
    [button addSubview:btnImage];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width*0.5, 10)];
    label.center = CGPointMake(btnImage.center.x, btnImage.center.y+btnImage.frame.size.height);
    //    label.backgroundColor = [UIColor blueColor];
    label.text = title;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor colorWithRed:32/255.0 green:118/255.0 blue:175/255.0 alpha:1.0];
    label.textAlignment = NSTextAlignmentCenter;
    [button addSubview:label];
    
    [_centerView addSubview:button];
    
    
}

//设置四边框
- (void)setBorderWithView:(UIView *)view top:(BOOL)top
                     left:(BOOL)left
                   bottom:(BOOL)bottom
                    right:(BOOL)right
              borderColor:(UIColor *)color
               borderWith:(CGFloat)width{
    if (top) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (left) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (bottom) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, view.frame.size.height-width, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (right) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(view.frame.size.width-width, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
