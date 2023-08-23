//
//  ParentTabView.m
//  MyMinistry
//
//  Created by Koji Murata on 08/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "ParentTabView.h"
#import "OverviewScene.h"
#import "InstructionViewController.h"
#import "AppDelegate.h"
@interface ParentTabView ()

@end

@implementation ParentTabView

/*
 User device default settings
 {Lang}
 JA Japanese
 EN English
 
 First user settings
 1. Language
 2. What is your Name?
 3. Would you like to set your monthly goals? (Can be edited later)
 4. Welcome to Ministry Plus
 */

- (NSString *)localizeWithText:(NSString *)inputIdentifier {
    /*
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"localizedDisplayTexts" ofType:@"plist"]];
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    NSString *userLang = @"EN";
    if ([saveData objectForKey:@"userSetting-lang"]) {
        userLang = [saveData objectForKey:@"userSetting-lang"];
    }
    return [[dic objectForKey:inputIdentifier] objectForKey:userLang];
     */
    return NSLocalizedString(inputIdentifier, nil);
}

- (NSString *)localizedText:(NSString *)identifier {
    /*
    NSString *lang = [_saveData objectForKey:@"userSetting-lang"];
    NSString *returnedStr = [[[_constDat objectForKey:@"displayText"] objectForKey:identifier] objectForKey:lang];
    NSLog(@"localizedText %@", returnedStr);
    return returnedStr;
     */
    return NSLocalizedString(identifier, nil);
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[OverviewScene class]] == YES) {
        NSLog(@"OverviewScene detected");
    }
    //
    [self checkForImageUpdate];
}

- (void)tabBarController:(UITabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers changed:(BOOL)changed {
    
}

- (void)updateTabDisplayLanguage {
    
    //NSArray *barTitles = [NSArray arrayWithObjects:[self localizeWithText:@"home"], [self localizeWithText:@"add"], [self localizeWithText:@"records"], nil];
    //for (UIViewController *viewController in self.viewControllers) {
        //viewController.title = [barTitles objectAtIndex:[self.viewControllers indexOfObject:viewController]];
    //}
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    
    //graphic design
    self.view.layer.masksToBounds = YES;
    [self.view.layer setCornerRadius:5.0];
    
    _today = [NSDate date];
    _selectedDate = _today;
    
    //load datas
    _saveData = [NSUserDefaults standardUserDefaults]; //startup data
    _constDat = [NSDictionary dictionaryWithContentsOfFile:[self plist:@"appLogic"]]; //load constant data
        
    _currentMonthData = [self monthlyBasedCalculatedReport:[NSDate date]];
    
    [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setTitle:nil];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            obj.imageInsets = UIEdgeInsetsZero;
        } else {
            obj.imageInsets = UIEdgeInsetsMake(0, 0, -8, 0);
        }
    }];
    
}

- (void)showNotification:(NSInteger)value {
    UITabBarItem *homeTab = [self.tabBar.items objectAtIndex:0];
    if (value > 0) {
        [homeTab setBadgeColor:[UIColor redColor]];
        [homeTab setBadgeValue:[NSString stringWithFormat:@"%ld", value]];
        _currentNotificationValue = value;
    } else {
        [homeTab setBadgeColor:[UIColor clearColor]];
        [homeTab setBadgeValue:@"0"];
        _currentNotificationValue = 0;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    
    //preset
    [self checkForImageUpdate];
    
    //turn tab into blurred backgorund
    CGRect tabBounds = self.tabBar.bounds;
    UIVisualEffectView *visualFXView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    visualFXView.frame = tabBounds;
    
    visualFXView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tabBar addSubview:visualFXView];
    [self.tabBar sendSubviewToBack:visualFXView];
    [self.tabBar setBackgroundImage:[UIImage new]];
    [self.tabBar setShadowImage:[UIImage new]];
    [self.tabBar setTranslucent:YES];
    [self.tabBar setAccessibilityValue:[NSString stringWithFormat:@"%f",self.tabBar.frame.origin.y]];
    
    //This method run only once every launch. <main root>
    //check if user has basic settings done
    if ([_saveData objectForKey:@"appGuide"]) {
        
    } else {
        
        InstructionViewController *instView = [self.storyboard instantiateViewControllerWithIdentifier:@"InstructionViewController"];
        [self presentViewController:instView animated:YES completion:^{
            //start showing instruction view
        }];
    }
    
    [self updateTabDisplayLanguage];
    
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSLog(@"TABBAR didSelectItem %@", item.title);
}

