//
//  PublicCell.h
//  SohuByObject_C
//
//  Created by lixu on 16/5/2.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Grade+Flickr.h"

@interface PublicCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *courseName;
@property (weak, nonatomic) IBOutlet UILabel *courseCategory;
@property (weak, nonatomic) IBOutlet UILabel *courseCredit;
@property (weak, nonatomic) IBOutlet UILabel *courseFinalGrade;
@property (weak, nonatomic) IBOutlet UILabel *gradePoint;
-(void)configModel:(Grade *)grade;
@end
