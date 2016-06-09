//
//  Uuid.m
//  uuid+keychain
//
//  Created by 全宝蓝萌萌哒 on 16/6/3.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import "IdModel.h"

@implementation IdModel

- (id)init
{
    if (self = [super init]) {
        //Initialization code
        [self setup];
    }
    return self;
}

-(void)setup
{
    NSString *retrieveuuid = [SSKeychain passwordForService:@"com.yourapp.yourcompany" account:@"user"];
    
    if (retrieveuuid == nil) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        retrieveuuid = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault,uuidRef));
        
        [SSKeychain setPassword: [NSString stringWithFormat:@"%@", retrieveuuid]
                     forService:@"com.yourapp.yourcompany"account:@"user"];
    }
    
    _uuidStr = retrieveuuid;
}

-(NSString *)getUuidStr
{
    return _uuidStr;
}

@end

