// Database Management

- (void)setRecordsForCurrentMonth {
    _currentMonthData = [self monthlyBasedCalculatedReport:[NSDate date]];
    [self setReportDataEntriesToDate:[NSDate date]];
}

- (void)removeRecordAtIndexFromCurrentReportData:(NSInteger)index {
    NSDictionary *currentData = [_reportDataEntries objectAtIndex:index];
    NSLog(@"removeRecordAtIndexFromCurrentReportData data:%@ index:%ld", currentData, (long)index);
    
    [_reportDataEntries removeObjectAtIndex:index];
}

- (NSInteger)getNumberedDate:(NSString *)inputDate {
    //dat-MM-yyyy -> yyyyMM
    NSArray *dateCmd = [inputDate componentsSeparatedByString:@"-"];
    NSString *formattedDate = [NSString stringWithFormat:@"%@%@", dateCmd[2], dateCmd[1]];
    return [formattedDate integerValue];
}

- (NSMutableArray *)returnCurrentServiceYearMonths {
    
    // Data Initialization
    NSMutableArray *currentServiceMonths = [NSMutableArray new];
    NSDate *today = [NSDate date];
    NSString *countableYMToday = [self getCountableMonthYear:today]; //dat-06-2019
    NSArray *datDeconstr = [countableYMToday componentsSeparatedByString:@"-"];
    
    int currentMonth = [[datDeconstr objectAtIndex:1] intValue];  // 06
    int currentYear = [[datDeconstr objectAtIndex:2] intValue];   // 2019
    
    int currentSvMonth = [[NSString stringWithFormat:@"%d%02d",currentYear, currentMonth] intValue];
    // minus year if month is on january until august
    if (currentMonth > 0 && currentMonth < 9) {
        currentYear = currentYear - 1;
    }
    //
    int addYear = 0;
    if (currentMonth > 8) {
        addYear = 1;
    }
    
    [currentServiceMonths addObject:[NSString stringWithFormat:@"dat-01-%d", currentYear+1]];
    [currentServiceMonths addObject:[NSString stringWithFormat:@"dat-02-%d", currentYear+1]];
    [currentServiceMonths addObject:[NSString stringWithFormat:@"dat-03-%d", currentYear+1]];
    [currentServiceMonths addObject:[NSString stringWithFormat:@"dat-04-%d", currentYear+1]];
    [currentServiceMonths addObject:[NSString stringWithFormat:@"dat-05-%d", currentYear+1]];
    [currentServiceMonths addObject:[NSString stringWithFormat:@"dat-06-%d", currentYear+1]];
    [currentServiceMonths addObject:[NSString stringWithFormat:@"dat-07-%d", currentYear+1]];
    [currentServiceMonths addObject:[NSString stringWithFormat:@"dat-08-%d", currentYear+1]];
    [currentServiceMonths addObject:[NSString stringWithFormat:@"dat-09-%d", currentYear]];
    [currentServiceMonths addObject:[NSString stringWithFormat:@"dat-10-%d", currentYear]];
    [currentServiceMonths addObject:[NSString stringWithFormat:@"dat-11-%d", currentYear]];
    [currentServiceMonths addObject:[NSString stringWithFormat:@"dat-12-%d", currentYear]];
    [currentServiceMonths addObject:[NSString stringWithFormat:@"dat-08-%d", currentYear]]; // last year

    // remove future dates
    NSMutableArray *svToRemove = [NSMutableArray new];
    for (int i = 0; i < currentServiceMonths.count; i++) {
        NSArray *currentDateCtr = [currentServiceMonths[i] componentsSeparatedByString:@"-"];
        int sMonth = [[currentDateCtr objectAtIndex:1] intValue];
        int sYear = [[currentDateCtr objectAtIndex:2] intValue];
        int sSvMonth = [[NSString stringWithFormat:@"%d%02d",sYear, sMonth] intValue];
        if (sSvMonth > currentSvMonth) {
            [svToRemove addObject:currentServiceMonths[i]];
        }
    }
    
    for (int i = 0; i < svToRemove.count; i++) {
        [currentServiceMonths removeObject:svToRemove[i]];// remove equal object
        NSLog(@"removeFutureDate %@", svToRemove[i]);
    }
    
    // sort
    [currentServiceMonths sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSInteger day1 = [self getNumberedDate:obj1];
        NSInteger day2 = [self getNumberedDate:obj2];
        if (day1 > day2) {
            return (NSComparisonResult)NSOrderedAscending;
        } if (day1 < day2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return currentServiceMonths;
    
}

- (NSArray *)availableMonths {
    return [self returnCurrentServiceYearMonths];
}

- (NSArray *)serviceYearData {
    
    // get current service year
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateByAddingComponents:[NSDateComponents new] toDate:today options:0];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
    NSInteger year = [components year];
    NSInteger month = [components month];
    
    __block NSInteger totalHours = 0;
    
    int monthDisplayCount = 13;
    NSString *serviceMonth[monthDisplayCount];
    NSInteger addServiceYear = 0;
    
    if (month > 8) {
        // new service year has started
        addServiceYear = 1;
    }
    
    // if year is this year, start with the current year.
    serviceMonth[0] = [NSString stringWithFormat:@"01-%02ld", (long)year+addServiceYear];
    serviceMonth[1] = [NSString stringWithFormat:@"02-%02ld", (long)year+addServiceYear];
    serviceMonth[2] = [NSString stringWithFormat:@"03-%02ld", (long)year+addServiceYear];
    serviceMonth[3] = [NSString stringWithFormat:@"04-%02ld", (long)year+addServiceYear];
    serviceMonth[4] = [NSString stringWithFormat:@"05-%02ld", (long)year+addServiceYear];
    serviceMonth[5] = [NSString stringWithFormat:@"06-%02ld", (long)year+addServiceYear];
    serviceMonth[6] = [NSString stringWithFormat:@"07-%02ld", (long)year+addServiceYear];
    serviceMonth[7] = [NSString stringWithFormat:@"08-%02ld", (long)year+addServiceYear]; // last month of next service year.
    serviceMonth[8] = [NSString stringWithFormat:@"09-%02ld", (long)year]; // start of new service year.
    serviceMonth[9] = [NSString stringWithFormat:@"10-%02ld", (long)year];
    serviceMonth[10] = [NSString stringWithFormat:@"11-%02ld", (long)year];
    serviceMonth[11] = [NSString stringWithFormat:@"12-%02ld", (long)year];
    serviceMonth[12] = [NSString stringWithFormat:@"08-%02ld", (long)year]; // last service year month to add.
    
    for (int i = 0; i < monthDisplayCount; i++) {
        
        NSInteger calcMonth = 0;
        NSInteger calcYear = [components year];
        
        calcMonth = 1+i;

        if (i >= 7 && i < 13) {
        } else {
            calcYear = year+1;
        }
        
        //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //dateFormatter.dateFormat = @"MM-yyyy";
        //NSString *less = [NSString stringWithFormat:@"dat-%02ld-%ld",(long)calcMonth, (long)calcYear];
        
        NSString *myKey = [NSString stringWithFormat:@"dat-%@",serviceMonth[i]];
        
        NSMutableArray *monthlyReports = [[_saveData objectForKey:myKey] mutableCopy];
        
        //get monthly hour report
        [monthlyReports enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull reportObject, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSNumber *saveVersion = [reportObject objectForKey:@"saveData_version"];
            if ([reportObject objectForKey:@"data-hours"]) { //publications
                // running this method will automatically convert old time format into new time format
                int hoursToAdd = 0;
                // check data
                if (saveVersion) {
                    hoursToAdd = [[reportObject objectForKey:@"data-hours"] intValue];
                } else {
                    hoursToAdd = [self convertNumberToNewTimeFormat:[reportObject objectForKey:@"data-hours"]];
                }
                totalHours += hoursToAdd;
                NSLog(@"month %@ hoursToAdd %d", myKey, hoursToAdd);
            }
        }];
    }
    
    NSLog(@"Total Service Year Hours %ld",(long)totalHours);
    
    NSString *currentServiceYear = [NSString stringWithFormat:@"%ld~%ld", year, year+1];
    NSString *currentTotalHours = [NSString stringWithFormat:@"%ld",totalHours];
    
    return @[currentServiceYear, currentTotalHours];
}











