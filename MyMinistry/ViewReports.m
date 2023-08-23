//
//  ViewReports.m
//  MyMinistry
//
//  Created by Koji Murata on 08/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "ViewReports.h"
#import "ParentTabView.h"
#import "RecordDispCell.h"
#import "SubmitScene.h"
#import "AppDelegate.h"

@interface ViewReports ()

@property NSInteger selectedIndex;
@property NSDate *currentSelectedMonth;
@property (strong, nonatomic) IBOutlet UIImageView *bgImg;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitBtn;
@property BOOL isRunningInFullScreen;
@end

@implementation ViewReports

//return reports made in some particular month.
- (void)monthYearDidPicked:(NSDate *)pickedDate {
    
    self.currentSelectedMonth = pickedDate;
    [self updateNavigationTitle:[self.mainParent getDateInWordsFrom:[self.mainParent convertMonthYear:pickedDate]]];
    
    _currentCollectionView.alpha = 0.5f;
    
    [_mainParent setReportDataEntriesToDate:pickedDate withCompletion:^(BOOL success) {
        
        _currentCollectionView.alpha = 1.0f;
        
        //recheck for updated reportdata entrees
        if ([_mainParent reportDataEntries].count > 0) {
            [_submitBtn setEnabled:YES];
        } else {
            [_submitBtn setEnabled:NO];
        }
        
        // bad timing, as icloud data may not be updated to local device
        [_currentCollectionView reloadData];
        
    }];

}

- (void)updateNavigationTitle:(NSString *)str {
    [self.navigationItem setTitle:str];
}

- (void)didEditReport:(NSMutableDictionary *)updatedReport {
    
    // must synchronize with iCloud
    [_mainParent updateRecord:updatedReport AtIndex:self.selectedIndex forMonth:self.currentSelectedMonth];
    
    [_mainParent setReportDataEntriesToDate:self.currentSelectedMonth];
    [self.currentCollectionView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    EditReports *er = [segue destinationViewController];
    if (!er.parent) {
        er.delegate = self;
        er.parent = self;
        er.navBar = self.navigationController.navigationBar;
        er.mainParent = self.mainParent;
        // register its parent to access VC that has raw-data
        er.editableDatas = [[[_mainParent reportDataEntries] objectAtIndex:_selectedIndex] mutableCopy];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectedIndex = indexPath.row;
    NSLog(@"SELECTED INDEX %ld", (long)_selectedIndex);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_mainParent reportDataEntries].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSDictionary *dataEntry = [[_mainParent reportDataEntries] objectAtIndex:indexPath.row];
    
    //extract data
    RecordDispCell *theCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"recordDisp" forIndexPath:indexPath];
    
    //savedata version
    NSNumber *savedatVersion = [dataEntry objectForKey:@"saveData_version"];
    
    //graphic modify
    if (theCell.tag == 5) {
        [theCell setTag:0];
        [theCell.layer setMasksToBounds:YES];
        [theCell.layer setCornerRadius:20.0f];
        if (savedatVersion) {
            [theCell.layer setBorderColor:[UIColor whiteColor].CGColor];
            [theCell.layer setBorderWidth:0.75f];
        } else {
            [theCell.layer setBorderColor:[UIColor redColor].CGColor];
            [theCell.layer setBorderWidth:1.5f];
        }
    }
    
    [theCell.lbl_pubs setText:[self convertNumberToString:[dataEntry objectForKey:@"data-pubs"]]];
    [theCell.lbl_vids setText:[self convertNumberToString:[dataEntry objectForKey:@"data-vids"]]];
    
    if (savedatVersion) {// ignores data conversion command
        [theCell.lbl_time setText:[self convertNumberToTimeNew:[dataEntry objectForKey:@"data-hours"]]];
    } else {
        //old data version
        [theCell.lbl_time setText:[self convertNumberToNewTimeFormat:[dataEntry objectForKey:@"data-hours"]]];
    }
    
    [theCell.lbl_rvs setText:[self convertNumberToString:[dataEntry objectForKey:@"data-rvs"]]];
    [theCell.lbl_bss setText:[self convertNumberToString:[dataEntry objectForKey:@"data-bss"]]];
    [theCell.lbl_dayDateDisp setText:[self getDayDate:[dataEntry objectForKey:@"data-refDates"]]];
    [theCell.lbl_refNotes setText:(NSString *)[dataEntry objectForKey:@"data-refNotes"]];
    
    return theCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float cellSize = 100;
    float width = collectionView.frame.size.width-30; //for iPhone
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (_isRunningInFullScreen == NO) {
            width = collectionView.frame.size.width-30;
        } else {
            width = collectionView.frame.size.width-200; //for iPad
        }
    }
    return CGSizeMake(width, cellSize);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    CGRect frame = [UIApplication sharedApplication].delegate.window.frame;
    _isRunningInFullScreen = CGRectEqualToRect(CGRectMake(frame.origin.x, frame.origin.y, size.width, size.height), [UIApplication sharedApplication].delegate.window.screen.bounds);
    [_currentCollectionView reloadData];
}

