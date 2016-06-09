//
//  ViewController.m
//  bankOnTips
//
//  Created by 全宝蓝萌萌哒 on 16/6/4.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import "ViewController.h"
#import "IdModel.h"

@interface ViewController (){
    NSDictionary *_dic;
}

@property (strong, nonatomic) UITextField *userNameTf;
@property (strong, nonatomic) UITextField *passwordTf;
@property (strong, nonatomic) UIButton *loginBtn;
@property (strong, nonatomic) UIButton *signInBtn;
@property (strong, nonatomic) UIButton *forgetPwdBtn;
@property (strong, nonatomic) UILabel *cutLineLb;
@property (strong, nonatomic) UIImageView *mainImageView;
@property (strong, nonatomic) UILabel *projectName;
@property (strong, nonatomic) NSUserDefaults *userDef;

@property (strong, nonatomic) NSString *strOfUuid;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupView];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [_userNameTf resignFirstResponder];
//    [_passwordTf resignFirstResponder];
    [self.view endEditing:YES];
}

- (void)loadData
{
    
    if ([_userDef objectForKey:@"username"] == nil) {
        return;
    }
    //如果属于登入状态
    if ([_userDef boolForKey:@"loginState"]) {
        _userNameTf.text = [_userDef objectForKey:@"username"];
        _passwordTf.text = [_userDef objectForKey:@"password"];
        [self creatSession];
    } else{
        //如果属于退出状态
        _userNameTf.text = [_userDef objectForKey:@"username"];
    }
    
    
}

//将保存的键加入用户名
- (NSString *)addUserName:(NSString *)str
{
    return [[_userDef objectForKey:@"username"] stringByAppendingString:str];
}

//登入按钮
- (void)successLogin
{
    NSString *msg = @"";
    BOOL state = YES;
    
    if ([_userNameTf.text isEqualToString:@""]) {
        msg = @"账号为空";
        state = NO;
    } else if([_passwordTf.text isEqualToString:@""]){
        msg = @"密码为空";
        state = NO;
    }
    if (state) {
        [self creatSession];
    } else{
        DSToast *toast = [[DSToast alloc] initWithText:msg];
        [toast showInView:self.view];
    }
    
//    MainViewController *mainVc = [[MainViewController alloc] init];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainVc];
//    [self presentViewController:nav animated:NO completion:nil];
//    DSToast *toast = [[DSToast alloc] initWithText:@"登录成功"];
//    [toast showInView:mainVc.view];
    
}

//跳转注册
- (void)jumpToSignIn
{
    SignInViewController *signv = [[SignInViewController alloc] init];
    [self presentViewController:signv animated:YES completion:nil];
}

- (void)creatSession
{
    //gcd异步实现
    dispatch_queue_t ql = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(ql, ^{
        //加载一个NSURL对象
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.best8023.com:8080/FingerBank/user_login.do"]];
        
        request.HTTPMethod = @"POST";
        NSString *args = [NSString stringWithFormat:@"user_username=%@&user_password=%@&user_machine=%@",_userNameTf.text,_passwordTf.text,_strOfUuid];
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
                        
                        NSLog(@"%@",_dic);
                        
                        //用NSUserDefaults保存用户名、密码和登录状态
                        [_userDef setObject:_userNameTf.text forKey:@"username"];
                        [_userDef setObject:_passwordTf.text forKey:@"password"];
                        [_userDef setBool:YES forKey:@"loginState"];
                        
                        //保存服务器传回的
                        NSString *d_b_id = [NSString stringWithFormat:@"%@",[_dic objectForKey:@"default_bank_id"]];
                        [_userDef setObject:d_b_id forKey:[self addUserName:@"default_bank_id"]];
                        [_userDef setObject:[_dic objectForKey:@"default_bank_number"] forKey:[self addUserName:@"default_bank_number"]];
                        [_userDef setObject:[_dic objectForKey:@"id"] forKey:@"id"];
                        
                        //保存token
                        NSString *token = [_dic objectForKey:@"token"];
                        [_userDef setObject:token forKey:@"token"];
                        
                        
                        MainViewController *mainVc = [[MainViewController alloc] init];
                        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainVc];
                        [self presentViewController:nav animated:NO completion:nil];
                        DSToast *toast = [[DSToast alloc] initWithText:@"登录成功"];
                        [toast showInView:mainVc.view];
                    } else{
                        NSString *s = [_dic objectForKey:@"msg"];
                        NSLog(@"失败,%@",s);
                        
                        DSToast *toast = [[DSToast alloc] initWithText:@"账号或密码不正确"];
                        [toast showInView:self.view];
                    }
                }
            });
        }];
        //调用任务
        [task resume];
    });
}


