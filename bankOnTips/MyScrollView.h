//
//  MyScrollView.h
//  图片自动滚动(修改成可调用接口)
//
//  Created by 全宝蓝萌萌哒 on 16/6/5.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyScrollView : UIView <UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView *scrV;
@property (strong, nonatomic) UIPageControl *pageC;
@property (strong, nonatomic) UIImageView *imgVLeft;
@property (strong, nonatomic) UIImageView *imgVCenter;
@property (strong, nonatomic) UIImageView *imgVRight;
@property (strong, nonatomic) UILabel *lblImageDesc;
@property (strong, nonatomic) NSMutableDictionary *mDicImageData;
@property (assign, nonatomic) NSUInteger currentImageIndex;
@property (assign, nonatomic) NSUInteger imageCount;

//给外部调用，配合外部计时器实现自动滚动
- (void)roll;

@end
