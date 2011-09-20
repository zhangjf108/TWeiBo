//
//  SendViewController.m
//  TWeiBo
//
//  Created by 健锋 章 on 11-8-20.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import "SendViewController.h"
#import "OtherUtil.h"
#import "Account.h"
#import "SinaWeiBo.h"
#import "QQWeiBo.h"
#import "UIImage+Compress.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+Util.h"

//查看图片
#import "MWPhotoBrowser.h"

@implementation SendViewController

@synthesize content;
@synthesize characterSize;
@synthesize sendItem;
@synthesize imageIconView;
@synthesize imageSmallView;
@synthesize delBtn;

//菊花
MBProgressHUD *HUD;
BOOL isKeyboard = YES;

static NSData *imageData;

#pragma mark -
#pragma mark private methods
- (void) networkError {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD setFrame:CGRectMake(0, 0, 320, 270)];
    HUD.dimBackground = NO;
    HUD.delegate = self;
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"skull.png"]] autorelease];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"网络连接错误";
    [HUD show:YES];
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:1.0];
}

- (void) hideHUD {
    if (HUD) {
        [HUD removeFromSuperview];
    }
}

- (NSData *) getNSDataFromUIImage:(UIImage *)image {
    if (imageData) {
        return imageData;
    }
    
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGFloat scaleRatio = 1;
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(width, height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    
    imageData = [imageCopy compressedData:0.5];
    return imageData;
}

#pragma mark -
#pragma mark instance methods

- (void)didReceiveMemoryWarning
{
    self.imageIconView = nil;
    self.imageSmallView = nil;
    HUD = nil;
    [self.view removeFromSuperview];
    
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    //自动显示键盘
    self.content.delegate = self;
    //[self.content selectAll:nil];
    [self.content becomeFirstResponder];
    sendItem.enabled = NO;
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.content becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)keyboardWillShow:(id)sender {
    CGRect keyboardFrame;
    [[[((NSNotification *)sender) userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    float keyboardHeight = CGRectGetHeight(keyboardFrame);
    
    //改变高度
    saveBtn.frame       = CGRectMake(15, 430 - keyboardHeight, 22, 22);
    cameraBtn.frame     = CGRectMake(55, 430 - keyboardHeight, 25, 20);
    imgBtn.frame        = CGRectMake(100, 430 - keyboardHeight, 25, 20);
    locationBtn.frame   = CGRectMake(145, 430 - keyboardHeight, 20, 20);
    topicBtn.frame      = CGRectMake(180, 430 - keyboardHeight, 20, 20);
    atBtn.frame         = CGRectMake(210, 423 - keyboardHeight, 28, 34);
    
    imageIconView.frame = CGRectMake(280, 430 - keyboardHeight, 30, 30);
    picBtn.frame        = CGRectMake(280, 430 - keyboardHeight, 30, 30);
    characterSize.frame = CGRectMake(278, 410 - keyboardHeight, 38, 21);

}

//检测textview变化
- (void) textViewDidChange:(UITextView *)textView
{
    int strLen = [[textView text] strLength];
    if (strLen % 2 ==0) {
        strLen = 140 - strLen / 2;
    } else {
        strLen = 140 - strLen / 2 - 1;
    }
    
    NSString *txtLen = [[NSString alloc] initWithFormat:@"%d", strLen];
    self.characterSize.text = txtLen;
    
    //如果超过字数则发送按钮失效,字数显示红色
    if (strLen < 0 || strLen == 140) {
        self.sendItem.enabled = NO;
        if (strLen < 0) {
            self.characterSize.textColor = [UIColor redColor];
        }
    } else {
        self.sendItem.enabled = YES;
        self.characterSize.textColor = [UIColor blackColor];
    }
}

- (IBAction) sendWeiBo:(id)sender {    
    //检测当前网络是否通畅
    if (![OtherUtil isNetConnection]) {
        [self networkError];
        return;
    }
    
    self.sendItem.enabled = NO;
        
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD setFrame:CGRectMake(0, 0, 320, 270)];
    HUD.dimBackground = YES;
    HUD.delegate = self;
    HUD.labelText = @"正在发送...";
    [HUD showWhileExecuting:@selector(sendTask) onTarget:self withObject:nil animated:YES];
}

- (void) sendTask {
    NSString *weiboString = [NSString stringWithString:[self.content text]];
    [weiboString UTF8String];
    
    NSMutableDictionary *param = [[[NSMutableDictionary alloc] init] autorelease];
    
    Account *account = [[Account alloc] init];
    NSArray *accountArray = [account getAccountList];
    [account release];
    for (NSDictionary *accountInfo in accountArray) {
        [param removeAllObjects];
        [param setValue:weiboString forKey:@"content"];
        [param setValue:[accountInfo objectForKey:@"Token"] forKey:@"token"];
        [param setValue:[accountInfo objectForKey:@"TokenSecret"] forKey:@"tokenSecret"];
        
        if ([@"QQ" isEqualToString:[accountInfo objectForKey:@"Type"]]) {
            if (imageSmallView.image != nil) {
                [self sendQQWithImage:param];
            } else {
                [self sendQQ:param];
            }
            
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = [NSString stringWithFormat:@"腾讯微薄<%@>发送成功", [accountInfo objectForKey:@"NickName"]];
            sleep(1);
            
        } else if ([@"Sina" isEqualToString:[accountInfo objectForKey:@"Type"]]) {
            if (imageSmallView.image != nil) {
                [self sendSinaWithImage:param];
            } else {
                [self sendSina:param];
            }
            
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = [NSString stringWithFormat:@"新浪微薄<%@>发送成功", [accountInfo objectForKey:@"NickName"]];
            sleep(1);
            
        }
        
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.labelText = @"正在发送...";
    }
    
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = @"发送完成";
    sleep(1);
}

- (void) sendQQ:(NSDictionary *) param {
    //发一条微薄
    NSMutableDictionary *parameters = [[[NSMutableDictionary alloc] init] autorelease];
    [parameters setValue:[param objectForKey:@"content"] forKey:@"content"];
    [parameters setValue:@"127.0.0.1" forKey:@"clientip"];
    [parameters setValue:@"" forKey:@"Jing"];
    [parameters setValue:@"" forKey:@"Wei"];
    
    QQWeiBo *qqWeibo = [[QQWeiBo alloc] init];
    [qqWeibo apiSynPostRequest:@"t/add"
                         token:[param objectForKey:@"token"]
                   tokenSecret:[param objectForKey:@"tokenSecret"]
                    parameters:parameters];
    
    [qqWeibo release];
}

- (void) sendQQWithImage:(NSDictionary *)param {
    //发一条微薄
    NSMutableDictionary *parameters = [[[NSMutableDictionary alloc] init] autorelease];
    [parameters setValue:[param objectForKey:@"content"] forKey:@"content"];
    [parameters setValue:@"127.0.0.1" forKey:@"clientip"];
    [parameters setValue:@"" forKey:@"Jing"];
    [parameters setValue:@"" forKey:@"Wei"];
    
    QQWeiBo *qqWeibo = [[QQWeiBo alloc] init];
    [qqWeibo apiSynPostImageWithRequsetMethod:@"t/add_pic"
                         token:[param objectForKey:@"token"]
                   tokenSecret:[param objectForKey:@"tokenSecret"]
                    imageData:[self getNSDataFromUIImage:self.imageSmallView.image]
                    parameters:parameters];
    
    [qqWeibo release];
}

- (void) sendSina:(NSDictionary *) param {    
    //发一条微薄
    NSMutableDictionary *parameters = [[[NSMutableDictionary alloc] init] autorelease];
    [parameters setValue:[param objectForKey:@"content"] forKey:@"status"];
    
    SinaWeiBo *sinaWeibo = [[SinaWeiBo alloc] init];
    [sinaWeibo apiSynPostRequest:@"statuses/update.json"
                           token:[param objectForKey:@"token"]
                     tokenSecret:[param objectForKey:@"tokenSecret"]
                      parameters:parameters];
    
    [sinaWeibo release];
}

//带图片
- (void) sendSinaWithImage:(NSDictionary *) param {    
    //发一条微薄
    NSMutableDictionary *parameters = [[[NSMutableDictionary alloc] init] autorelease];
    [parameters setValue:[param objectForKey:@"content"] forKey:@"status"];
    
    SinaWeiBo *sinaWeibo = [[SinaWeiBo alloc] init];
    [sinaWeibo apiSynPostImageWithRequsetMethod:@"statuses/upload.json"
                                           token:[param objectForKey:@"token"]
                                     tokenSecret:[param objectForKey:@"tokenSecret"]
                                       imageData:[self getNSDataFromUIImage:imageSmallView.image]
                                      parameters:parameters];
    
    [sinaWeibo release];
}

- (void)hudWasHidden:(MBProgressHUD *)hud 
{
    [hud removeFromSuperview];
    [hud release];
	//hud = nil;
    
    if(imageData) {
        imageData = nil;
    }
    
    [self backToIndex:nil];
}

- (IBAction) backToIndex:(id)sender {
    //[[self parentViewController] dismissModalViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}

- (void) animationFinished {
    [self.view removeFromSuperview];
}

//打开相机
- (IBAction) openCanmera:(id)sender {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        //imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentModalViewController:imagePicker animated:YES];
        [imagePicker release];
    }
}

//打开相册
- (IBAction) openPhotoLibrary:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    //imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:imagePicker animated:YES];
    [imagePicker release];
}

//取消
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES]; 
}