- (void)updateRecord:(NSMutableDictionary *)updatedRecord AtIndex:(NSInteger)index forMonth:(NSDate *)month {
    
    NSString *myKey = [self getKeyedDataMonthYear:month];
    [self registerMonthYearKey:myKey]; //register
    
    // always SORT before editing, to avoid editing wrong entry
    NSMutableArray *monthlyReportsFromKey = [[_saveData objectForKey:myKey] mutableCopy];
    [monthlyReportsFromKey sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSInteger day1 = [[self getDayDate:(NSDate *)[obj1 objectForKey:@"data-refDates"]] integerValue];
        NSInteger day2 = [[self getDayDate:(NSDate *)[obj2 objectForKey:@"data-refDates"]] integerValue];
        if (day1 > day2) {
            return (NSComparisonResult)NSOrderedAscending;
        } if (day1 < day2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    //update after sorting
    [monthlyReportsFromKey replaceObjectAtIndex:index withObject:updatedRecord];
    
    // override local storage
    [_saveData setObject:monthlyReportsFromKey forKey:myKey];
    [_saveData synchronize];
    
    // synchronize with iCloud data as well
    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    [cloudStore setObject:monthlyReportsFromKey forKey:myKey];
    [cloudStore synchronize];
    
    NSLog(@"updateObject %@ : atIndex %ld monthKey:%@", monthlyReportsFromKey, (long)index, myKey);
}

- (void)removeRecordAtIndex:(NSInteger)index forMonth:(NSDate *)month {
    
    // get from local storage
    NSString *myKey = [self getKeyedDataMonthYear:month];
    [self registerMonthYearKey:myKey]; //register
    
    // sort
    NSMutableArray *monthlyReportsFromKey = [[_saveData objectForKey:myKey] mutableCopy];
    [monthlyReportsFromKey sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        NSInteger day1 = [[self getDayDate:(NSDate *)[obj1 objectForKey:@"data-refDates"]] integerValue];
        NSInteger day2 = [[self getDayDate:(NSDate *)[obj2 objectForKey:@"data-refDates"]] integerValue];
        
        if (day1 > day2) {
            return (NSComparisonResult)NSOrderedAscending;
        } if (day1 < day2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
        
    }];
    
    //remove after ordering
    [monthlyReportsFromKey removeObjectAtIndex:index];
    
    // update on local storage
    [_saveData setObject:monthlyReportsFromKey forKey:myKey];
    [_saveData synchronize];
    
    // post it on icloud storage queue for changes
    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    [cloudStore setObject:monthlyReportsFromKey forKey:myKey];
    [cloudStore synchronize];
    
    NSLog(@"removingFromObject %@ : atIndex %ld monthKey:%@", monthlyReportsFromKey, index, myKey);
}

- (NSDictionary *)monthlyBasedCalculatedReport:(NSDate *)date {
    
    NSLog(@"monthlyBased CalculatedReport");
    //
    NSString *myKey = [self getKeyedDataMonthYear:date];
    NSMutableArray *monthlyReports = [[_saveData objectForKey:myKey] mutableCopy];
    //create dictionary for entire monthly reports
    NSMutableDictionary *theReport = [NSMutableDictionary new];
    //
    [theReport setObject:date forKey:@"dat-MonthDat"];
    [monthlyReports enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull reportObject, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSNumber *saveVersion = [reportObject objectForKey:@"saveData_version"];
        
        if ([reportObject objectForKey:@"data-pubs"]) { //publications
            NSInteger addPubs = [[reportObject objectForKey:@"data-pubs"] integerValue];
            NSInteger totPubs = 0;
            if ([theReport objectForKey:@"tot-pubs"]) {
                totPubs = [[theReport objectForKey:@"tot-pubs"] integerValue];
            }
            totPubs += addPubs;
            [theReport setObject:[NSNumber numberWithInteger:totPubs] forKey:@"tot-pubs"];
        }
        if ([reportObject objectForKey:@"data-vids"]) { //publications
            NSInteger addPubs = [[reportObject objectForKey:@"data-vids"] integerValue];
            NSInteger totPubs = 0;
            if ([theReport objectForKey:@"tot-vids"]) {
                totPubs = [[theReport objectForKey:@"tot-vids"] integerValue];
            }
            totPubs += addPubs;
            [theReport setObject:[NSNumber numberWithInteger:totPubs] forKey:@"tot-vids"];
        }
        
        //
        //
        if ([reportObject objectForKey:@"data-hours"]) { //publications
            //
            // running this method will automatically convert old time format into new time format
            //
            int addPubs = 0;
            int totHours = 0;
            //
            if ([theReport objectForKey:@"tot-hours"]) {
                //add accumulated total hours
                totHours = [[theReport objectForKey:@"tot-hours"] intValue];
            }
            // check data
            if (saveVersion) {
                //data in new time format (add as a minute)
                addPubs = [[reportObject objectForKey:@"data-hours"] intValue];
            } else {
                //data in old time format (convert and add as a minute).
                addPubs = [self convertNumberToNewTimeFormat:[reportObject objectForKey:@"data-hours"]];
            }
            //
            totHours += addPubs;
            [theReport setObject:[NSNumber numberWithInt:totHours] forKey:@"tot-hours"];
            //
        }
        //
        //
        
        
        if ([reportObject objectForKey:@"data-rvs"]) { //publications
            NSInteger addPubs = [[reportObject objectForKey:@"data-rvs"] integerValue];
            NSInteger totPubs = 0;
            if ([theReport objectForKey:@"tot-rvs"]) {
                totPubs = [[theReport objectForKey:@"tot-rvs"] integerValue];
            }
            totPubs += addPubs;
            [theReport setObject:[NSNumber numberWithInteger:totPubs] forKey:@"tot-rvs"];
        }
        if ([reportObject objectForKey:@"data-bss"]) { //publications
            NSInteger addPubs = [[reportObject objectForKey:@"data-bss"] integerValue];
            NSInteger totPubs = 0;
            if ([theReport objectForKey:@"tot-bss"]) {
                totPubs = [[theReport objectForKey:@"tot-bss"] integerValue];
            }
            totPubs += addPubs;
            [theReport setObject:[NSNumber numberWithInteger:totPubs] forKey:@"tot-bss"];
        }
    }];
    
    //calm check if monthlyReports is empty. display "add new records"
    if (monthlyReports.count > 0) {
        return theReport;
    }
    return nil;
}

- (int)convertNumberToNewTimeFormat:(NSNumber *)inputDat {
    
    // ALL old data have either: 1.00/1.25/0.30 style data. New data is always higher than 60, and never have decimals.
    NSTimeInterval extractedTime = [inputDat floatValue]; //1.25
    int hour = (int)extractedTime; //1.00
    float decimal = extractedTime - hour;
    int minutes = 0; //either .25 .50 .75 variant only
    int finalVal = 0;
    
    if (decimal > 0) {
        //for time with decimal places format.
        minutes = decimal*60; //convert minutes
        hour = hour*60; //convert full hours
        finalVal = minutes+hour; //calculate by adding converted values
    } else {
        //for time without decimal places, oldest hour based time.
        hour = hour*60; //convert full hours
        finalVal = minutes+hour; //calculate by adding converted values
        //hour will be converted into raw minutes.
    }
    
    //returns int value in minute period.
    return [[self timeFormatted:finalVal*60] intValue];
}

- (BOOL)addRecordWithTest:(NSDictionary *)reportDataToAdd {
    /*
     this method, automatically assigns the report data to the designated Month/Year.
     */
    // get its reportData's "DATE"
    NSDate *reportDatDate = [reportDataToAdd objectForKey:@"data-refDates"];
    NSString *myKey = [self getKeyedDataMonthYear:reportDatDate];
    [self registerMonthYearKey:myKey]; //register
    
    NSMutableArray *monthlyReportsFromKey = [[_saveData objectForKey:myKey] mutableCopy];
    if (!monthlyReportsFromKey) {
        monthlyReportsFromKey = [NSMutableArray new];
    }
    
    [monthlyReportsFromKey addObject:reportDataToAdd];
    
    // save it over to local storage
    [_saveData setObject:monthlyReportsFromKey forKey:myKey];
    [_saveData synchronize];
    
    // save it over to cloud
    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    [cloudStore setObject:monthlyReportsFromKey forKey:myKey];
    [cloudStore synchronize];
    
    NSLog(@"savingRecord %@ : myKey %@ :existingDat %@ and iCloud", reportDataToAdd, myKey, monthlyReportsFromKey);
    
    return YES;
}


// this is to get data straight from iCloud
- (void)setReportDataEntriesToDate:(NSDate *)inputDate {
    
    //instantiate datas, this key can also become a ubiquitous key
    NSString *currentMYKey = [self getKeyedDataMonthYear:inputDate];
    __block NSMutableArray *fieldServiceRecordsByMonth;
    
    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //try to load data stored in user's iCloud
        fieldServiceRecordsByMonth = [[cloudStore objectForKey:currentMYKey] mutableCopy];
        NSLog(@"trying to claim fsRecord from iCloud with date %@ myKey %@", inputDate, currentMYKey);

        if (fieldServiceRecordsByMonth && fieldServiceRecordsByMonth.count > 0) {
            // data loaded from iCloud.
            _reportDataEntries = fieldServiceRecordsByMonth;
            
            // if loaded, must replace the ones currently in the local storage
            [_saveData setObject:_reportDataEntries forKey:currentMYKey];
            [_saveData synchronize];
            
        } else {
            // data loaded from local storage.
            _reportDataEntries = [[_saveData objectForKey:currentMYKey] mutableCopy];
        }
        
        [self sortDataEntries:_reportDataEntries];
        
    });
}


