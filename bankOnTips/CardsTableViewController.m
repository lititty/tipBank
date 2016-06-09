//
//  CardsTableViewController.m
//  bankOnTips
//
//  Created by 全宝蓝萌萌哒 on 16/6/4.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import "CardsTableViewController.h"

@interface CardsTableViewController ()

@property (strong, nonatomic) NSDictionary *dic;
@property (strong, nonatomic) IdentifyBank *ident;
@property (strong, nonatomic) NSArray *bankArr;
@property (strong, nonatomic) NSUserDefaults *userDef;
@property (strong, nonatomic) UILabel *defCardlb;

@property (assign, nonatomic) NSInteger cardsNum;

@end

@implementation CardsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"银行卡";
    
    //左返回键
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBack)];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backItem;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    self.tableView.tableFooterView = [UIView new];
    
    _userDef = [NSUserDefaults standardUserDefaults];
    
    //setup data
    _cardsNum = 0;
    
    _ident = [[IdentifyBank alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self creatSession];
}

- (void)viewWillDisappear:(BOOL)animated{
    [_defCardlb removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return _cardsNum;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        cell.textLabel.text = @"添加银行卡+";
        cell.textLabel.textColor = [UIColor colorWithRed:32/255.0 green:118/255.0 blue:175/255.0 alpha:1.0];
    } else{
        NSString *nums = [_bankArr[indexPath.row] objectForKey:@"number"];
        NSString *name = [_ident match:[nums substringToIndex:5]];
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",name]];
        cell.textLabel.text = name;
        cell.detailTextLabel.text = [nums substringFromIndex:nums.length-4];
        
        if ([nums isEqualToString:[_userDef objectForKey:[[_userDef objectForKey:@"username"] stringByAppendingString:@"default_bank_number"]]]) {
            
                //如果是默认银行卡
                _defCardlb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 80/2.0)];
                _defCardlb.center = CGPointMake(self.view.frame.size.width-30, 80/2.0);
                _defCardlb.font = [UIFont systemFontOfSize:13];
                _defCardlb.text = @"默认";
                _defCardlb.textAlignment = NSTextAlignmentCenter;
                _defCardlb.textColor = [UIColor colorWithRed:64/255.0 green:137/255.0 blue:186/255.0 alpha:1.0];
                [cell addSubview:_defCardlb];
            
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        //添加银行卡
        AddCardViewController *addCardVc = [[AddCardViewController alloc] init];
        [self.navigationController pushViewController:addCardVc animated:YES];
    } else{
        //银行卡详细信息
        CardDetailViewController *cardDetailVc = [[CardDetailViewController alloc] init];
        [self.navigationController pushViewController:cardDetailVc animated:YES];
        
        cardDetailVc.dict = _bankArr[indexPath.row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section != 0) {
        return 80;
    }
    return 40;
}

//创建网络连接
- (void)creatSession
{
    NSUserDefaults *userDer = [NSUserDefaults standardUserDefaults];
    
    //gcd异步实现
    dispatch_queue_t ql = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(ql, ^{
        //加载一个NSURL对象
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.best8023.com:8080/FingerBank/bank_getBanksList.do"]];
        
        request.HTTPMethod = @"POST";
        
        NSString *user_id = [userDer objectForKey:@"id"];
        NSString *user_token = [userDer objectForKey:@"token"];
        
        NSString *args = [NSString stringWithFormat:@"user_id=%@&user_token=%@",user_id,user_token];
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
                
//                NSLog(@"%@",_dic);
                
                if ([_dic objectForKey:@"status"] != nil) {
                    NSString *str = [NSString stringWithFormat:@"%@",[_dic objectForKey:@"status"]];
                    if ([str isEqualToString:@"1"]) {
                        //将银行卡列表读取到数组
                        _bankArr = [NSArray arrayWithArray:[_dic objectForKey:@"banks"]];
                        _cardsNum = [_bankArr count];
                        
                        [self.tableView reloadData];
                        
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