- (NSString *)convertNumberToString:(NSNumber *)inputDat {
    return [NSString stringWithFormat:@"%@", inputDat];
}

- (NSString *)convertNumberToNewTimeFormat:(NSNumber *)inputDat {
    
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
    
    return [NSString stringWithFormat:@"(%@)", [self timeFormatted:finalVal*60]];
}

// Time is already in the newest version
- (NSString *)convertNumberToTimeNew:(NSNumber *)inputDat {
    NSLog(@"new time %@", inputDat);
    
    int totalMinutes = [inputDat intValue];// minutes
    int totalSeconds = totalMinutes*60;
    
    return [self timeFormatted:totalSeconds];
}

- (NSString *)timeFormatted:(int)totalSeconds {
    
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d",hours, minutes];
}

- (NSString *)getDayDate:(NSDate *)returnedDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd"];
    NSString *dayDate = [dateFormat stringFromDate:returnedDate];
    if ([dayDate hasPrefix:@"0"]) {
        dayDate = [[dateFormat stringFromDate:returnedDate] stringByReplacingOccurrencesOfString:@"0" withString:@""];
    }
    return dayDate;
}

- (void)updateRecordsData {
    
}


- (void)removeReport {
    [_mainParent removeRecordAtIndex:_selectedIndex forMonth:self.currentSelectedMonth];
    // based on old report
}

- (void)cloudDataDidUpdated:(NSNotification *)notification {
    // check
    NSLog(@"iCloud data was updated in the server side");
    [_mainParent updateMonthlyReports:self.currentSelectedMonth fromCloud:YES];
    [self.currentCollectionView reloadData];
    //
}

- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    [super viewDidLoad];

    self.mainParent = self.parentViewController.parentViewController;
    NSLog(@"current parent %@", self.mainParent);
    self.currentSelectedMonth = [NSDate date];
    // use update months data (don't read from iCloud)
    [_mainParent setReportDataEntriesToDate:self.currentSelectedMonth];
    
    // icloud changes notiication
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudDataDidUpdated:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear");
    [super viewWillAppear:YES];
    
    _isRunningInFullScreen = CGRectEqualToRect(CGRectMake([UIApplication sharedApplication].delegate.window.frame.origin.x, [UIApplication sharedApplication].delegate.window.frame.origin.y, [UIApplication sharedApplication].delegate.window.frame.size.width, [UIApplication sharedApplication].delegate.window.frame.size.height), [UIApplication sharedApplication].delegate.window.screen.bounds);
    
    // update from local storage
    [_mainParent updateMonthlyReports:self.currentSelectedMonth fromCloud:NO];
    
    [self updateNavigationTitle:[self.mainParent getDateInWordsFrom:[self.mainParent convertMonthYear:self.currentSelectedMonth]]];
    [self readBgImage];
    
    //check if
    if ([_mainParent reportDataEntries].count > 0) {
        [_submitBtn setEnabled:YES];
    } else {
        [_submitBtn setEnabled:NO];
    }
    
    
    [self.currentCollectionView reloadData];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectMonthYear:(id)sender {
    
    NSArray *viewableMonths = [self.mainParent availableMonths];
    NSLog(@"selectMonthYear -> %@", viewableMonths);
    
    MonthYearPicker *myp = [self.storyboard instantiateViewControllerWithIdentifier:@"MonthYearPicker"];
    myp.delegate = self;
    [myp setMonthDat:viewableMonths];
    
    [self presentViewController:myp animated:YES completion:nil];
}

- (IBAction)openOptions:(id)sender {
    //test total data
    NSDictionary *dat = [self.mainParent monthlyBasedCalculatedReport:self.currentSelectedMonth];
    
    SubmitScene *ss = [self.storyboard instantiateViewControllerWithIdentifier:@"SubmitScene"];
    [ss setInputData:dat];
    [ss setReportingMonth:[self.mainParent getDateInWordsFrom:[self.mainParent convertMonthYear:self.currentSelectedMonth]]];
    [self.navigationController pushViewController:ss animated:YES];
    
}

@end
