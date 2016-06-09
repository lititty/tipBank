//
//  TransferView.h
//  bankOnTips
//
//  Created by 全宝蓝萌萌哒 on 16/6/8.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+SDAutoLayout.h"
#import "DSToast.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface TransferView : UIViewController

@property (strong, nonatomic) NSString *scanMoney;
@property (strong, nonatomic) NSString *scanCardNum;

@end
