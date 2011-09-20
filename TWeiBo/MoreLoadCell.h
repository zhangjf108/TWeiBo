//
//  MoreLoadCell.h
//  caibo
//
//  Created by jacob on 11-6-8.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MoreLoadCell : UITableViewCell 
{
	UILabel *label;
	UIActivityIndicatorView *spinner;
}

@property(nonatomic,readonly) UIActivityIndicatorView *spinner;

// 开始旋转
-(void)spinnerStartAnimating;
// 停止旋转
-(void)spinnerStopAnimating;

- (void)setText:(NSString *)text;

@end




