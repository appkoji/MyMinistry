//
//  DatePickView.m
//  MyMinistry
//
//  Created by Koji Murata on 09/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "DatePickView.h"
#import "AppDelegate.h"
#import "AddReport.h"

@interface DatePickView ()

@property (strong, nonatomic) IBOutlet UIView *calendarContainer;
@property (strong, nonatomic) IBOutlet UILabel *monthLabel;
@property (strong, nonatomic) IBOutlet UIImageView *bgImg;

@property (strong, nonatomic) NSDate *originallySelectedDate;

- (IBAction)nextMonth:(id)sender;
- (IBAction)previousMonth:(id)sender;
- (IBAction)datePicked:(id)sender;

@property NSInteger year;   //2018
@property NSInteger month;  //10
@property NSInteger day;    //14

@end

@implementation DatePickView


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //identify each stack and dates
    if (!_currentDate) {
        _currentDate = [NSDate date];
    }
    
    _originallySelectedDate = _currentDate;
    [self getCalendarDataForMonth:_currentDate];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self readBgImage];
}


// returns calendar data for particular month: start date, last date,
- (void)getCalendarDataForMonth:(NSDate *)currentDate {
    
    _year = [self getYear:currentDate];
    _month = [self getMonth:currentDate];
    _day = [self getDay:currentDate];

    
    //clean up
    [_calendarContainer.subviews enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj restorationIdentifier] containsString:@"week"]) {
            [[obj subviews] enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull dayBtn, NSUInteger idx, BOOL * _Nonnull stop) {
                [dayBtn setTitle:nil forState:UIControlStateNormal];
                [dayBtn setExclusiveTouch:YES];
                [dayBtn setAlpha:1.0];
                [dayBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            }];
            [obj setAlpha:1.0];
        }
    }];
    
    NSDate *firstDateOfMonth = [self firstDayOfMonth:currentDate];
    NSInteger firstDateIndex = [self dateIndex:firstDateOfMonth];
    
    NSDate *lastDateOfMonth = [self lastDayOfMonth:currentDate];
    NSInteger lastDateIndex = [self getDay:lastDateOfMonth];
    
    NSLog(@"firstDay:%ld lastDay:%ld", (long)firstDateIndex, (long)lastDateIndex);
    
    __block NSInteger tagOfFirstDate;
    
    //set first day
    [_calendarContainer.subviews enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj restorationIdentifier] containsString:@"week1"]) {
            [[obj subviews] enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull dayBtn, NSUInteger idx, BOOL * _Nonnull stop) {
                if (dayBtn.tag == firstDateIndex) {
                    [dayBtn setTitle:@"1" forState:UIControlStateNormal];
                    tagOfFirstDate = [dayBtn.accessibilityIdentifier integerValue];
                }
            }];
        }
    }];
    
    
    //set day to the rest of the month
    [_calendarContainer.subviews enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj restorationIdentifier] containsString:@"week"]) {
            [[obj subviews] enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull dayBtn, NSUInteger idx, BOOL * _Nonnull stop) {
                //all buttons go here
                NSInteger index = [dayBtn.accessibilityIdentifier integerValue]; // buttons index pointer count
                NSInteger dateCalc = index-tagOfFirstDate+1; // this is what to write on button as a day date.
                if (index > tagOfFirstDate && index < lastDateIndex+tagOfFirstDate) {
                    [dayBtn setTitle:[NSString stringWithFormat:@"%ld", (long)dateCalc] forState:UIControlStateNormal];
                }
                if (index == [self getDay:[NSDate date]] && [self getMonth:_currentDate] == [self getMonth:[NSDate date]]) {
                    [dayBtn setTitleColor:dayBtn.tintColor forState:UIControlStateNormal];
                }
            }];
        }
    }];
    
    //hide unnecessary week
    [_calendarContainer.subviews enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj restorationIdentifier] containsString:@"week"]) {
            [[obj subviews] enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull dayBtn, NSUInteger idx, BOOL * _Nonnull stop) {
                if (!dayBtn.currentTitle) {
                    [dayBtn setAlpha:0.3];//
                }
            }];
        }
        //check for last week
        if ([[obj restorationIdentifier] containsString:@"week6"]) {
            [[obj subviews] enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull dayBtn, NSUInteger idx, BOOL * _Nonnull stop) {
                if (dayBtn.tag == 0) {
                    if (!dayBtn.currentTitle) {
                        [obj setAlpha:0.0];
                    }
                }
            }];
        }
    }];
    
    //update interface
    [_monthLabel setText:[self getMonthYearString:currentDate]];
    
}



