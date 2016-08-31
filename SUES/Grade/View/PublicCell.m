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
@property (weak, nonatomic) IBOutlet UILabel *fistLabel;
@property (weak, nonatomic) IBOutlet UILabel *twoLabel;
@property (weak, nonatomic) IBOutlet UILabel *threeLabel;
@property (weak, nonatomic) IBOutlet UILabel *fourLabel;
@property (weak, nonatomic) IBOutlet UILabel *fiveLabel;


@end

@implementation PublicCell

//配置
-(void)configModel:(id)model
{
    if ([model isKindOfClass:[Grade class]]) {
        Grade *grade = model;
        self.courseName.text = grade.name;
        self.courseCredit.text = grade.credit;
        self.courseFinalGrade.text = grade.finalGrade;
        self.courseCategory.text = grade.category;
        self.gradePoint.text = grade.gradePoint;
    } else if([model isKindOfClass:[Exam class]]) {
        Exam *exam = model;
        self.twoLabel.text = @"考试时间:";
        self.threeLabel.text = @"考试安排:";
        self.fourLabel.text = @"考试地点:";
        self.fiveLabel.text = @"考试类型:";
        self.courseName.text = exam.examName;
        self.courseCredit.text = exam.examPlan;
        self.courseFinalGrade.text = exam.examLocale;
        self.courseCategory.text = exam.examDate;
        self.gradePoint.text = [self examCategory:exam.examCategory];
    }
}
- (void)awakeFromNib {
    // Initialization code
    
    
}

- (NSString *)examCategory:(NSString *)category
{
    NSInteger type = [category integerValue];
    switch (type) {
        case 1:
            return @"期末考试";
            break;
        case 2:
            return @"期中考试";
            break;
        case 3:
            return @"补考";
            break;
            
        default:
            break;
    }
    return @"未知";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