#pragma mark - 创建UI

- (void)setupView
{
    CGFloat tfHeight = 45;
    UIColor *color = [UIColor colorWithRed:64/255.0 green:137/255.0 blue:186/255.0 alpha:1.0];
    CGFloat winWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat winHeight = [UIScreen mainScreen].bounds.size.height;
    
    //初始UI
    _mainImageView = [[UIImageView alloc] init];
    _projectName = [[UILabel alloc] init];
    UIView *topBar = [[UIView alloc] init];
    UIView *btmBar = [[UIView alloc] init];
    _userNameTf = [[UITextField alloc] init];
    _passwordTf = [[UITextField alloc] init];
    _loginBtn = [[UIButton alloc] init];
    _signInBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _cutLineLb = [[UILabel alloc] init];
    _forgetPwdBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view sd_addSubviews:@[topBar,btmBar,_mainImageView,_projectName,_userNameTf,_passwordTf,_loginBtn,_signInBtn,_cutLineLb,_forgetPwdBtn]];
    
    //顶底bar
    topBar.backgroundColor = color;
    topBar.sd_layout
    .topSpaceToView(self.view,0)
    .widthIs(self.view.frame.size.width)
    .heightIs(tfHeight+20);
    
    btmBar.backgroundColor = color;
    btmBar.sd_layout
    .bottomSpaceToView(self.view,0)
    .widthIs(self.view.frame.size.width)
    .heightIs(tfHeight+20);
    
    //项目图标
    _mainImageView.image = [UIImage imageNamed:@"tip.png"];
//    _mainImageView.backgroundColor = [UIColor redColor];
    _mainImageView.sd_layout
    .topSpaceToView(topBar,winHeight*0.05)
    .widthIs(winWidth/4.0)
    .heightIs(winWidth/4.0);
    _mainImageView.center = CGPointMake(self.view.centerX, _mainImageView.centerY);
    
    //项目名称
    _projectName.text = @"Bank On Tips";
    _projectName.textAlignment = NSTextAlignmentCenter;
    _projectName.textColor = color;
    _projectName.sd_layout
    .topSpaceToView(_mainImageView,4)
    .leftSpaceToView(self.view,10)
    .rightSpaceToView(self.view,10)
    .heightIs(20);
    
    //账户输入框
    _userNameTf.backgroundColor = color;
//    _userNameTf.borderStyle = UITextBorderStyleRoundedRect;
    _userNameTf.keyboardType = UIKeyboardTypeEmailAddress;
    _userNameTf.textColor = [UIColor whiteColor];
    _userNameTf.tintColor = [UIColor whiteColor];
    _userNameTf.layer.cornerRadius = tfHeight/2.0;
    _userNameTf.sd_layout
    .leftSpaceToView(self.view,tfHeight)
    .rightSpaceToView(self.view,tfHeight)
    .topSpaceToView(_projectName,winHeight*0.05)
    .heightIs(tfHeight);
    
    //账户框左侧Label
    _userNameTf.leftView = [[UIView alloc] initWithFrame:CGRectMake(tfHeight/0, 0, tfHeight*1.5, tfHeight)];
    UILabel *usernameLeftLb = [[UILabel alloc] initWithFrame:CGRectMake(tfHeight/2.0, 0, tfHeight, tfHeight)];
