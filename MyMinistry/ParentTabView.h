//
//  ParentTabView.h
//  MyMinistry
//
//  Created by Koji Murata on 08/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

/*
 Use Airdrop for viral marketing strategy...
 */

#import <UIKit/UIKit.h>

typedef void (^Completion)(BOOL success);

@interface ParentTabView : UITabBarController <UITabBarControllerDelegate>

@property (copy, nonatomic) Completion completeLoading;

@property (strong, nonatomic) NSUserDefaults *saveData;
@property (strong, nonatomic) NSDictionary *constDat;
@property (strong, nonatomic) NSMutableArray *reportDataEntries;
@property (strong, nonatomic) NSDate *today;
@property (strong, nonatomic) NSDate *selectedDate;
@property NSString *mIdentifier;
@property (strong, nonatomic) NSDictionary *currentMonthData;
@property NSInteger currentNotificationValue;

@property int excessHours; // Excess hours will be forwarded to the preceeding month's hour.

- (BOOL)addRecordWithTest:(NSDictionary *)reportDataToAdd;
- (void)setRecordsForCurrentMonth;
- (void)removeRecordAtIndex:(NSInteger)index forMonth:(NSDate *)month;
- (void)updateRecord:(NSMutableDictionary *)updatedRecord AtIndex:(NSInteger)index forMonth:(NSDate *)month;

- (void)setReportDataEntriesToDate:(NSDate *)inputDate;
- (void)setReportDataEntriesToDate:(NSDate *)inputDate withCompletion:(void (^)(BOOL success))completion;

- (void)updateMonthlyReports:(NSDate *)inputDate fromCloud:(BOOL)use;

- (NSMutableArray *)getReportDataFromCloudWithDate:(NSDate *)inputDate;
- (NSInteger)dayToday;
- (NSString *)localizedText:(NSString *)identifier;
- (NSString *)getMonthYearKey:(NSString *)inputMMYY;
- (NSString *)getMonth:(NSDate *)inputDate;
- (NSDictionary *)monthlyBasedCalculatedReport:(NSDate *)date;
- (NSArray *)availableMonths;
- (NSDate *)getLastMonthYear;
- (NSString *)getDateInWordsFrom:(NSString *)inputFormattedDate;
- (NSString *)convertMonthYear:(NSDate *)inputDate;
- (void)showNotification:(NSInteger)value;
- (void)updateTabDisplayLanguage;
- (NSArray *)serviceYearData;

- (NSString *)timeFormatted:(int)unformattedTime;

@end
