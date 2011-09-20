//
//  MoreLoadCell.m
//  caibo
//
//  Created by jacob on 11-6-8.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoreLoadCell.h"

@implementation MoreLoadCell

@synthesize spinner;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(-5, 0, 330, 50)];
		label.backgroundColor = [UIColor whiteColor];
		label.font = [UIFont systemFontOfSize:20];
		label.textAlignment = UITextAlignmentCenter;
		label.textColor = [UIColor blackColor];
		label.numberOfLines = 0;
		label.text = @"载入更多...";
		[self.contentView addSubview:label];
		[label release];
        
		spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
		spinner.frame = CGRectMake(210, 10, 24, 24);
		[self.contentView addSubview:spinner];
    }
    return self;
}

// 开始旋转
-(void)spinnerStartAnimating
{
	[spinner startAnimating];
}

// 停止旋转
-(void)spinnerStopAnimating
{
	[spinner stopAnimating];
}

- (void)setText:(NSString *)text
{
    label.text = text;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{    
    [super setSelected:selected animated:animated];
}

- (void)dealloc 
{
    [super dealloc];
}


@end
