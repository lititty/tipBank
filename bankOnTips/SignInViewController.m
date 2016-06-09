//
//  SignInViewController.m
//  bankOnTips
//
//  Created by 全宝蓝萌萌哒 on 16/6/4.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import "SignInViewController.h"
#define Kheight [UIScreen mainScreen].bounds.size.height
#define Kwidth [UIScreen mainScreen].bounds.size.width
#define barHeight 44.f

enum ErrorState{
    nameEmpty,   //用户名为空
    firstPwdEmpty,  //密码为空
    secondPwdEmpty,  //确认密码为空
    diffOfPwd,    //确认密码不一致
    success       //填写没有错误
};

@interface SignInViewController () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>


{
    NSString *strUuid_;
    enum ErrorState state;
}

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *CellTfArray;
@property (strong, nonatomic) NSUserDefaults *userDef;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_tableView endEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return barHeight*1.3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(2*barHeight +0.5*barHeight, 0, cell.size.width-2*barHeight, cell.size.height)];
    tf.centerY = barHeight*0.65;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @" 账　号";
            tf.keyboardType = UIKeyboardTypeEmailAddress;
            break;
        case 1:
            cell.textLabel.text = @"设置密码";
            tf.secureTextEntry = YES;
            tf.delegate = self;
            break;
        case 2:
            cell.textLabel.text = @"确认密码";
            tf.secureTextEntry = YES;
            tf.delegate = self;
            break;
        default:
            break;
    }
    //将TextField放置数组
    [_CellTfArray addObject:tf];
    [cell addSubview:tf];
    
    return cell;
}

//返回上一个登录页面
- (void)backOrdPage
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)stepBtnFunc
{
    NSString *name = [_CellTfArray[0] text];
    NSString *pwdFirst = [_CellTfArray[1] text];
    NSString *pwdSecond = [_CellTfArray[2] text];
    
    state = success;
    
    if ([name isEqualToString:@""]) {
        state = nameEmpty;
    } else if ([pwdFirst isEqualToString:@""]){
        state = firstPwdEmpty;
    } else if ([pwdSecond isEqualToString:@""]){
        state = secondPwdEmpty;
    } else if (![pwdSecond isEqualToString:pwdFirst]){
        state = diffOfPwd;
    }
    
    NSString *errMsg = @"";
    switch (state) {
        case nameEmpty:
            errMsg = @"用户名为空";
            break;
        case firstPwdEmpty:
            errMsg = @"密码为空";
            break;
        case secondPwdEmpty:
            errMsg = @"确认密码为空";
            break;
        case diffOfPwd:
            errMsg = @"确认密码不一致";
            break;
        default:
            break;
    }
    if (state == success) {
        [self creatSession];
    } else{
        DSToast *toast = [[DSToast alloc] initWithText:errMsg];
        [toast showInView:self.view];
    }

}

- (void)creatSession
{
    //gcd异步实现
    dispatch_queue_t ql = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(ql, ^{
        //加载一个NSURL对象
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.best8023.com:8080/FingerBank/user_regist.do"]];
        
        request.HTTPMethod = @"POST";
        NSString *args = [NSString stringWithFormat:@"user_username=%@&user_password=%@&user_machine=%@",[[_CellTfArray objectAtIndex:0] text],[[_CellTfArray objectAtIndex:1] text],strUuid_];
        request.HTTPBody = [args dataUsingEncoding:NSUTF8StringEncoding];
        
        //使用NSURLSession获取网络返回的Json并处理
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data,NSURLResponse *_Nullable response,NSError *_Nullable error){
            if (data == nil) {
                NSLog(@"网络错误");
                
                DSToast *toast = [[DSToast alloc] initWithText:@"网络错误"];
                [toast showInView:self.view.superview];
                
                return ;
            }
            //从网络返回了Json数据，我们调用NSJSONSerialization解析它，将JSON数据转换为Foundation对象（这里是一个字典）
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString *msg = [dic objectForKey:@"msg"];
            //更新UI操作需要在主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([dic objectForKey:@"status"] != nil) {
                    NSString *str = [NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]];
                    if ([str isEqualToString:@"1"]) {
                        NSLog(@"成功");
                        
                        
                        //用NSUserDefaults保存用户名和密码 和登录状态
                        
                        [_userDef setObject:[_CellTfArray[0] text] forKey:@"username"];
                        [_userDef setObject:[_CellTfArray[0] text] forKey:@"password"];
                        [_userDef setBool:NO forKey:@"loginState"];
                        
                        //注册成功返回登录界面
                        [self dismissViewControllerAnimated:YES completion:nil];
                        
                        DSToast *toast = [[DSToast alloc] initWithText:@"注册成功"];
                        [toast showInView:self.view.superview];
                        
                    } else{
                        NSLog(@"失败,%@",msg);
                        
                        DSToast *toast = [[DSToast alloc] initWithText:msg];
                        [toast showInView:self.view.superview];
                    }
                }
            });
        }];
        //调用任务
        [task resume];
    });
}

//监听两次密码是否正确
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (void)tapAction:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}

- (void)setupView
{
    UIColor *color = [UIColor colorWithRed:64/255.0 green:137/255.0 blue:186/255.0 alpha:1.0];
    _CellTfArray = [NSMutableArray array];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, barHeight+20, Kwidth, Kheight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.scrollEnabled = NO;
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Kwidth, 20)];
    _tableView.tableHeaderView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    
    UITapGestureRecognizer *tapRecognizer;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    //navBar
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Kwidth, barHeight+20)];
    navBar.backgroundColor = color;
    [self.view addSubview:navBar];
    //navTitleLable
    UILabel *titleLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Kwidth*0.5, barHeight)];
    titleLb.textAlignment = NSTextAlignmentCenter;
    titleLb.textColor = [UIColor whiteColor];
    titleLb.text = @"注册";
    titleLb.center = CGPointMake(navBar.centerX, navBar.centerY+10);
    [navBar addSubview:titleLb];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake(6, 24, 52*0.6, 62*0.6);
    backBtn.tintColor = [UIColor whiteColor];
    [backBtn setImage:[UIImage imageNamed:@"backArrow"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backOrdPage) forControlEvents:UIControlEventTouchUpInside];
    
    //stepBtn
    UIButton *stepBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, Kheight-barHeight-20, Kwidth, barHeight+20)];
    stepBtn.backgroundColor = color;
    [stepBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [self.view addSubview:stepBtn];
    [stepBtn addTarget:self action:@selector(stepBtnFunc) forControlEvents:UIControlEventTouchUpInside];
    
    //获取UUID
    IdModel *idModel = [[IdModel alloc] init];
    strUuid_ = [idModel getUuidStr];
    
    //NSUserDefault;
    _userDef = [NSUserDefaults standardUserDefaults];
    [_userDef setObject:strUuid_ forKey:@"uuid"];
    
}


@end
