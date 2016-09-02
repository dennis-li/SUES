//
//  User+CoreDataProperties.h
//  
//
//  Created by lixu on 16/9/2.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *password;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSSet<Courses *> *courses;
@property (nullable, nonatomic, retain) NSSet<Exam *> *exam;
@property (nullable, nonatomic, retain) NSSet<Grade *> *grade;
@property (nullable, nonatomic, retain) NSSet<AnswerQuestion *> *answerQuestion;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addCoursesObject:(Courses *)value;
- (void)removeCoursesObject:(Courses *)value;
- (void)addCourses:(NSSet<Courses *> *)values;
- (void)removeCourses:(NSSet<Courses *> *)values;

- (void)addExamObject:(Exam *)value;
- (void)removeExamObject:(Exam *)value;
- (void)addExam:(NSSet<Exam *> *)values;
- (void)removeExam:(NSSet<Exam *> *)values;

- (void)addGradeObject:(Grade *)value;
- (void)removeGradeObject:(Grade *)value;
- (void)addGrade:(NSSet<Grade *> *)values;
- (void)removeGrade:(NSSet<Grade *> *)values;

- (void)addAnswerQuestionObject:(AnswerQuestion *)value;
- (void)removeAnswerQuestionObject:(AnswerQuestion *)value;
- (void)addAnswerQuestion:(NSSet<AnswerQuestion *> *)values;
- (void)removeAnswerQuestion:(NSSet<AnswerQuestion *> *)values;

@end

NS_ASSUME_NONNULL_END
