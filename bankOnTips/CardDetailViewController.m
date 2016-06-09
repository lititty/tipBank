//
//  CardDetailViewController.m
//  bankOnTips
//
//  Created by 全宝蓝萌萌哒 on 16/6/4.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import "CardDetailViewController.h"
#define kwidth [UIScreen mainScreen].bounds.size.width
#define kheight [UIScreen mainScreen].bounds.size.height

@interface CardDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *footView;
@property (strong, nonatomic) UIButton *removeBtn;
@property (strong, nonatomic) IdentifyBank *ident;
@property (strong, nonatomic) NSDictionary *dic;
@property (strong, nonatomic) UIButton *setDefaultBtn;
@property (strong, nonatomic) NSUserDefaults *userDer;

@end

@implementation CardDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"银行卡信息";
    
    _ident = [[IdentifyBank alloc] init];
    
    //左返回键
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBack)];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backItem;

    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];
    
    _setDefaultBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width*0.9, 40)];
    [_setDefaultBtn setTitle:@"设为默认" forState:UIControlStateNormal];
    _setDefaultBtn.backgroundColor = [UIColor colorWithRed:64/255.0 green:137/255.0 blue:186/255.0 alpha:1.0];
    _setDefaultBtn.layer.cornerRadius = 3.f;
    _setDefaultBtn.center = CGPointMake(self.view.center.x, _setDefaultBtn.center.y);
    [_setDefaultBtn addTarget:self action:@selector(setDaultFunc) forControlEvents:UIControlEventTouchUpInside];
    
    
    //设置默认银行卡的btn
    _removeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kheight-64, kwidth, 64)];
    [_removeBtn setTitle:@"解除绑定" forState:UIControlStateNormal];
    _removeBtn.backgroundColor = [UIColor colorWithRed:229/255.0 green:83/255.0 blue:63/255.0 alpha:1.0];
    [_removeBtn addTarget:self action:@selector(removeCard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_removeBtn];
    
    _footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1000)];
    _footView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    [_footView addSubview:_setDefaultBtn];
    
    _tableView.tableFooterView = _footView;
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    _tableView.tableHeaderView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    
    _userDer = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"%@",_dict);
}

- (NSString *)addUserName:(NSString *)str
{
    return [[_userDer objectForKey:@"username"] stringByAppendingString:str];
}

- (void)leftBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)removeCard
{
    NSString *url = @"http://www.best8023.com:8080/FingerBank/bank_deleteBankCard.do";
    
    NSString *user_id = [_userDer objectForKey:@"id"];
    NSString *user_token = [_userDer objectForKey:@"token"];
    NSString *bank_id = [_dict objectForKey:@"id"];
    
    NSString *args = [NSString stringWithFormat:@"user_id=%@&user_token=%@&bank_id=%@",user_id,user_token,bank_id];
    
    [self creatSessionWithUrl:url args:args operate:@"解绑"];
}

- (void)setDaultFunc
{
    NSString *url = @"http://www.best8023.com:8080/FingerBank/user_update.do";
    
    NSString *user_id = [_userDer objectForKey:@"id"];
    NSString *user_token = [_userDer objectForKey:@"token"];
    NSString *bank_id = [_dict objectForKey:@"id"];
    
    NSString *args = [NSString stringWithFormat:@"user_id=%@&user_token=%@&user_default_bank=%@",user_id,user_token,bank_id];
    
    [self creatSessionWithUrl:url args:args operate:@"设默"];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat cellHeight = 50.0;
    
    NSString *nums = [_dict objectForKey:@"number"];
    NSString *name = [_ident match:[nums substringToIndex:5]];
    cell.textLabel.text = name;
    
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",name]];
        cell.textLabel.text = name;
        cell.detailTextLabel.text = [nums substringFromIndex:nums.length-4];
        
        
        if ([[_dict objectForKey:@"number"] isEqualToString:[_userDer objectForKey:[self addUserName:@"default_bank_number"]]]) {
            NSLog(@"是默认");
            
            //如果是默认银行卡
            UILabel *defCardlb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 64/2.0)];
            defCardlb.center = CGPointMake(kwidth-30, 64/2.0);
            defCardlb.font = [UIFont systemFontOfSize:13];
            defCardlb.text = @"默认";
            defCardlb.textAlignment = NSTextAlignmentCenter;
            defCardlb.textColor = [UIColor colorWithRed:64/255.0 green:137/255.0 blue:186/255.0 alpha:1.0];
            [cell addSubview:defCardlb];
        }
    }
    if (indexPath.row == 1) {
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.text = @"卡号 ";
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 200, 30)];
        lb.center = CGPointMake(lb.center.x, cellHeight/2.0);
//        lb.textAlignment = NSTextAlignmentCenter;
        lb.textColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        lb.font = [UIFont systemFontOfSize:15];
        lb.text = nums;
        [cell addSubview:lb];
    }
    if (indexPath.row == 2) {
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.text = @"金额 ";
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 60, 30)];
        lb.center = CGPointMake(lb.center.x, cellHeight/2.0);
        lb.textAlignment = NSTextAlignmentCenter;
        lb.textColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        lb.font = [UIFont systemFontOfSize:15];
//        lb.backgroundColor = [UIColor blueColor];
        lb.textColor = [UIColor colorWithRed:229/255.0 green:83/255.0 blue:63/255.0 alpha:0.8];
        lb.text = [NSString stringWithFormat:@"%@",[_dict objectForKey:@"money"]];
        [cell addSubview:lb];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 64;
    }
    return 50;
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
                        DSToast *toast = [[DSToast alloc] initWithText:@"银行卡解绑成功"];
                        if ([operate isEqualToString:@"设默"]) {
                            toast.text = @"银行卡设置默认成功";
                            //将默认的银行卡信息保存
                            [_userDer setObject:[_dict objectForKey:@"number"] forKey:[self addUserName:@"default_bank_number"]];
                            [_userDer setObject:[_dict objectForKey:@"id"] forKey:[self addUserName:@"default_bank_id"]];
                            
                        } else{
                            //解绑 将默认信息清空
                            //将默认的银行卡信息保存
                            [_userDer setObject:@"" forKey:[self addUserName:@"default_bank_number"]];
                            [_userDer setObject:@"" forKey:[self addUserName:@"default_bank_id"]];
                        }
                        
                        
                        [toast showInView:self.navigationController.view];
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
