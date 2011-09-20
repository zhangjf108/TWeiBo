//
//  SendViewController.h
//  TWeiBo
//
//  Created by 健锋 章 on 11-8-20.
//  Copyright 2011年 Zelome Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface SendViewController : UIViewController<UITextViewDelegate, MBProgressHUDDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    IBOutlet UITextView *content;
    IBOutlet UILabel *characterSize;
    IBOutlet UIBarButtonItem *sendItem;
    IBOutlet UIImageView *imageIconView;
    IBOutlet UIImageView *imageSmallView;
    IBOutlet UIButton *delBtn;
    
    //一排小图标
    IBOutlet UIButton *saveBtn;
    IBOutlet UIButton *cameraBtn;
    IBOutlet UIButton *imgBtn;
    IBOutlet UIButton *locationBtn;
    IBOutlet UIButton *topicBtn;
    IBOutlet UIButton *atBtn;
    IBOutlet UIButton *picBtn;
}

@property (nonatomic, retain) IBOutlet UITextView *content;
@property (nonatomic, retain) IBOutlet UILabel *characterSize;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *sendItem;
@property (nonatomic, retain) IBOutlet UIImageView *imageIconView;
@property (nonatomic, retain) IBOutlet UIImageView *imageSmallView;
@property (nonatomic, retain) IBOutlet UIButton *delBtn;

- (IBAction) backToIndex:(id)sender;
- (IBAction) sendWeiBo:(id)sender;
- (IBAction) openCanmera:(id)sender;
- (IBAction) openPhotoLibrary:(id)sender;

//显示隐藏键盘
- (IBAction) showAndHideKeyBorad:(id)sender;

//显示大图
- (IBAction) showImage:(id)sender;

- (void) sendTask;
- (void) sendQQ:(NSDictionary *) param;
- (void) sendQQWithImage:(NSDictionary *)param;
- (void) sendSina:(NSDictionary *) param;
- (void) sendSinaWithImage:(NSDictionary *) param;
- (void) saveImage:(UIImage *)image;
- (void) deleteImage;

@end
