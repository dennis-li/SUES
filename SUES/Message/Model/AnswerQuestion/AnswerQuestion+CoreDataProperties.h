//
//  AnswerQuestion+CoreDataProperties.h
//  
//
//  Created by lixu on 16/9/2.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "AnswerQuestion.h"

NS_ASSUME_NONNULL_BEGIN

@interface AnswerQuestion (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *courseCode;
@property (nullable, nonatomic, retain) NSString *credit;
@property (nullable, nonatomic, retain) NSString *date;
@property (nullable, nonatomic, retain) NSString *locale;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *semesterId;
@property (nullable, nonatomic, retain) NSString *teacher;
@property (nullable, nonatomic, retain) NSString *time;
@property (nullable, nonatomic, retain) User *whoAnswerQuestion;

@end

NS_ASSUME_NONNULL_END
