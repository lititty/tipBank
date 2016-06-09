//
//  PayView.m
//  bankOnTips
//
//  Created by 全宝蓝萌萌哒 on 16/6/7.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import "PayView.h"
#define winWidth [UIScreen mainScreen].bounds.size.width
#define winHeight [UIScreen mainScreen].bounds.size.height

@interface PayView ()

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIImageView *line;

@end

@implementation PayView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self creatUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scanBtnFunc
{
    ScanView *scanVc = [[ScanView alloc] init];
    [self.navigationController pushViewController:scanVc animated:YES];
}

- (void)paymentBtnFunc
{
    CreatQRView *qrView = [[CreatQRView alloc] init];
    [self.navigationController pushViewController:qrView animated:YES];
}

- (void)tranfBtnFunc
{
    
    TransferView *transView = [[TransferView alloc] init];
    [self.navigationController pushViewController:transView animated:YES];
    
   
}

- (UIImageView *)navigationBarLine:(UIView *)view
{
    //符合调教返回控件
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    //递归查找
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self navigationBarLine:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)creatTopBtn:(NSInteger)index
          imageName:(NSString *)imageName
             btnTxt:(NSString *)btnTxt
           selector:(SEL)selector{
    CGFloat btnWidth = winWidth/3.0;
    CGFloat btnHeight = _topView.frame.size.height;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(index*btnWidth, 0, btnWidth-1, btnHeight)];
    
    //btn图标
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, btnWidth*0.4, btnWidth*0.4)];
    imageView.center = CGPointMake(btnWidth/2.0, btnHeight*0.4);
    imageView.image = [UIImage imageNamed:imageName];
//    imageView.backgroundColor = [UIColor whiteColor];
    [btn addSubview:imageView];
    
    //btn文字
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btnWidth, btnHeight*0.2)];
    lb.center = CGPointMake(btnWidth/2.0, btnHeight*0.8);
    lb.text = btnTxt;
//    lb.backgroundColor = [UIColor orangeColor];
    lb.textAlignment = NSTextAlignmentCenter;
    lb.textColor = [UIColor whiteColor];
    [btn addSubview:lb];
    
//    btn.backgroundColor = [UIColor redColor];
    [_topView addSubview:btn];
    
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)creatUI
{
    //去除navigationBar下横线
    _line = [self navigationBarLine:self.navigationController.navigationBar];
    _line.hidden = YES;
    
    //左返回键
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBack)];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backItem;
    
    //topView
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 100)];
    _topView.backgroundColor = [UIColor colorWithRed:64/255.0 green:137/255.0 blue:186/255.0 alpha:1.0];
    [self.view addSubview:_topView];
    
    //创建btn
    SEL selector0 = @selector(scanBtnFunc);
    SEL selector1 = @selector(paymentBtnFunc);
    SEL selector2 = @selector(tranfBtnFunc);
    
    [self creatTopBtn:0 imageName:@"扫一扫.png" btnTxt:@"扫一扫" selector:selector0];
    [self creatTopBtn:1 imageName:@"付款.png" btnTxt:@"付款" selector:selector1];
    [self creatTopBtn:2 imageName:@"转账.png" btnTxt:@"转账" selector:selector2];
}


@end