- (NSDate *)firstDayOfMonth:(NSDate *)month {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:month];
    [comp setDay:1];
    return [gregorian dateFromComponents:comp];
}
- (NSDate *)lastDayOfMonth:(NSDate *)month {
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDate *plusOneMonthDate = [self dateByAddingMonths:1 toDate:month];
    NSDateComponents * plusOneMonthDateComponents = [calendar components: NSCalendarUnitYear | NSCalendarUnitMonth fromDate: plusOneMonthDate];
    return [[calendar dateFromComponents: plusOneMonthDateComponents] dateByAddingTimeInterval: -1]; // One second before the start of next month
}
- (NSDate *)dateByAddingMonths:(NSInteger)monthsToAdd toDate:(NSDate *)inputDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *months = [[NSDateComponents alloc] init];
    [months setMonth:monthsToAdd];
    return [calendar dateByAddingComponents:months toDate:inputDate options: 0];
}

- (NSInteger)getDay:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd"];
    return [[dateFormatter stringFromDate:date] integerValue];
}
- (NSInteger)getMonth:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    return [[dateFormatter stringFromDate:date] integerValue];
}
- (NSInteger)getYear:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    return [[dateFormatter stringFromDate:date] integerValue];
}
- (NSString *)getMonthYearString:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM yyyy"];
    return [dateFormatter stringFromDate:date];
}

- (NSInteger)dateIndex:(NSDate *)inputDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE"];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    NSString *dayOfWeek = [dateFormatter stringFromDate:inputDate];
    
    if ([dayOfWeek hasPrefix:@"Mon"]) {
        return 1;
    } if ([dayOfWeek hasPrefix:@"Tue"]) {
        return 2;
    } if ([dayOfWeek hasPrefix:@"Wed"]) {
        return 3;
    } if ([dayOfWeek hasPrefix:@"Thu"]) {
        return 4;
    } if ([dayOfWeek hasPrefix:@"Fri"]) {
        return 5;
    } if ([dayOfWeek hasPrefix:@"Sat"]) {
        return 6;
    }
    
    return 0; //Sunday
}

- (NSDate *)requestDate {
    
    NSString *dateStr = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)_day, (long)_month, (long)_year];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    return [dateFormatter dateFromString:dateStr];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    if (self.navigationController) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    //NSString *str = [self.parent setDate:_datePicker.date];
    //save while returning date to parent view controller
    [self dismissViewControllerAnimated:YES completion:^{
        [self.parent setMonthDate:_datePicker.date];
    }];
}

- (IBAction)nextMonth:(id)sender {
    
    _currentDate = [self dateByAddingMonths:1 toDate:_currentDate];
    [self getCalendarDataForMonth:_currentDate];
    
}

- (IBAction)previousMonth:(id)sender {
    _currentDate = [self dateByAddingMonths:-1 toDate:_currentDate];
    [self getCalendarDataForMonth:_currentDate];
}

- (IBAction)datePicked:(id)sender {
    
    if ([sender currentTitle]) {
        _day = [[sender currentTitle] integerValue];
        NSDate *returnedDate = [self requestDate];
        
        // set date
        if ([self.parent respondsToSelector:@selector(setMonthDate:)]) {
            [self.parent setMonthDate:returnedDate];
        }
        

        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }
        NSLog(@"returedDate %@", returnedDate);
    }
}

- (void)readBgImage {
    NSLog(@"attempt to claim image from app delegate, update with transition");
    //check if app delegate has latest image
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate updateBGImageEntry];
    if (appDelegate.commonBGImages) {
        self.bgImg.image = appDelegate.commonBGImages;
    } else {
        self.bgImg.image = [UIImage imageNamed:@"mibg-02"];
    }
}

@end