//选择图片
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [[info objectForKey:UIImagePickerControllerOriginalImage] retain];
    [picker dismissModalViewControllerAnimated:YES];
    [self performSelector:@selector(saveImage:)
               withObject:image 
               afterDelay:0.5];
}

- (void) saveImage:(UIImage *)image {
    
    if (self.imageIconView.image != nil) {
        [self deleteImage];
    }
    
    self.imageIconView.image = image;
    
    float width, height, imageWidth, imageHeight;
    
    width = imageWidth = image.size.width;
    height = imageHeight = image.size.height;
    
    //等比例缩小图片
    if (imageWidth > 280 || imageHeight > 190) {
        float multiple = (imageWidth / 280) > (imageHeight / 190) ? ((imageWidth / 280)) : (imageHeight / 190);
        width = width / multiple;
        height = height / multiple;
    } 
    
    self.imageSmallView = [[UIImageView alloc] init];
    self.imageSmallView.frame = CGRectMake(160 - (width / 2), 253, width, height);
    self.imageSmallView.image = image;
    self.imageSmallView.userInteractionEnabled = YES;
    
    //添加图片边框
    self.imageSmallView.layer.masksToBounds = YES;
    self.imageSmallView.layer.cornerRadius = 5.0; 
    self.imageSmallView.layer.borderWidth = 2.0;
    self.imageSmallView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    //图片添加单击事件
    self.imageSmallView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapImage)];
    [self.imageSmallView addGestureRecognizer:singleTap];
    [singleTap release];
    
    [self.view insertSubview:imageSmallView atIndex:1];
    
    //添加删除图片按钮
    self.delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.delBtn.frame = CGRectMake(160 - (width / 2) - 10, 243, 20, 20);
    [self.delBtn setBackgroundImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    [self.delBtn setShowsTouchWhenHighlighted:YES];
    [self.delBtn addTarget:self action:@selector(deleteImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:delBtn atIndex:0];
    [self.view bringSubviewToFront:delBtn];
    
    [self.content becomeFirstResponder];
}

//单击图片全屏显示图片
- (void) singleTapImage {    
    NSMutableArray *photos = [[[NSMutableArray alloc] init] autorelease];
    [photos addObject:[MWPhoto photoWithImage:self.imageIconView.image]];
    
    MWPhotoBrowser *browser = [[[MWPhotoBrowser alloc] initWithPhotos:photos] autorelease];
    [browser setSave:NO];
	[self presentModalViewController:browser animated:YES];
}

- (void) deleteImage {
    if (self.imageIconView.image != nil) {
        self.imageIconView.image = nil;
        [self.imageSmallView removeFromSuperview];
        [self.delBtn removeFromSuperview];
        [self.content becomeFirstResponder];
    }
}

- (IBAction) showAndHideKeyBorad:(id)sender {
    if (self.imageIconView.image != nil) {
        if ([self.content isFirstResponder]) {
            [self.content resignFirstResponder];
        } else {
            [self.content becomeFirstResponder];
        }
    }
}

- (IBAction) showImage:(id)sender {
    NSMutableArray *photos = [[[NSMutableArray alloc] init] autorelease];
    [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://fmn.rrimg.com/fmn052/20110605/1135/p_large_kgPt_5a1700007e125c44.jpg"]]];
    MWPhotoBrowser *browser = [[[MWPhotoBrowser alloc] initWithPhotos:photos] autorelease];
    [browser setSave:YES];
	[self presentModalViewController:browser animated:YES];
    NSLog(@"@show");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [content release];
    [imageIconView release];
    [imageSmallView release];
    [delBtn release];
    [HUD release];
    [saveBtn release];
    [cameraBtn release];
    [imgBtn release];
    [locationBtn release];
    [topicBtn release];
    [atBtn release];
    [picBtn release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
