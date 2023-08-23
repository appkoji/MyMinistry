//
//  AddReport.m
//  MyMinistry
//
//  Created by Koji Murata on 08/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "AddReport.h"
#import "InputValCell.h"
#import "ParentTabView.h"
#import "DatePickView.h"
#import "HelpDisplayView.h"
#import "AppDelegate.h"

@interface AddReport ()

@property NSArray *inputDat;
@property (strong, nonatomic) IBOutlet UIImageView *bgImg;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property BOOL isRunningInFullScreen;
@end

@implementation AddReport

- (void)mmAlertviewDidRespond:(BOOL)response :(id)alertview {
    if (response == YES) {
        [alertview dismissViewControllerAnimated:NO completion:^{
            [self saveReportData];
        }];
    } else {
        [alertview dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)saveFunc:(id)sender {
    
    [self saveReportData];

}

- (void)displayHelp:(NSString *)helpID {
    NSLog(@"SmartBar Help");
    HelpDisplayView *hdv = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpDisplayView"];
    [hdv setInputDat:helpID];
    
    [self.tabBarController presentViewController:hdv animated:YES completion:^{
    }];
}

- (void)saveReportData {
    
    [_recordingElements setTag:1]; //ready to reset
    //saving by just adding data to current entry
    NSMutableDictionary *reportData = [NSMutableDictionary dictionary];
    [reportData setObject:[NSNumber numberWithInteger:_pubs] forKey:@"data-pubs"];
    [reportData setObject:[NSNumber numberWithInteger:_vids] forKey:@"data-vids"];
    [reportData setObject:[NSNumber numberWithInteger:_hours] forKey:@"data-hours"];
    [reportData setObject:[NSNumber numberWithInteger:_rvs] forKey:@"data-rvs"];
    [reportData setObject:[NSNumber numberWithInteger:_bss] forKey:@"data-bss"];
    [reportData setObject:@2.0 forKey:@"saveData_version"];
    
    NSLog(@"saving data %@", reportData);
    
    if (_refNotes) {
        [reportData setObject:_refNotes forKey:@"data-refNotes"];
    }
    
    [reportData setObject:_currentDate forKey:@"data-refDates"];
    //add this report data into data entry mutableArray
    [_parent addRecordWithTest:reportData];
    //
    [_recordingElements reloadData];
    //change to myRecords Scene
    [_parent setSelectedIndex:3];
}

- (NSString *)getDateFrom:(NSString *)inputFormattedDate {
    NSArray *cmd = [inputFormattedDate componentsSeparatedByString:@"-"];
    NSString *monthDisp = [self localizeWithText:cmd[0]];
    NSLog(@"DATE ASKED %@ - %@", monthDisp, cmd[0]);
    int dayInt = [cmd[1] intValue];
    return [NSString stringWithFormat:@"%@ %@, %@", monthDisp, [NSString stringWithFormat:@"%d", dayInt], cmd[2]];
}

- (NSString *)setMonthDate:(NSDate *)returnedDate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-YYYY"];
    NSString *formattedDate = [dateFormat stringFromDate:returnedDate];
    _currentDate = returnedDate;
    NSString *dateString = [self getDateFrom:formattedDate];
    [_recordingElements.visibleCells enumerateObjectsUsingBlock:^(__kindof InputValCell * _Nonnull theCell, NSUInteger idx, BOOL * _Nonnull stop) {
        if (theCell.currentDateDisp) {
            [theCell.currentDateDisp setText:dateString];
        }
    }];
    return dateString;
}

- (IBAction)closeKeyboard:(id)sender {
    [_recordingElements.visibleCells enumerateObjectsUsingBlock:^(__kindof InputValCell * _Nonnull theCell, NSUInteger idx, BOOL * _Nonnull stop) {
        if (theCell.inputTextField) {
            [theCell endEditing:YES];
        }
    }];
}

- (void)didReturnTapFunctionFor:(NSString *)actionId {
    if ([actionId isEqualToString:@"datePicker"]) {

        DatePickView *datePicker = [self.storyboard instantiateViewControllerWithIdentifier:@"CalendarDatePicker"];
        datePicker.parent = self;
        [datePicker setCurrentDate:_currentDate];
        [self.navigationController pushViewController:datePicker animated:YES];
        
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //config collectionView inset
    CGFloat deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSLog(@"device version %f", deviceVersion);
    if (deviceVersion < 11.0) {
        [collectionView setContentInset:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height+20, 0, 50, 0)];
    }
    return _inputDat.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    //extract data
    NSArray *cmd = [[_inputDat objectAtIndex:indexPath.row] componentsSeparatedByString:@"/"];
    NSString *cellID = cmd[1];
    
    //cell that displays constant data
    InputValCell *theCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    if (!theCell.parent) {
        theCell.parent = self;
    }
    
    if (collectionView.tag == 1) {
        //reset
        [theCell resetData];
    }
    
    if ([cellID containsString:@"date"]) {
        [theCell setUserInteractionEnabled:NO];
        [theCell setMultipleTouchEnabled:NO];
        [theCell setExclusiveTouch:YES];
    }
    
    if (theCell.dataTypeIcon) {
        if (cmd.count > 3) {
            [theCell.dataTypeIcon setImage:[UIImage imageNamed:cmd[3]]];
        }
    }
    
    [theCell initializeCellObject];
    
    if (theCell.inputTextField) {
        [theCell.inputTextField setText:[self localizeWithText:cmd[0]]];
    }
    
    if (theCell.datatypeDisplay) {
        [theCell setDataTypeIdentifier:cmd[0]];
        
        //add text as corresponding user lang
        [theCell.datatypeDisplay setText:[self localizeWithText:cmd[0]]];
        
        if (theCell.layer.borderWidth <= 0.1 && ![cmd[1] isEqualToString:@"questionCell"]) {
            [theCell.layer setMasksToBounds:YES];
            [theCell.layer setCornerRadius:35.0f];
            [theCell.layer setBorderColor:[UIColor whiteColor].CGColor];
            [theCell.layer setBorderWidth:0.5f];
        }
        
    } else {
        if (theCell.layer.borderWidth <= 0.1) {
            [theCell.layer setMasksToBounds:YES];
            [theCell.layer setCornerRadius:15.0f];
        }
    }
    
    if (theCell.currentDateDisp) {
        NSString *dateStr = [self setMonthDate:_currentDate]; //default date <today>
        [theCell.currentDateDisp setText:dateStr];
        NSLog(@"currentDateDisp %@", _currentDate);
    }
    return theCell;
}


- (void)resetAddRecords {
    //reset all symbols
    [_recordingElements reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_recordingElements.visibleCells enumerateObjectsUsingBlock:^(__kindof InputValCell * _Nonnull theCell, NSUInteger idx, BOOL * _Nonnull stop) {
        if (theCell.activeIndicator.alpha > 0.5) {
            [UIView animateWithDuration:0.5 animations:^{
                [theCell.activeIndicator setAlpha:0.0];
            }];
        }
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *cmd = [[_inputDat objectAtIndex:indexPath.row] componentsSeparatedByString:@"/"];
    float cellSize = [cmd[2] floatValue];
    float width = _recordingElements.frame.size.width-30; //for iPhone
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (_isRunningInFullScreen == NO) {
            width = _recordingElements.frame.size.width-30;
        } else {
            width = _recordingElements.frame.size.width-200; //for iPad
        }
    }
    return CGSizeMake(width, cellSize);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    CGRect frame = [UIApplication sharedApplication].delegate.window.frame;
    _isRunningInFullScreen = CGRectEqualToRect(CGRectMake(frame.origin.x, frame.origin.y, size.width, size.height), [UIApplication sharedApplication].delegate.window.screen.bounds);
    [_recordingElements reloadData];
}




- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (_isRunningInFullScreen == NO) {
            return 20.0f;
        } else {
            return 20.0f;
        }
    }
    return 20.0f;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    
    [self updateNavigationTitle:@"add"];
    [self.saveBtn setTitle:[self localizeWithText:@"save"]];
    
    [self.recordingElements reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self readBgImage];
    _isRunningInFullScreen = CGRectEqualToRect(CGRectMake([UIApplication sharedApplication].delegate.window.frame.origin.x, [UIApplication sharedApplication].delegate.window.frame.origin.y, [UIApplication sharedApplication].delegate.window.frame.size.width, [UIApplication sharedApplication].delegate.window.frame.size.height), [UIApplication sharedApplication].delegate.window.screen.bounds);
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


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //track parent
    _parent = self.parentViewController.parentViewController;
    _inputDat = [[_parent constDat] objectForKey:@"inputDatVal"];
    
    _currentDate = [NSDate date]; //today
    
}

- (void)updateNavigationTitle:(NSString *)str {
    [self.navigationItem setTitle:[self localizeWithText:str]];
}

- (NSString *)localizeWithText:(NSString *)inputIdentifier {
    /*
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"localizedDisplayTexts" ofType:@"plist"]];
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    NSString *userLang = @"EN"; // EN defauls language
    if ([saveData objectForKey:@"userSetting-lang"]) {
        userLang = [saveData objectForKey:@"userSetting-lang"];
    }
    return [[dic objectForKey:inputIdentifier] objectForKey:userLang];
     */
    return NSLocalizedString(inputIdentifier, nil);

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
