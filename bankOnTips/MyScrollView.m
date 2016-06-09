//
//  MyScrollView.m
//  图片自动滚动(修改成可调用接口)
//
//  Created by 全宝蓝萌萌哒 on 16/6/5.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import "MyScrollView.h"

//#define kWidthOfScreen [UIScreen mainScreen].bounds.size.width
//#define kHeightOfScreen [[UIScreen mainScreen] bounds].size.height
#define kImageViewCount 3

@interface MyScrollView() {
    NSInteger seconds;
    CGFloat _kWidthOfScreen;
    CGFloat _kHeightOfScreen;
    CGRect _selfRect;
}

/* 加载图片数据 */
- (void)loadImageData;

/*  添加滚动视图 */
- (void)addScrollView;

/* 添加三个图片视图到滚动视图内
 */
- (void)addImageViewsToScrollView;

/*  添加分页控件
 */
- (void)addPageControl;

/*  添加标签；用于图片描述
 */
- (void)addLabel;

/*  根据当前图片索引设置信息  @param currentImageIndex 当前图片索引；即中间
 */
- (void)setInfoByCurrentImageIndex:(NSUInteger)currentImageIndex;

/*  设置默认信息
 */
- (void)setDefaultInfo;

/*  重新加载图片
 */
- (void)reloadImage;

- (void)layoutUI;

@end

@implementation MyScrollView


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        
        _kWidthOfScreen = frame.size.width;
        _kHeightOfScreen = frame.size.height;
        _selfRect = frame;
        
        seconds = 0;

        [self layoutUI];
    }
    
    return self;
}

//计时器调用
- (void)roll
{
//    NSLog(@"roll %ld",seconds++);

    [self scrollViewDidEndDecelerating:_scrV];
    [_scrV setContentOffset:CGPointMake(_kWidthOfScreen*2, 0) animated:YES];
    
    
    
    
    
    
}

- (void)loadImageData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ImageInfo" ofType:@"plist"];
    _mDicImageData = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    _imageCount = _mDicImageData.count;
}

- (void)addScrollView {
    _scrV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _kWidthOfScreen, _kHeightOfScreen)];
    _scrV.contentSize = CGSizeMake(_kWidthOfScreen * kImageViewCount, _kHeightOfScreen);
    _scrV.contentOffset = CGPointMake(_kWidthOfScreen+1, 0.0);
    _scrV.pagingEnabled = YES;
    _scrV.bounces = NO;
    _scrV.directionalLockEnabled = YES;
    _scrV.scrollsToTop = NO;
    _scrV.alwaysBounceVertical = NO;
    _scrV.showsHorizontalScrollIndicator = NO;
    _scrV.delegate = self;
    [self addSubview:_scrV];
    
}

- (void)addImageViewsToScrollView {
    //图片视图；左边
    _imgVLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, _kWidthOfScreen, _kHeightOfScreen)];
    _imgVLeft.contentMode = UIViewContentModeScaleAspectFit;
    [_scrV addSubview:_imgVLeft];
    
    
    //图片视图；中间
    _imgVCenter = [[UIImageView alloc] initWithFrame:CGRectMake(_kWidthOfScreen, 0.0, _kWidthOfScreen, _kHeightOfScreen)];
    _imgVCenter.contentMode = UIViewContentModeScaleAspectFit;
    [_scrV addSubview:_imgVCenter];
    
    
    //图片视图；右边
    _imgVRight = [[UIImageView alloc] initWithFrame:CGRectMake(_kWidthOfScreen * 2.0, 0.0, _kWidthOfScreen, _kHeightOfScreen)];
    _imgVRight.contentMode = UIViewContentModeScaleAspectFit;
    [_scrV addSubview:_imgVRight];
}

- (void)addPageControl {
    _pageC = [UIPageControl new];
    CGSize size= [_pageC sizeForNumberOfPages:_imageCount]; //根据页数返回 UIPageControl 合适的大小
    _pageC.bounds = CGRectMake(0.0, 0.0, size.width, size.height);
    _pageC.center = CGPointMake(_kWidthOfScreen / 2.0, _kHeightOfScreen - 10.0);
    _pageC.numberOfPages = _imageCount;
    _pageC.pageIndicatorTintColor = [UIColor whiteColor];
    _pageC.currentPageIndicatorTintColor = [UIColor brownColor];
    _pageC.userInteractionEnabled = NO; //设置是否允许用户交互；默认值为 YES，当为 YES 时，针对点击控件区域左（当前页索引减一，最小为0）右（当前页索引加一，最大为总数减一），可以编写 UIControlEventValueChanged 的事件处理方法
    [self addSubview:_pageC];
}

- (void)addLabel {
    _lblImageDesc = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 40.0, _kWidthOfScreen, 40.0)];
    _lblImageDesc.center = CGPointMake(_kWidthOfScreen / 2.0, _kHeightOfScreen - 30.0);
    _lblImageDesc.textAlignment = NSTextAlignmentCenter;
    _lblImageDesc.textColor = [UIColor whiteColor];
    _lblImageDesc.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    _lblImageDesc.text = @"now.";
    [self addSubview:_lblImageDesc];
}

- (void)setInfoByCurrentImageIndex:(NSUInteger)currentImageIndex {
    NSString *currentImageNamed = [NSString stringWithFormat:@"%lu.png", (unsigned long)currentImageIndex];
    _imgVCenter.image = [UIImage imageNamed:currentImageNamed];
    _imgVLeft.image = [UIImage imageNamed:[NSString stringWithFormat:@"%lu.png", (unsigned long)((_currentImageIndex - 1 + _imageCount) % _imageCount)]];
    _imgVRight.image = [UIImage imageNamed:[NSString stringWithFormat:@"%lu.png", (unsigned long)((_currentImageIndex + 1) % _imageCount)]];
    
    _pageC.currentPage = currentImageIndex;
    _lblImageDesc.text = _mDicImageData[currentImageNamed];
}

- (void)setDefaultInfo {
    _currentImageIndex = 0;
    [self setInfoByCurrentImageIndex:_currentImageIndex];
}

- (void)reloadImage {
    CGPoint contentOffset = [_scrV contentOffset];
    if (contentOffset.x > _kWidthOfScreen) { //向左滑动
//        NSLog(@"zuo %ld",seconds++);
        _currentImageIndex = (_currentImageIndex + 1) % _imageCount;
    } else if (contentOffset.x < _kWidthOfScreen) { //向右滑动
        _currentImageIndex = (_currentImageIndex - 1 + _imageCount) % _imageCount;
//        NSLog(@"you");
    }
    
    [self setInfoByCurrentImageIndex:_currentImageIndex];
    
}

- (void)layoutUI {
    self.backgroundColor = [UIColor blackColor];
    
    [self loadImageData];
    [self addScrollView];
    [self addImageViewsToScrollView];
    [self addPageControl];
//    [self addLabel];
    [self setDefaultInfo];
    
    
//    [self scrollViewDidEndDecelerating:_scrV];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"didend  x:%0f",[_scrV contentOffset].x);
    [self reloadImage];
    
    _scrV.contentOffset = CGPointMake(_kWidthOfScreen, 0.0);
    _pageC.currentPage = _currentImageIndex;
    
    NSString *currentImageNamed = [NSString stringWithFormat:@"%lu.png", (unsigned long)_currentImageIndex];
    _lblImageDesc.text = _mDicImageData[currentImageNamed];
    
}


@end
