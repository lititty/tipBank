//
//  AddCardViewController.m
//  bankOnTips
//
//  Created by 全宝蓝萌萌哒 on 16/6/4.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import "AddCardViewController.h"
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

@interface AddCardViewController ()
{
    CGFloat cellHeight ;
    CGFloat edge ;
}

@property (strong, nonatomic) UIButton *stepBtn;
@property (strong, nonatomic) UITextField *nameTf;
@property (strong, nonatomic) UITextField *cardNumTf;
@property (strong, nonatomic) NSDictionary *dic;

@end

@implementation AddCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    cellHeight = 40.f;
    edge = 10.0;
    
    
    self.title = @"添加银行卡";
    
    [self setupUI];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_nameTf resignFirstResponder];
    [_cardNumTf resignFirstResponder];
}

- (void)leftBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)stepBtnFunc{

    
    if (![_nameTf.text isEqualToString:@""]) {
        if (![_cardNumTf.text isEqualToString:@""]) {
            if ([self checkCardNo:_cardNumTf.text]) {
                //指纹验证
                LAContext *authenticationContext = [[LAContext alloc] init];
                NSError *error;
                BOOL isTouchIdAvailable = [authenticationContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
                if (isTouchIdAvailable) {
                    NSLog(@"touch id 可以使用！");
                    //步骤2：获取指纹验证结果
                    [authenticationContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"将指纹和银行卡进行绑定" reply:^(BOOL success,NSError*error){
                        if (success) {
                            NSLog(@"指纹绑定成功！");
                            [self creatSession];
                        } else{
                            NSLog(@"指纹绑定失败！");
                        }
                    }];
                } else{
                    NSLog(@"Touch ID不可以使用！\n%@",error);
                    DSToast *toast = [[DSToast alloc] initWithText:@"Touch ID不可以使用"];
                    [toast showInView:self.view showType:DSToastShowTypeCenter];
                }
                
            } else{
                DSToast *toast = [[DSToast alloc] initWithText:@"银行卡号不正确"];
                [toast showInView:self.view showType:DSToastShowTypeCenter];
            }
        }else{
            DSToast *toast = [[DSToast alloc] initWithText:@"银行卡号为空"];
            [toast showInView:self.view showType:DSToastShowTypeCenter];
        }
    } else{
        DSToast *toast = [[DSToast alloc] initWithText:@"用户名为空"];
        [toast showInView:self.view showType:DSToastShowTypeCenter];
    }
    
//    if ([self checkCardNo:_cardNumTf.text]) {
//        [self creatSession];
//    } else{
//        DSToast *toast = [[DSToast alloc] initWithText:@"银行卡号不正确"];
//        [toast showInView:self.view showType:DSToastShowTypeTop];
//    }
    
}

//创建网络连接
- (void)creatSession
{
    NSUserDefaults *userDer = [NSUserDefaults standardUserDefaults];
    
    //gcd异步实现
    dispatch_queue_t ql = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(ql, ^{
        //加载一个NSURL对象
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.best8023.com:8080/FingerBank/bank_addBankCard.do"]];
        
        request.HTTPMethod = @"POST";
        
        NSString *user_id = [userDer objectForKey:@"id"];
        NSString *user_token = [userDer objectForKey:@"token"];
        NSString *bank_name = _nameTf.text;
        NSString *bank_number = _cardNumTf.text;
        
        NSString *args = [NSString stringWithFormat:@"user_id=%@&user_token=%@&bank_name=%@&bank_number=%@",user_id,user_token,bank_name,bank_number];
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
                        //返回银行卡列表
                        [self.navigationController popViewControllerAnimated:YES];
                        
                        NSLog(@"添加成功");
                        DSToast *toast = [[DSToast alloc] initWithText:@"添加成功"];
                        [toast showInView:self.navigationController.view];
                    } else{
                        NSString *s = [_dic objectForKey:@"msg"];
                        NSLog(@"失败,%@",s);
                        
                        DSToast *toast = [[DSToast alloc] initWithText:s];
                        [toast showInView:self.view  showType:DSToastShowTypeCenter];
                    }
                }
            });
        }];
        //调用任务
        [task resume];
    });
}