- (void)setReportDataEntriesToDate:(NSDate *)inputDate withCompletion:(void (^)(BOOL success))completion {
    
    //instantiate datas, this key can also become a ubiquitous key
    NSString *currentMYKey = [self getKeyedDataMonthYear:inputDate];
    __block NSMutableArray *fieldServiceRecordsByMonth;
    
    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //try to load data stored in user's iCloud
        fieldServiceRecordsByMonth = [[cloudStore objectForKey:currentMYKey] mutableCopy];
        NSLog(@"trying to claim fsRecord from iCloud with date %@ myKey %@", inputDate, currentMYKey);
        
        if (fieldServiceRecordsByMonth && fieldServiceRecordsByMonth.count > 0) {
            // data loaded from iCloud.
            _reportDataEntries = fieldServiceRecordsByMonth;
            
            // if loaded, must replace the ones currently in the local storage
            [_saveData setObject:_reportDataEntries forKey:currentMYKey];
            [_saveData synchronize];
            
        } else {
            // data loaded from local storage.
            _reportDataEntries = [[_saveData objectForKey:currentMYKey] mutableCopy];
        }
        
        [self sortDataEntries:_reportDataEntries];
        
        // when reaching here
        self.completeLoading = completion;
        self.completeLoading(YES); // call block
    });
}









