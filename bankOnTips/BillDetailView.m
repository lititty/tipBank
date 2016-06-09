//
//  BillDetailView.m
//  bankOnTips
//
//  Created by 全宝蓝萌萌哒 on 16/6/6.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import "BillDetailView.h"

@interface BillDetailView (){
    CGFloat cellHeight;
}

@end

@implementation BillDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"账单详情";
    
    cellHeight = 56;
    
    //左返回键
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBack)];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.tableView.tableFooterView = [UIView new];
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 300,cellHeight*0.8)];
    lb.center = CGPointMake(lb.center.x, cellHeight/2.0);
    lb.font = [UIFont systemFontOfSize:15];
    lb.textColor = [UIColor colorWithWhite:0.2 alpha:0.7];
    
    
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"交易方式";
            lb.text = _outIn;
            break;
        case 1:
            cell.textLabel.text = @"对方账户";
            lb.text = [_dict objectForKey:[_outIn isEqualToString:@"付款"] ? @"to" : @"from"];
            break;
        case 2:
            cell.textLabel.text = @"自己账户";
            lb.text = [_dict objectForKey:[_outIn isEqualToString:@"收款"] ? @"to" : @"from"];
            break;
        case 3:
            cell.textLabel.text = @"交易金额";
            lb.text = [NSString stringWithFormat:@"%@",[_dict objectForKey:@"money"]];
            break;
        case 4:
            cell.textLabel.text = @"交易时间";
            
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
            
            lb.text = timeStr;
            break;
//
//        default:
//            break;
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    [cell addSubview:lb];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHeight;
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
