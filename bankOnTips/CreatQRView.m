//
//  CreatQRView.m
//  bankOnTips
//
//  Created by 全宝蓝萌萌哒 on 16/6/8.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import "CreatQRView.h"

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

@interface CreatQRView ()

@property (strong, nonatomic) UIImageView *imageViewIcon;
@property (strong, nonatomic) UIButton *setMoneyBtn;
@property (strong, nonatomic) UIView *bottomSlideView;
@property (strong, nonatomic) UITextField *setMoneyTf;
@property (strong, nonatomic) UIButton *confirmBtn;
@property (assign, nonatomic) CGFloat keyboardHeight;
@property (assign, nonatomic) BOOL keyShow;
@property (strong, nonatomic) NSString *defaultCardNum;
@property (strong, nonatomic) NSString *logoNumMoney;
@property (strong, nonatomic) NSUserDefaults *userDef;

@end

@implementation CreatQRView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"付款码";
    self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    
    [self creatUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)addUserName:(NSString *)str
{
    return [[_userDef objectForKey:@"username"] stringByAppendingString:str];
}

- (void)leftBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setMoneyBtnFunc
{
    _setMoneyBtn.userInteractionEnabled = NO;
    
    [self displayOrHiddenButtomView:0.5 heightVar:-_bottomSlideView.frame.size.height];
    
}

//加载底部视图
- (void)loadButtomToView
{
    
    
}

//确定按钮的实现
- (void)confirmFunc
{
    _setMoneyBtn.userInteractionEnabled = YES;
    
    [self displayOrHiddenButtomView:0.5 heightVar:_bottomSlideView.frame.size.height];
    [_setMoneyTf resignFirstResponder]; //移除焦点
    
    //生成带金额数 的二维码字符串
    NSString *moneyStr = [NSString stringWithFormat:@"&%@",_setMoneyTf.text];
    UIImage *myImage = [UIImage imageNamed:@"tipBackWhite.png"];
    _imageViewIcon.image = [self createQRForString:[_logoNumMoney stringByAppendingString:moneyStr] myImage:myImage];
}

// 显示隐藏底部视图
- (void)displayOrHiddenButtomView:(CGFloat)duration heightVar:(CGFloat)heightVar
{
    
    
    [UIView animateWithDuration:duration animations:^{
        _setMoneyBtn.frame = CGRectMake(0, _setMoneyBtn.frame.origin.y+heightVar, kWidth, 64);
        _bottomSlideView.frame = CGRectMake(0,_bottomSlideView.frame.origin.y+heightVar, kWidth, kHeight/4.0);
    }];
}

//键盘弹出
- (void)keyboardWasShown:(NSNotification *)notification
{
    
    CGFloat height = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    
    [self displayOrHiddenButtomView:0.2 heightVar:-(height - _keyboardHeight)];
    
    _keyboardHeight = height;

    
}

//键盘隐藏
- (void)keyboardWasHidden:(NSNotification *)notification
{
    _keyShow = NO;
    [self displayOrHiddenButtomView:0.2 heightVar:_keyboardHeight];
    //将键盘高度重新初始为零
    _keyboardHeight = 0;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_setMoneyBtn.frame.origin.y == kHeight*3/4-64) {
        [self displayOrHiddenButtomView:0.5 heightVar:_bottomSlideView.frame.size.height];
        _setMoneyTf.text = @"";
        _setMoneyBtn.userInteractionEnabled = YES;
    }if (_setMoneyBtn.frame.origin.y == kHeight*3/4-64 + _keyboardHeight) {
        [self displayOrHiddenButtomView:0.5 heightVar:_keyboardHeight];
        
    }
    [_setMoneyTf resignFirstResponder];
}