- (void)updateMonthlyReports:(NSDate *)inputDate fromCloud:(BOOL)use {
    
    //instantiate datas, this key can also become a ubiquitous key
    NSString *currentMYKey = [self getKeyedDataMonthYear:inputDate];
    __block NSMutableArray *fieldServiceRecordsByMonth;
    
    if (use == YES) {
        // update from iCloud
        NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
        fieldServiceRecordsByMonth = [[cloudStore objectForKey:currentMYKey] mutableCopy];
        _reportDataEntries = fieldServiceRecordsByMonth;
        
        // apply data to local storage
        [_saveData setObject:_reportDataEntries forKey:currentMYKey];
        [_saveData synchronize];
        
    } else {
        // from local storage
        _reportDataEntries = [[_saveData objectForKey:currentMYKey] mutableCopy];
    }
    
    [self sortDataEntries:_reportDataEntries];
    
}

- (void)sortDataEntries:(NSMutableArray *)mutableArray {
    [_reportDataEntries sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSInteger day1 = [[self getDayDate:(NSDate *)[obj1 objectForKey:@"data-refDates"]] integerValue];
        NSInteger day2 = [[self getDayDate:(NSDate *)[obj2 objectForKey:@"data-refDates"]] integerValue];
        if (day1 > day2) {
            return (NSComparisonResult)NSOrderedAscending;
        } if (day1 < day2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
}

- (NSMutableArray *)getReportDataFromCloudWithDate:(NSDate *)inputDate {
    // always try to get data from cloud, this will save to local storage
    NSString *currentMYKey = [self getKeyedDataMonthYear:inputDate];
    NSMutableArray *fieldServiceRecordsByMonth;
    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    fieldServiceRecordsByMonth = [[cloudStore objectForKey:currentMYKey] mutableCopy];
    
    if (!fieldServiceRecordsByMonth) {
        return nil;
    }
    if (fieldServiceRecordsByMonth.count < 1) {
        return nil;
    }
    
    //save it to local storage
    [_saveData setObject:fieldServiceRecordsByMonth forKey:currentMYKey];
    [_saveData synchronize];
    
    // register to current reportDataEntry after sorting
    [fieldServiceRecordsByMonth sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSInteger day1 = [[self getDayDate:(NSDate *)[obj1 objectForKey:@"data-refDates"]] integerValue];
        NSInteger day2 = [[self getDayDate:(NSDate *)[obj2 objectForKey:@"data-refDates"]] integerValue];
        if (day1 > day2) {
            return (NSComparisonResult)NSOrderedAscending;
        } if (day1 < day2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    _reportDataEntries = fieldServiceRecordsByMonth;
    return fieldServiceRecordsByMonth;
    
}


- (NSInteger)dayToday {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd"];
    NSString *dateInStr = [dateFormat stringFromDate:[NSDate date]];
    [dateInStr stringByReplacingOccurrencesOfString:@"0" withString:@""];
    //convert
    return [dateInStr integerValue];
}

- (NSString *)getDayDate:(NSDate *)returnedDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd"];
    return [dateFormat stringFromDate:returnedDate];
}

- (NSString *)getMonthYear:(NSDate *)returnedDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-yyyy"];
    NSString *formattedDate = [dateFormat stringFromDate:returnedDate];
    // 06-26-1993
    return formattedDate;
}

- (NSDate *)getLastMonthYear {
    
    NSDate *currentMonthDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [NSDateComponents new];
    comps.month = -1;
    
    NSDate *date = [calendar dateByAddingComponents:comps toDate:currentMonthDate options:0];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date]; // Get necessary date components
    NSInteger newMonth = [components month];
    NSInteger newYear = [components year];
    NSString *formattedStringDate = [NSString stringWithFormat:@"%ld-%ld", (long)newMonth, (long)newYear];
    if (newMonth < 10) {
        formattedStringDate = [NSString stringWithFormat:@"0%@", formattedStringDate];
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-yyyy"];
    
    NSDate *formattedNSDate = [dateFormat dateFromString:formattedStringDate];
    
    NSLog(@"formatted Date %@ -> <NSDate> %@", formattedStringDate, formattedNSDate);
    
    // 06-26-1993
    return [dateFormat dateFromString:formattedStringDate];
}

- (NSString *)getKeyedDataMonthYear:(NSDate *)inputDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-yyyy"];
    NSString *formattedDate = [dateFormat stringFromDate:inputDate];
    // 06-1993
    return [NSString stringWithFormat:@"dat-%@",formattedDate];
}

- (NSString *)convertMonthYear:(NSDate *)inputDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-yyyy"];
    NSString *formattedDate = [dateFormat stringFromDate:inputDate];
    NSLog(@"convertMonthYear from %@ to %@", inputDate, formattedDate);
    return formattedDate;
}

