//
//  BillListTableViewController.m
//  bankOnTips
//
//  Created by 全宝蓝萌萌哒 on 16/6/4.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import "BillListTableViewController.h"

@interface BillListTableViewController ()
{
    CGFloat cellHeight_;
    NSInteger _billNum;
}

@property (strong, nonatomic) NSDictionary *dic;
@property (strong, nonatomic) NSArray *billArr;
@property (strong, nonatomic) NSArray *cardList;
@property (strong, nonatomic) NSDictionary *dict;
@property (strong, nonatomic) NSMutableArray *saveOutIns;

@end

@implementation BillListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"账单记录";
    
    //左返回键
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBack)];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.tableView.showsVerticalScrollIndicator = NO; //隐藏竖直条
    self.tableView.tableFooterView = [UIView new];
    
    //初始数据
    cellHeight_ = 64.f;
    _saveOutIns = [NSMutableArray array];
    
    NSUserDefaults *userDer = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [userDer objectForKey:@"id"];
    NSString *user_token = [userDer objectForKey:@"token"];
    //请求银行卡列表
    NSString *url = @"http://www.best8023.com:8080/FingerBank/bank_getBanksList.do";
    NSString *args = [NSString stringWithFormat:@"user_id=%@&user_token=%@",user_id,user_token];
    [self creatSessionWithUrl:url args:args operator:@"卡"];
    [NSThread sleepForTimeInterval:0.5];
    //请求账单列表
    url = @"http://www.best8023.com:8080/FingerBank/bank_getHistory.do";
    [self creatSessionWithUrl:url args:args operator:@"账单"];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)checkIsMyCard:(NSString *)num
{
    for (int h=0; h < [_cardList count]; h++) {
        if ([num isEqualToString:[_cardList[h] objectForKey:@"number"]]) {
            return @"付款";
        }
    }
    return @"收款";
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"billnum:%ld",_billNum);
    return _billNum;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" ];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    _dict = _billArr[indexPath.row];
    cell.textLabel.text = [self checkIsMyCard:[_dict objectForKey:@"from"]];
    [_saveOutIns addObject:[self checkIsMyCard:[_dict objectForKey:@"from"]]];
    //对时间戳进行正常的时间格式转换
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSUInteger timeIntervar = [[_dict objectForKey:@"time"] integerValue];
    timeIntervar /= 1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeIntervar];
    
    NSString *timeStr = [formatter stringFromDate:date];
    cell.detailTextLabel.text = timeStr;
    
    CGFloat moneyWidth = 70;
    UITextView *money = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, moneyWidth, cellHeight_*0.7)];
    money.center = CGPointMake(self.view.frame.size.width-(moneyWidth/2.0), cellHeight_/2.0);
    NSString *m = [_dict objectForKey:@"money"];
    money.text = [NSString stringWithFormat:@"%@元",m];
    money.font = [UIFont systemFontOfSize:12];
    money.textAlignment = NSTextAlignmentCenter;
    money.editable = NO;
    [cell addSubview:money];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHeight_;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BillDetailView *billDetail = [[BillDetailView alloc] init];
    billDetail.outIn = _saveOutIns[indexPath.row];
    billDetail.dict = _billArr[indexPath.row];
    [self.navigationController pushViewController:billDetail animated:YES];
}

- (void)creatSessionWithUrl:(NSString *)url args:(NSString *)args operator:(NSString *)operator
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
                
                
                
                if ([_dic objectForKey:@"status"] != nil) {
                    NSString *str = [NSString stringWithFormat:@"%@",[_dic objectForKey:@"status"]];
                    if ([str isEqualToString:@"1"]) {
                        if ([operator isEqualToString:@"账单"]) {
                            NSLog(@"%@",_dic);
                            //将账单列表读取到数组
                            _billArr = [NSArray arrayWithArray:[_dic objectForKey:@"histories"]];
                            _billNum = [_billArr count];
                            
                            [self.tableView reloadData];
                            NSLog(@"读取成功");
                        } else{
                            //读取银行卡列表
                            _cardList = [NSArray arrayWithArray:[_dic objectForKey:@"banks"]];
                            NSLog(@"cardlist:%@",_cardList);
                        }
                        
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