//创建二维码图片
- (UIImage *)createQRForString:(NSString *)qrString myImage:(UIImage *)myImage
{
    if (![qrString isEqualToString:@""]) {
        NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        //创建一个二维码的滤镜
        CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [qrFilter setValue:stringData forKey:@"inputMessage"];
        [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
        CIImage *qrCIImage = qrFilter.outputImage;
        //创建一个颜色滤镜，黑白色
        CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"];
        [colorFilter setDefaults];
        [colorFilter setValue:qrCIImage forKey:@"inputImage"];
        [colorFilter setValue:[CIColor colorWithRed:0 green:0 blue:0] forKey:@"inputColor0"];
        [colorFilter setValue:[CIColor colorWithRed:1 green:1 blue:1] forKey:@"inputColor1"];
        //返回二维码image
        UIImage *codeImage = [UIImage imageWithCIImage:[colorFilter.outputImage imageByApplyingTransform:CGAffineTransformMakeScale(5, 5)]];
        
        //中间放置自定义图片
        if (myImage != nil) {
            CGRect rect = CGRectMake(0, 0, codeImage.size.width, codeImage.size.height);
            UIGraphicsBeginImageContext(rect.size);
            
            [codeImage drawInRect:rect];
            CGSize avatarSize = CGSizeMake(rect.size.width*0.25, rect.size.height*0.25);
            CGFloat x = (rect.size.width - avatarSize.width)*0.5;
            CGFloat y = (rect.size.height - avatarSize.height)*0.5;
            [myImage drawInRect:CGRectMake(x, y, avatarSize.width, avatarSize.height)];
            UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return resultImage;
        }
        return codeImage;
    }
    return nil;
}

- (void)creatUI
{
    
    CGFloat imageEdge = kWidth/2.0;
    _defaultCardNum = @"000000000000";
    
    //左返回键
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBack)];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backItem;
    
    _imageViewIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageEdge, imageEdge)];
    _imageViewIcon.center = CGPointMake(kWidth/2.0, kHeight*0.4);
    
    //NSUserfault
    _userDef = [NSUserDefaults standardUserDefaults];
    _defaultCardNum = [_userDef objectForKey: [self addUserName:@"default_bank_number"]];
    
    //设置具有指尖银行标识的字符串
    _logoNumMoney = [@"tipbank_" stringByAppendingString:_defaultCardNum];
    UIImage *myImage = [UIImage imageNamed:@"tipBackWhite.png"];
    _imageViewIcon.image = [self createQRForString:_logoNumMoney myImage:myImage];
    
    [self.view addSubview:_imageViewIcon];
    
    //设置金额btn
    _setMoneyBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kHeight-64, kWidth, 64)];
    _setMoneyBtn.backgroundColor = [UIColor colorWithRed:64/255.0 green:137/255.0 blue:186/255.0 alpha:1.0];
    [_setMoneyBtn setTitle:@"设置金额" forState:UIControlStateNormal];
    [_setMoneyBtn addTarget:self action:@selector(setMoneyBtnFunc) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setMoneyBtn];
    
    //底部弹出框
    _bottomSlideView = [[UIView alloc] initWithFrame:CGRectMake(0, kHeight, kWidth, kHeight/4.0)];
    _bottomSlideView.backgroundColor = [UIColor colorWithRed:64/255.0 green:137/255.0 blue:186/255.0 alpha:1.0];
    [self.view addSubview:_bottomSlideView];
    
    //设置金额TextField
    _setMoneyTf = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, kWidth/2.0, 40)];
    _setMoneyTf.center = CGPointMake(kWidth/2.0, _bottomSlideView.frame.size.height/4.0);
    _setMoneyTf.borderStyle = UITextBorderStyleRoundedRect;
    _setMoneyTf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _setMoneyTf.textAlignment = NSTextAlignmentCenter;
//    _setMoneyTf.backgroundColor = [UIColor greenColor];
    [_bottomSlideView addSubview:_setMoneyTf];

    //confirm按钮
    _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWidth/2.0, 48)];
    _confirmBtn.backgroundColor = [UIColor colorWithRed:229/255.0 green:83/255.0 blue:63/255.0 alpha:1.0];
    _confirmBtn.center = CGPointMake(kWidth/2.0, _bottomSlideView.frame.size.height*2/3);
    _confirmBtn.layer.cornerRadius = 5.f;
    [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(confirmFunc) forControlEvents:UIControlEventTouchUpInside];
    [_bottomSlideView addSubview:_confirmBtn];
    
    //监听键盘变化事件
    _keyShow = NO;
    _keyboardHeight = 0;
    //弹出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    //隐藏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardWillHideNotification object:nil];
}

@end