- (NSString *)getCountableMonthYear:(NSDate *)inputDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-yyyy"];
    NSString *formattedDate = [NSString stringWithFormat:@"dat-%@",[dateFormat stringFromDate:inputDate]];
    NSLog(@"countableYear from %@ to %@", inputDate, formattedDate);
    return formattedDate;
}

- (NSString *)getMonth:(NSDate *)inputDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM.yyyy"];
    NSString *formattedDate = [dateFormat stringFromDate:inputDate];
    return formattedDate;
}

- (NSString *)getDay:(NSDate *)returnedDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd"];
    NSString *formattedDate = [dateFormat stringFromDate:returnedDate];
    // 06-26-1993
    return formattedDate;
}

- (NSString *)getDateInWordsFrom:(NSString *)inputFormattedDate {
    NSArray *cmd = [inputFormattedDate componentsSeparatedByString:@"-"];
    NSString *monthDisp = [self localizeWithText:cmd[0]];
    return [NSString stringWithFormat:@"%@ %@", monthDisp, cmd[1]];
}
//
// Date management
- (void)getServiceYear {
    //
    
    
}

- (NSString *)timeFormatted:(int)unformattedTime {
    // input unformattedTime is in minutes.
    // convert to seconds first!
    
    int totalSeconds = unformattedTime*60;
    
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d",hours, minutes];
}


