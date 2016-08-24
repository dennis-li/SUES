//
//  PublicCell.m
//  SohuByObject_C
//
//  Created by lixu on 16/5/2.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "PublicCell.h"
#import "Public.h"


@interface PublicCell ()

@end

@implementation PublicCell

//配置
-(void)configModel:(Grade *)grade
{
    self.courseName.text = grade.name;
    self.courseCredit.text = grade.credit;
    self.courseFinalGrade.text = grade.finalGrade;
    self.courseCategory.text = grade.category;
    self.gradePoint.text = grade.gradePoint;
    
}


- (void)awakeFromNib {
    // Initialization code
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
