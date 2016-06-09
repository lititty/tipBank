//
//  TransferView.m
//  bankOnTips
//
//  Created by 全宝蓝萌萌哒 on 16/6/8.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import "TransferView.h"

@interface TransferView ()

@property (strong, nonatomic) UITextField *moneyTf;
@property (strong, nonatomic) UITextField *cardNumTf;
@property (strong, nonatomic) UIButton *stepBtn;
@property (strong, nonatomic) NSUserDefaults *userDer;
@property (strong, nonatomic) NSDictionary *dic;

@end

@implementation TransferView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)addUserName:(NSString *)str
{
    return [[_userDer objectForKey:@"username"] stringByAppendingString:str];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_moneyTf resignFirstResponder];
    [_cardNumTf resignFirstResponder];
}

- (void)leftBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmTransfer
{
    NSString *url = @"http://www.best8023.com:8080/FingerBank/bank_transfer2Bank.do";
    NSString *user_id = [_userDer objectForKey:@"id"];
    NSString *user_token = [_userDer objectForKey:@"token"];
    NSString *from_bank_number = [_userDer objectForKey:[self addUserName:@"default_bank_number"]];
    NSString *to_bank_number = _cardNumTf.text;
    NSString *money = _moneyTf.text;
    
    
    NSString *args = [NSString stringWithFormat:@"user_id=%@&user_token=%@&from_bank_number=%@&to_bank_number=%@&money=%@",user_id,user_token,from_bank_number,to_bank_number,money];
    
    //指纹验证
    LAContext *authenticationContext = [[LAContext alloc] init];
    NSError *error;
    BOOL isTouchIdAvailable = [authenticationContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if (isTouchIdAvailable) {
        NSLog(@"touch id 可以使用！");
        //步骤2：获取指纹验证结果
        [authenticationContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"正在进行指纹验证" reply:^(BOOL success,NSError*error){
            if (success) {
                NSLog(@"指纹绑定成功！");
                [self creatSessionWithUrl:url args:args operate:@"转账"];
            } else{
                NSLog(@"指纹绑定失败！");
            }
        }];
    } else{
        NSLog(@"Touch ID不可以使用！\n%@",error);
        DSToast *toast = [[DSToast alloc] initWithText:@"Touch ID不可以使用"];
        [toast showInView:self.view showType:DSToastShowTypeCenter];
    }

    
    
}

//创建网络连接
- (void)creatSessionWithUrl:(NSString *)url args:(NSString *)args operate:(NSString *)operate
{
    
    
    //gcd异步实现
    dispatch_queue_t ql = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(ql, ^{
        //加载一个NSURL对象
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        request.HTTPMethod = @"POST";
        
        
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
                
                //                                NSLog(@"%@",_dic);
                
                if ([_dic objectForKey:@"status"] != nil) {
                    NSString *str = [NSString stringWithFormat:@"%@",[_dic objectForKey:@"status"]];
                    if ([str isEqualToString:@"1"]) {
                        DSToast *toast = [[DSToast alloc] initWithText:@"已转账到默认银行卡"];
                        
                        [toast showInView:self.navigationController.view];
                        
                        [self.navigationController popToRootViewControllerAnimated:YES];
                        
                    } else{
                        NSString *s = [_dic objectForKey:@"msg"];
                        NSLog(@"失败,%@",s);
                        
                        DSToast *toast = [[DSToast alloc] initWithText:s];
                        [toast showInView:self.view];
                    }
                }
            });
        }];
        //调用任务
        [task resume];
    });
}

- (void)setupUI
{
    CGFloat cellHeight = 40;
    CGFloat edge = 10;
    
    //左返回键
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBack)];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backItem;
    
    _moneyTf = [UITextField new];
    _cardNumTf = [UITextField new];
    _stepBtn = [UIButton new];
    
    [self.view sd_addSubviews:@[_moneyTf,_cardNumTf,_stepBtn]];
    
    
    //name
    _moneyTf.borderStyle = UITextBorderStyleRoundedRect;
    _moneyTf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _moneyTf.sd_layout
    .topSpaceToView(self.navigationController.navigationBar,cellHeight/2.0)
    .leftSpaceToView(self.view,edge)
    .rightSpaceToView(self.view,edge)
    .heightIs(cellHeight);
    _moneyTf.placeholder = @"输入要转的金额";
    _moneyTf.text = @"";
    
    //cardNum
    _cardNumTf.borderStyle = UITextBorderStyleRoundedRect;
    _cardNumTf.keyboardType = UIKeyboardTypePhonePad;
    _cardNumTf.text = @"";
    _cardNumTf.placeholder = @"输入要转的银行卡号";
    _cardNumTf.sd_layout
    .topSpaceToView(_moneyTf,10)
    .leftSpaceToView(self.view,edge)
    .rightSpaceToView(self.view,edge)
    .heightIs(cellHeight);
    
    //step按钮
    [_stepBtn setTitle:@"确认转账" forState:UIControlStateNormal];
    _stepBtn.sd_layout
    .topSpaceToView(_cardNumTf,cellHeight/2.0)
    .leftSpaceToView(self.view,edge)
    .rightSpaceToView(self.view,edge)
    .heightIs(cellHeight);
    _stepBtn.backgroundColor = [UIColor colorWithRed:64/255.0 green:137/255.0 blue:186/255.0 alpha:1.0];
    [_stepBtn addTarget:self action:@selector(confirmTransfer) forControlEvents:UIControlEventTouchUpInside];
    
    //name leftView
    _moneyTf.leftView = [[UIView alloc] initWithFrame:CGRectMake(3, 0, cellHeight*1.8, cellHeight)];
    UILabel *moneyLeftLb = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, cellHeight*1.6, cellHeight)];
    moneyLeftLb.font = [UIFont systemFontOfSize:17];
    moneyLeftLb.textColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    moneyLeftLb.text = @" 金额";
    //    usernameLeftLb.textColor = [UIColor whiteColor];
    [_moneyTf.leftView addSubview:moneyLeftLb];
    _moneyTf.leftViewMode = UITextFieldViewModeAlways;
    
    //密码框左侧Label
    _cardNumTf.leftView = [[UIView alloc] initWithFrame:CGRectMake(3, 0, cellHeight*1.8, cellHeight)];
    UILabel *pwdLeftLb = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, cellHeight*1.6, cellHeight)];
    //    usernameLeftLb.backgroundColor = [UIColor redColor];
    pwdLeftLb.text = @" 卡号";
    pwdLeftLb.font = [UIFont systemFontOfSize:17];
    pwdLeftLb.textColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    [_cardNumTf.leftView addSubview:pwdLeftLb];
    _cardNumTf.leftViewMode = UITextFieldViewModeAlways;
    
    //userdefault
    _userDer = [NSUserDefaults standardUserDefaults];
    
    
    if (nil != _scanMoney ) {
        _moneyTf.text = _scanMoney;
    }
    if (nil != _scanCardNum) {
        _cardNumTf.text = _scanCardNum;
        _cardNumTf.userInteractionEnabled = NO;
    }

}


@end