//
// MY Key Data Management by Months
- (void)registerMonthYearKey:(NSString *)inputMMYYKey {
    
    NSMutableArray *mmYyKeys;
    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    
    //try to claim from iCloud first before creating one
    if ([cloudStore objectForKey:@"monthYear"]) {
        // monthYear key is an NSMutableArray
        mmYyKeys = [[cloudStore objectForKey:@"monthYear"] mutableCopy]; // data claimed from iCloud
    }
    if ([_saveData objectForKey:@"monthYear"] && !mmYyKeys) {
        mmYyKeys = [[_saveData objectForKey:@"monthYear"] mutableCopy];
    } else {
        mmYyKeys = [NSMutableArray new];
    }
    
    if ([mmYyKeys containsObject:inputMMYYKey] == NO) {
        // this will always update to icloud regardless
        [mmYyKeys addObject:inputMMYYKey];
        [_saveData setObject:mmYyKeys forKey:@"monthYear"];
        [_saveData synchronize];
        [cloudStore setObject:mmYyKeys forKey:@"monthYear"];
        [cloudStore synchronize];
        NSLog(@"myKey Successfully registered myKey %@ in mmYYKeys %@", inputMMYYKey, mmYyKeys);
    } else {
        NSLog(@"myKey:%@ already exists in %@", inputMMYYKey, mmYyKeys);
    }
    
}