//    usernameLeftLb.backgroundColor = [UIColor redColor];
    usernameLeftLb.text = @"账号";
    usernameLeftLb.textColor = [UIColor whiteColor];
    [_userNameTf.leftView addSubview:usernameLeftLb];
    _userNameTf.leftViewMode = UITextFieldViewModeAlways;
    
    //密码框左侧Label
    _passwordTf.leftView = [[UIView alloc] initWithFrame:CGRectMake(tfHeight/0, 0, tfHeight*1.5, tfHeight)];
    UILabel *pwdLeftLb = [[UILabel alloc] initWithFrame:CGRectMake(tfHeight/2.0, 0, tfHeight, tfHeight)];
    //    usernameLeftLb.backgroundColor = [UIColor redColor];
    pwdLeftLb.text = @"密码";
    pwdLeftLb.textColor = [UIColor whiteColor];
    [_passwordTf.leftView addSubview:pwdLeftLb];
    _passwordTf.leftViewMode = UITextFieldViewModeAlways;
    
    //密码输入框
    _passwordTf.backgroundColor = color;
    _passwordTf.layer.cornerRadius = tfHeight/2.0;
    _passwordTf.secureTextEntry = YES;
    _passwordTf.textColor = [UIColor whiteColor];
    _passwordTf.tintColor = [UIColor whiteColor];
    _passwordTf.sd_layout
    .leftEqualToView(_userNameTf)
    .rightEqualToView(_userNameTf)
    .topSpaceToView(_userNameTf,tfHeight*0.5)
    .heightIs(tfHeight);
    
    //登录按钮
    _loginBtn.backgroundColor = color;
    [_loginBtn setTitle:@"登入" forState:UIControlStateNormal];
    [_loginBtn setAdjustsImageWhenHighlighted:YES];
    _loginBtn.layer.cornerRadius = tfHeight/2.0;
    _loginBtn.sd_layout
    .leftEqualToView(_userNameTf)
    .rightEqualToView(_userNameTf)
    .topSpaceToView(_passwordTf,tfHeight*0.5)
    .heightIs(tfHeight);
    [_loginBtn addTarget:self action:@selector(successLogin) forControlEvents:UIControlEventTouchUpInside];
  
    //分割线
    //    _cutLineLb.backgroundColor = color;
    _cutLineLb.center = self.view.center;
    _cutLineLb.text = @"|";
    _cutLineLb.textColor = color;
    _cutLineLb.sd_layout
    //    .leftSpaceToView(_signInBtn,tfHeight/2.0)
    .topEqualToView(_signInBtn)
    .widthIs(5)
    .autoHeightRatio(0);
    
    //注册按钮
//    _signInBtn.backgroundColor = color;
    [_signInBtn setTitle:@"用户注册" forState:UIControlStateNormal];
    _signInBtn.tintColor = color;
    _signInBtn.sd_layout
    .rightSpaceToView(_cutLineLb,10)
    .topSpaceToView(_loginBtn,tfHeight/2.0)
    .widthIs(tfHeight*1.5)
    .heightIs(tfHeight/2.0);
    [_signInBtn addTarget:self action:@selector(jumpToSignIn) forControlEvents:UIControlEventTouchUpInside];
    
    //忘记密码按钮
//    _forgetPwdBtn.backgroundColor = color;
    [_forgetPwdBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    _forgetPwdBtn.tintColor = color;
    _forgetPwdBtn.sd_layout
    .leftSpaceToView(_cutLineLb,10)
    .topEqualToView(_signInBtn)
    .widthIs(tfHeight*1.5)
    .heightIs(tfHeight/2.0);
    
    //uuid
    IdModel *idModel = [[IdModel alloc] init];
    _strOfUuid = [idModel getUuidStr];
    
    //NSUserDefault
    _userDef = [NSUserDefaults standardUserDefaults];
    [_userDef setObject:_strOfUuid forKey:@"uuid"];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    //加载保存的数据
    [self loadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