//判断银行卡输入正确与否
- (BOOL) checkCardNo:(NSString*) cardNo{
    int oddsum = 0;     //奇数求和
    int evensum = 0;    //偶数求和
    int allsum = 0;
    int cardNoLength = (int)[cardNo length];
    int lastNum = [[cardNo substringFromIndex:cardNoLength-1] intValue];
    
    cardNo = [cardNo substringToIndex:cardNoLength - 1];
    for (int i = cardNoLength -1 ; i>=1;i--) {
        NSString *tmpString = [cardNo substringWithRange:NSMakeRange(i-1, 1)];
        int tmpVal = [tmpString intValue];
        if (cardNoLength % 2 ==1 ) {
            if((i % 2) == 0){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }else{
            if((i % 2) == 1){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }
    }
    
    allsum = oddsum + evensum;
    allsum += lastNum;
    if((allsum % 10) == 0)
        return YES;
    else
        return NO;
}

- (void)setupUI
{
    //左返回键
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBack)];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backItem;
    
    _nameTf = [UITextField new];
    _cardNumTf = [UITextField new];
    _stepBtn = [UIButton new];
    [self.view sd_addSubviews:@[_nameTf,_cardNumTf,_stepBtn]];
    
    //name
    _nameTf.borderStyle = UITextBorderStyleRoundedRect;
    _nameTf.sd_layout
    .topSpaceToView(self.navigationController.navigationBar,cellHeight/2.0)
    .leftSpaceToView(self.view,edge)
    .rightSpaceToView(self.view,edge)
    .heightIs(cellHeight);
    _nameTf.placeholder = @"持卡人姓名";
    _nameTf.text = @"";
    [_nameTf becomeFirstResponder];
    
    //cardNum
    _cardNumTf.borderStyle = UITextBorderStyleRoundedRect;
    _cardNumTf.keyboardType = UIKeyboardTypePhonePad;
    _cardNumTf.text = @"";
    _cardNumTf.sd_layout
    .topSpaceToView(_nameTf,10)
    .leftSpaceToView(self.view,edge)
    .rightSpaceToView(self.view,edge)
    .heightIs(cellHeight);
    
    //step按钮
    [_stepBtn setTitle:@"下一步" forState:UIControlStateNormal];
    _stepBtn.sd_layout
    .topSpaceToView(_cardNumTf,cellHeight/2.0)
    .leftSpaceToView(self.view,edge)
    .rightSpaceToView(self.view,edge)
    .heightIs(cellHeight);
    _stepBtn.backgroundColor = [UIColor colorWithRed:64/255.0 green:137/255.0 blue:186/255.0 alpha:1.0];
    [_stepBtn addTarget:self action:@selector(stepBtnFunc) forControlEvents:UIControlEventTouchUpInside];
    
    //name leftView
    _nameTf.leftView = [[UIView alloc] initWithFrame:CGRectMake(3, 0, cellHeight*1.8, cellHeight)];
    UILabel *usernameLeftLb = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, cellHeight*1.6, cellHeight)];
    usernameLeftLb.font = [UIFont systemFontOfSize:17];
    usernameLeftLb.textColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    usernameLeftLb.text = @"  持卡人";
    //    usernameLeftLb.textColor = [UIColor whiteColor];
    [_nameTf.leftView addSubview:usernameLeftLb];
    _nameTf.leftViewMode = UITextFieldViewModeAlways;
    
    //密码框左侧Label
    _cardNumTf.leftView = [[UIView alloc] initWithFrame:CGRectMake(3, 0, cellHeight*1.8, cellHeight)];
    UILabel *pwdLeftLb = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, cellHeight*1.6, cellHeight)];
    //    usernameLeftLb.backgroundColor = [UIColor redColor];
    pwdLeftLb.text = @"　卡号";
    pwdLeftLb.font = [UIFont systemFontOfSize:17];
    pwdLeftLb.textColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    [_cardNumTf.leftView addSubview:pwdLeftLb];
    _cardNumTf.leftViewMode = UITextFieldViewModeAlways;
    
    

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