- (void)updateMonthYearKeyToCloud {
    // when finding, adding, always update latest data from the iCloud
    
    
}

// IMPORTANT DO NOT TOUCH 


/* Updating universal bg image */
- (UIImage *)readBgImage {
    NSString *imagePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"bgImage"];
    if (imagePath) {
        return [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
    }
    return nil;
}

- (void)updateBGImageToFile:(UIImage *)image withIdentifier:(NSString *)inputIdentifier {
    
    // convert image to nsdata
    NSData *imageData = UIImageJPEGRepresentation(image, 0.0);
    
    [_saveData setObject:imageData forKey:@"bgImageData"];
    [_saveData synchronize];
    
    NSLog(@"saved image to userDefaults");
     
    // update to current image identifier
    [_saveData setObject:inputIdentifier forKey:@"bgImage-identifier"];
    [_saveData synchronize];

}

- (NSString *)documentsPathForFileName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
}

// !@abstract checkForImageUpdate finds background image that needs update. Updates daily
- (void)checkForImageUpdate {
    NSUserDefaults *save = [NSUserDefaults standardUserDefaults];
    
    NSString *imageIdentifier = [NSString stringWithFormat:@"m%ld",(long)[self dayToday]];
    _mIdentifier = imageIdentifier;
    // imageIdentifier m1 m2 m3 m4
    
    //check if today's imageFileName is equal to
    NSLog(@"checkForImageUpdate -> currentImageIdentitier %@ || saveDat %@", imageIdentifier, [save objectForKey:@"bgImage-identifier"]);
    
    //display mDisp to overviewScene
    
    if ([[save objectForKey:@"bgImage-identifier"] isEqualToString:imageIdentifier]) {
        NSLog(@"checkForImageUpdate -> image is up to date");
    } else {
        NSLog(@"checkForImageUpdate -> update required. updating image begin with inputIdentifier %@", imageIdentifier);
        [self executeImageUpdateForImageName:imageIdentifier];
    }
    
}

- (void)executeImageUpdateForImageName:(NSString *)inputIdentifier {
    
    //check network connection first!
    NSString *urlString = [[_constDat objectForKey:@"bgImageURL"] objectForKey:inputIdentifier]; //inputFileName:m1
    NSLog(@"updating image with url %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    
    //string retrieved. now load image async
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            NSLog(@"before atStart of task sequence imageUpdate -> %@", image.description);
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // image claimed successfully from the internet. update image
                    [self updateBGImageToFile:image withIdentifier:inputIdentifier];
                    NSLog(@"after async imageUpdate -> %@ tabbarcontroller's child %@", image.description,self.tabBarController.selectedViewController);
                    
                    //call method -> execute update
                    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(bgImageDidUpdate)]) {
                        [[[UIApplication sharedApplication] delegate] performSelector:@selector(bgImageDidUpdate)];
                    }
                    
                });
            }
        }
    }];
    [task resume];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)plist:(NSString *)fileName {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    return path;
}


- (void)startCloudStorageFromThisDevice {
    
    
}

// RECEIVE
- (void)tryToUpdateEntireRecordFromCloudStorage {
    
    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    
    // 1, get all monthYear
    NSMutableArray *cloudMMyyKey = [[cloudStore objectForKey:@"monthYear"] mutableCopy];
    
    if (cloudMMyyKey) {
        
        
        
    } else {
        // if this entry is empty, do not attempt to update data in the local storage.
    }
    
    // try to update personal contacts/RVs
}

@end
