//
//  scanView.m
//  扫和生成二维码
//
//  Created by 全宝蓝萌萌哒 on 16/6/7.
//  Copyright © 2016年 全宝蓝萌萌哒. All rights reserved.
//

#import "ScanView.h"

@interface ScanView () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) UIView *scanRectVeiw;
@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureMetadataOutput *output;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;
@property (strong, nonatomic) NSString *scanValue;

@end

@implementation ScanView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"扫一扫";
    
    //左返回键
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBack)];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self scanFunc];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_scanValue != nil) {
        [_session startRunning];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scanFunc
{
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    self.output = [[AVCaptureMetadataOutput alloc]init];
    //    self.outPut.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    //    self.outPut.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
        
    }
    
    if ([self.session canAddOutput:self.output])
    {
        [self.session addOutput:self.output];
    }
    
    @try {
        self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    } @catch (NSException *exception) {
        NSLog(@"设备不支持或没打开相机");
    }
    
    
    //计算中间可探测区域
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    CGSize scanSize = CGSizeMake(windowSize.width*3/4, windowSize.width*3/4);
    CGRect scanRect = CGRectMake((windowSize.width-scanSize.width)/2, (windowSize.height-scanSize.height)/2, scanSize.width, scanSize.height);
    //计算rectOfInterest 注意x,y交换位置
    scanRect = CGRectMake(scanRect.origin.y/windowSize.height, scanRect.origin.x/windowSize.width, scanRect.size.height/windowSize.height, scanRect.size.width/windowSize.width);
    //设置可探测区域
    _output.rectOfInterest = scanRect;
    _preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = [UIScreen mainScreen].bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    
    
    
    //添加中间的探测区域绿框
    _scanRectVeiw = [UIView new];
    [self.view addSubview:_scanRectVeiw];
    _scanRectVeiw.frame = CGRectMake(0, 0, scanSize.width, scanSize.height);
    _scanRectVeiw.center = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds));
    _scanRectVeiw.layer.borderColor = [UIColor greenColor].CGColor;
    _scanRectVeiw.layer.borderWidth = 1;
    
    UIView *backView = [[UIView alloc] initWithFrame:self.view.frame];
    backView.backgroundColor = [UIColor whiteColor];
    backView.alpha = 0.2;
    //制作中空效果
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];
    shape.frame = self.view.frame;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:_scanRectVeiw.frame];
    [path appendPath:[UIBezierPath bezierPathWithRect:self.view.layer.frame]];
    shape.path = path.CGPath;
    shape.fillRule = kCAFillRuleEvenOdd;
    backView.layer.mask = shape;
    
    [self.view addSubview:backView];
    
    //开始捕获
    [_session startRunning];
}

//摄像头捕获
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSString *stringValue = @"";
    if ([metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = (AVMetadataMachineReadableCodeObject *)metadataObjects[0];
        stringValue = metadataObject.stringValue;
        
        if ([stringValue isEqualToString:@""]) {
            [_session stopRunning];
        }
    }
    [_session stopRunning];
    
    //扫描成功后要实现的功能
//    NSLog(@"二维码字符串: %@",stringValue);
    _scanValue = stringValue;
    
    //确认是否是指尖银行生成的字符串并分离金额和银行卡号
    NSInteger h = 0;
    NSMutableString *str = [NSMutableString stringWithString:stringValue];;
    NSRange substr = [str rangeOfString:@"tipbank_"];
    
    //检测是否是带有指尖银行标识的字符串
    if (substr.location != NSNotFound) {
        [str deleteCharactersInRange:substr];
        
        //字符串里有没有金额
        BOOL hasMoney = NO;
        for (h = 0; h < str.length; h++) {
            char a = [str characterAtIndex:h];
            if ( a == '&') {
                hasMoney = YES;
                break;
            }
        }
        NSString *cardNum;
        NSString * money;
        if (hasMoney) {
            cardNum = [str substringToIndex:h];
            money = [str substringFromIndex:h+1];
        } else{
            cardNum = str;
        }
        
        NSLog(@"str:%@,money:%@,cardnum:%@",str,money,cardNum);
        
        //跳转至转账页面并传值
        TransferView *transView = [[TransferView alloc] init];
        transView.scanMoney = money;
        transView.scanCardNum = cardNum;
        [self.navigationController pushViewController:transView animated:YES];
    } else{
//        NSLog(@"请扫描指尖银行的付款码 谢谢！");
        DSToast *toast = [[DSToast alloc] initWithText:@"请扫描指尖银行的付款码 谢谢！"];
        [toast showInView:self.view];
        
        //继续扫描
        [_session startRunning];
    }
    
}

@end












