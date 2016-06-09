//
//  Uuid.h
//  uuid+keychain
//
//  Created by 全宝蓝萌萌哒 on 16/6/3.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSKeychain.h"

@interface IdModel : NSObject{
    NSString *_uuidStr;
}
-(NSString *)getUuidStr;
@end
