//
//  IdentifyBank.h
//  bankOnTips
//
//  Created by 全宝蓝萌萌哒 on 16/6/6.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IdentifyBank : NSObject
{
    NSArray *arrayNum;
    NSArray *arrayName;
}

- (NSString *) match:(NSString *)num;
@end
