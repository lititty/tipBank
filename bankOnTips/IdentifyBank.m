//
//  IdentifyBank.m
//  bankOnTips
//
//  Created by 全宝蓝萌萌哒 on 16/6/6.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import "IdentifyBank.h"


@implementation IdentifyBank

- (id)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    arrayNum = @[@"43674",@"43674",@"62228"
                 ,@"45812",@"52189",@"62226"
                 ,@"42702",@"42703",@"53099",@"62223",@"62223",@"62221",@"62221",@"62220",@"95588"
                 ,@"55259",@"40411",@"40412",@"51941",@"40336",@"55873",@"52008",@"52008",@"51941",@"4910",@"40412",@"40411",@"53591",@"40411",@"62283",@"62283",@"62284"
                 ];
    
    arrayName = @[@"建设银行",@"建设银行",@"建设银行"
                 ,@"交通银行",@"交通银行",@"交通银行"
                 ,@"工商银行",@"工商银行",@"工商银行",@"工商银行",@"工商银行",@"工商银行",@"工商银行",@"工商银行",@"工商银行"
                 ,@"农业银行",@"农业银行",@"农业银行",@"农业银行",@"农业银行",@"农业银行",@"农业银行",@"农业银行",@"农业银行",@"农业银行",@"农业银行",@"农业银行",@"农业银行",@"农业银行",@"农业银行",@"农业银行",@"农业银行"
                 ];
}

-(NSString *)match:(NSString *)num{
    for (int h=0; h < [arrayNum count]; h++) {
        if ([num isEqualToString:arrayNum[h]]) {
            return arrayName[h];
        }
    }
    return @"交通银行";
}

@end








