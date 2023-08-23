//
//  OverviewScene.m
//  MyMinistry
//
//  Created by Koji Murata on 08/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "OverviewScene.h"
#import "DispCell.h"
#import "ParentTabView.h"
#import "AppDelegate.h"
#import "SubmitScene.h"

@interface OverviewScene ()

@property UIVisualEffectView *vfx;
@property NSMutableArray *goalDat;
@property BOOL isRunningInFullScreen;
@property (strong, nonatomic) IBOutlet UIImageView *bgImg;
@property float lastYPos;
@property (strong, nonatomic) IBOutlet UIView *topVFXBar;

@end

@implementation OverviewScene

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //accomodate only when user is touching the view
    
    if (scrollView.contentOffset.y-scrollView.contentInset.top <= 0) {
        [self hideToolbar:NO];
        [UIView animateWithDuration:0.2f animations:^{
            [self.topVFXBar setAlpha:0.0];
        }];
    } else {
        if (scrollView.contentOffset.y > _lastYPos) {
            //go down
            [self hideToolbar:YES];
            [UIView animateWithDuration:0.2f animations:^{
                [self.topVFXBar setAlpha:1.0];
            }];
        }
        _lastYPos = scrollView.contentOffset.y;
    }
}

- (void)hideToolbar:(BOOL)hide {
    [UIView animateWithDuration:0.2f animations:^{
        if (hide == YES) {
            [self.tabBarController.tabBar setAlpha:0.0];
            //[self.tabBarController.tabBar setTransform:CGAffineTransformMakeTranslation(0, self.tabBarController.tabBar.frame.size.height)];
        } else {
            [self.tabBarController.tabBar setAlpha:1.0];
            //[self.tabBarController.tabBar setTransform:CGAffineTransformMakeTranslation(0, 0)];
        }
    }];
}

- (void)hideNavbar:(BOOL)hide {
    
    CGRect navRect = self.navigationController.navigationBar.frame;
    float statBarRect = [UIApplication sharedApplication].statusBarFrame.size.height;
        
    [UIView animateWithDuration:0.15f animations:^{
        if (hide == YES) {
            [self.navigationController.navigationBar setFrame:CGRectMake(0, statBarRect-navRect.size.height, navRect.size.width, navRect.size.height)];
            [self.navigationController.navigationBar.topItem setHidesBackButton:YES];
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor clearColor]}];
        } else {
            [self.navigationController.navigationBar setFrame:CGRectMake(0, statBarRect, navRect.size.width, navRect.size.height)];
            [self.navigationController.navigationBar.topItem setHidesBackButton:NO];
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        }
    }];
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier containsString:@"setMonthlyGoal"]) {
        [self hideNavbar:NO];
        [self hideToolbar:NO];
        [segue.destinationViewController.navigationController setModalPresentationStyle:UIModalPresentationOverFullScreen];
    }
}

// ------

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    //check
    if ([(DispCell *)cell vfxView]) {
        [[(DispCell *)cell vfxView] setAlpha:0.5];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    //check
    if ([(DispCell *)cell vfxView]) {
        [[(DispCell *)cell vfxView] setAlpha:1.0];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // check button type
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if ([cell.reuseIdentifier containsString:@"addNewCell"]) {
        //move to tab 2
        [_parent setSelectedIndex:1];
    }
    if ([(DispCell *)cell vfxView]) {
        [[(DispCell *)cell vfxView] setAlpha:1.0];
    }
    //check if bar with special functinos has been tapped
    if ([cell.reuseIdentifier containsString:@"buttonCell"]) {
        DispCell *buttonCell = (DispCell*)cell;
        if ([buttonCell.customFunc containsString:@"$"]) {
            if ([buttonCell.customFunc containsString:@"devContact"]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:muratapp@gmail.com"] options:@{} completionHandler:^(BOOL success) {
                    
                }];
            }
            if ([buttonCell.customFunc containsString:@"visitWeb"]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://appkoji.com/"] options:@{} completionHandler:^(BOOL success) {
                    
                }];
            }
        }
    }
    
    //check if notification has been tapped. if tapped, remove them from the view
    if ([cell.reuseIdentifier containsString:@"notification"]) {
        [collectionView performBatchUpdates:^ {
            [_goalDat removeObjectAtIndex:indexPath.row];
            [collectionView deleteItemsAtIndexPaths:@[indexPath]];
            [self.parent setCurrentNotificationValue:[self.parent currentNotificationValue]-1];
            
            // after deleting, display report submission scene! //[self.mainParent monthlyBasedCalculatedReport:self.currentSelectedMonth];
            NSUserDefaults *save = [NSUserDefaults standardUserDefaults];
            [save setObject:[self getMonthYear:[NSDate date]] forKey:@"Notification-monthlyReport"];
            [save synchronize];
            
            [self hideNavbar:NO];
            [self hideToolbar:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSDate *lastMonthYear = [self.parent getLastMonthYear];
                NSDictionary *dat = [self.parent monthlyBasedCalculatedReport:lastMonthYear]; //last month
                SubmitScene *ss = [self.storyboard instantiateViewControllerWithIdentifier:@"SubmitScene"];
                [ss setInputData:dat];
                [ss setReportingMonth:[self.parent getDateInWordsFrom:[self.parent convertMonthYear:lastMonthYear]]];
                [self.navigationController pushViewController:ss animated:YES];
            });
        } completion:nil];
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    //config collectionView inset
    CGFloat deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (deviceVersion < 11.0) {
        [collectionView setContentInset:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height+20.00, 0, 0, 0)];
    }
    
    return _goalDat.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    //extract data
    NSArray *cmd = [[_goalDat objectAtIndex:indexPath.row] componentsSeparatedByString:@"/"];
    NSString *cellID = cmd[1];
    
    //Register class registerClass:forCellWithReuseIdentifier
    //[collectionView registerClass:[DispCell class] forCellWithReuseIdentifier:cellID];
    
    
    if ([cellID isEqualToString:@"lblCell"]) {
        DispCell *theCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        [theCell.nameDisplay setText:[self localizeWithText:cmd[0]]];
        return theCell;
    } else if ([cellID isEqualToString:@"monthCell"]) {
        DispCell *theCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        [theCell.nameDisplay setText:[self.parent getMonth:[NSDate date]]];
        return theCell;
    } else {
        //cell that displays constant data
        DispCell *theCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        if (theCell.completedCheck) {
            [theCell.completedCheck setHidden:YES];
        }
        if ([cellID isEqualToString:@"notificationCell"]) {
            [theCell.valueDisplay setText:[self localizeWithText:cmd[0]]];
        }
        if (theCell.progressBar) {
            [theCell.progressBar setHidden:YES];
            [theCell.progressBar.layer setMasksToBounds:YES];
        }
        
        if ([cellID isEqualToString:@"copyrightCell"]) {
        } else {
            [theCell.nameDisplay setText:[self localizeWithText:cmd.firstObject]];
        }
        
        
        if (theCell.goalValueDisplay) {
            [theCell.goalValueDisplay setText:@""];
        }

        if (theCell.nameDisplay.tag == 0) {
            [theCell setTag:1];
            [theCell maskLabel];
        }
        
        //add appropriate icon [3]
        if (theCell.iconDisplay) {
            [theCell.iconDisplay setImage:[UIImage imageNamed:cmd[3]]];
        }
        
        //display special datas here
        if (cmd.count > 2) {
            if ([cmd[2] hasPrefix:@"$dat"]) {
                if ([cmd[2] containsString:@"daysLeft"]) {
                    //days left until end of month
                    NSInteger monthDays = [NSCalendar.currentCalendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate date]].length;
                    NSInteger daysLeft = monthDays - [_parent dayToday];
                    [theCell.valueDisplay setText:[NSString stringWithFormat:@"%ld",daysLeft]];
                    
                }
            }
        }
        
        //display corresponding data right here!
        if ([cmd.firstObject containsString:@"pubs"]) {
            
            if ([[_parent currentMonthData] objectForKey:@"tot-pubs"]) {
                [theCell.valueDisplay setText:[NSString stringWithFormat:@"%@",[[_parent currentMonthData] objectForKey:@"tot-pubs"]]];
            } else {
                [theCell.valueDisplay setText:[NSString stringWithFormat:@"0"]];
            }
            
            // goal display
            if (_goalPubs) {
                [theCell.completedCheck setHidden:NO];
                [theCell.goalValueDisplay setText:[NSString stringWithFormat:@"%@",_goalPubs]];
            } else {
                [theCell.completedCheck setHidden:YES];
            }
            
            [theCell displayCompletedCheckWithProgress:[[[_parent currentMonthData] objectForKey:@"tot-pubs"] intValue] total:[_goalPubs intValue]];
            
        }
        
        if ([cmd.firstObject containsString:@"vids"]) {
            
            if ([[_parent currentMonthData] objectForKey:@"tot-vids"]) {
                [theCell.valueDisplay setText:[NSString stringWithFormat:@"%@",[[_parent currentMonthData] objectForKey:@"tot-vids"]]];
            } else {
                [theCell.valueDisplay setText:[NSString stringWithFormat:@"0"]];
            }
            
            if (_goalVids) {
                [theCell.completedCheck setHidden:NO];
                [theCell.goalValueDisplay setText:[NSString stringWithFormat:@"%@",_goalVids]];
            } else {
                [theCell.completedCheck setHidden:YES];
            }
            
            [theCell displayCompletedCheckWithProgress:[[[_parent currentMonthData] objectForKey:@"tot-vids"] intValue] total:[_goalVids intValue]];
            
        }
        
        // Time must distinguish between service year time/monthly time
        if ([cmd.firstObject containsString:@"time"]) {
            NSString *totHours = [[_parent currentMonthData] objectForKey:@"tot-hours"];
            
            if (totHours) {
                float uT = [totHours floatValue];
                [theCell.valueDisplay setText:[NSString stringWithFormat:@"%@",[_parent timeFormatted:uT]]];
            } else {
                [theCell.valueDisplay setText:[NSString stringWithFormat:@"00:00"]];
            }

            [theCell.completedCheck setHidden:YES];

            if (_goalHours) {
                [theCell.goalValueDisplay setText:[NSString stringWithFormat:@"%@:00",_goalHours]];
            }
            
            //HERE DISPLAY THE DA CIRCULAR VIEW
            if (theCell.timeProgressView) {
                [theCell.timeProgressView setHidden:NO];
                
                //setup
                [theCell.timeProgressView setRoundedCorners:0.0];
                [theCell.timeProgressView setThicknessRatio:0.1];
                [theCell.timeProgressView setProgressTintColor:theCell.timeProgressView.tintColor];
                [theCell.timeProgressView setTrackTintColor:theCell.timeProgressView.backgroundColor];
                //data
                float tot = [totHours floatValue];
                float goal = [_goalHours floatValue]*60;
                float calcProg = tot/goal;
                
                if ([_goalHours intValue] < 1) {
                    [theCell.timeProgressView setProgress:1.0f];
                } else {
                    // try to show progress
                    [theCell.timeProgressView setProgress:calcProg];
                }
                // total time
                NSLog(@"totalTime %f/%f progress %f",tot,goal,calcProg);
            }
        }
        
        if ([cmd.firstObject containsString:@"timesy"]) {
            
            NSArray *serviceYearData = [_parent serviceYearData];
            NSString *totHours = serviceYearData.lastObject;
            
            [theCell.nameDisplay setText:serviceYearData.firstObject];
            
            if (totHours) {
                float uT = [totHours floatValue];
                NSString *timeFormatted = [[_parent timeFormatted:uT] componentsSeparatedByString:@":"].firstObject;
                [theCell.valueDisplay setText:timeFormatted];
            } else {
                [theCell.valueDisplay setText:[NSString stringWithFormat:@"0"]];
            }
            
            if (_goalHours) {
                [theCell.completedCheck setHidden:NO]; // times 12.
                int gh = [_goalHours intValue] * 12;
                [theCell.goalValueDisplay setText:[NSString stringWithFormat:@"%d",gh]];
            } else {
                [theCell.completedCheck setHidden:YES];
            }
            //HERE DISPLAY THE DA CIRCULAR VIEW
            float tot = [totHours floatValue];
            float goal = ([_goalHours floatValue]*60)*12;
            [theCell.progressBar setHidden:NO];
            [theCell.progressBar setProgress:tot/goal];
        }
        
        if ([cmd.firstObject containsString:@"rvs"]) {
            
            if ([[_parent currentMonthData] objectForKey:@"tot-rvs"]) {
                [theCell.valueDisplay setText:[NSString stringWithFormat:@"%@",[[_parent currentMonthData] objectForKey:@"tot-rvs"]]];
            } else {
                [theCell.valueDisplay setText:[NSString stringWithFormat:@"0"]];
            }
            
            if (_goalRvs) {
                [theCell.completedCheck setHidden:NO];
                [theCell.goalValueDisplay setText:[NSString stringWithFormat:@"%@",_goalRvs]];
            } else {
                [theCell.completedCheck setHidden:YES];
            }
            [theCell displayCompletedCheckWithProgress:[[[_parent currentMonthData] objectForKey:@"tot-rvs"] intValue] total:[_goalRvs intValue]];

        }
        
        if ([cmd.firstObject containsString:@"bss"]) {
            if ([[_parent currentMonthData] objectForKey:@"tot-bss"]) {
                [theCell.valueDisplay setText:[NSString stringWithFormat:@"%@",[[_parent currentMonthData] objectForKey:@"tot-bss"]]];
            } else {
                [theCell.valueDisplay setText:[NSString stringWithFormat:@"0"]];
            }
        }
        
        
        //[theCell.layer setMasksToBounds:YES];
        
        //for buttons that has vfxView
        if ([cellID isEqualToString:@"setGoalCell"]) {
            [theCell.vfxView.layer setMasksToBounds:YES];
            [theCell.vfxView.layer setCornerRadius:25];
        } if ([cellID isEqualToString:@"annualProgCell"]) {
            [theCell.vfxView.layer setMasksToBounds:YES];
            [theCell.vfxView.layer setCornerRadius:35];
        }
        
        // for buttons that gives specific tasks, assign special functions
        if ([cellID isEqualToString:@"buttonCell"]) {
            [theCell setCustomFunc:[cmd objectAtIndex:2]];
        }
        
        return theCell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *cmd = [[_goalDat objectAtIndex:indexPath.row] componentsSeparatedByString:@"/"];
    NSString *cellID = cmd[1];
    
    float size = 90;
    float width = _menuDisplays.frame.size.width-20; //for iPhone
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (_isRunningInFullScreen == NO) {
            width = _menuDisplays.frame.size.width-30; //for iPad
        } else {
            width = _menuDisplays.frame.size.width-200; //for iPad
        }
    }
    if ([cellID containsString:@"month"]) {
        size = 100;// for iPhone
    }
    if ([cellID containsString:@"lbl"]) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            size = 50;// for iPhone
        } else {
            size = 30;// for iPhone
        }
    }
    if ([cellID containsString:@"breakCell"]) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            if (_isRunningInFullScreen == NO) {
                size = 40;// for iPad
            } else {
                size = 70;// for iPad
            }
        } else {
            size = 40;// for iPhone
        }
    }
    if ([cellID containsString:@"time"]) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            if (_isRunningInFullScreen == NO) {
                size = 300;// for iPad standard full screen
            } else {
                size = 450;// for iPad split view, small screen
            }
        } else {
            size = 300;// for iPhone
        }
    }
    if ([cellID containsString:@"annualProgCell"]) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            if (_isRunningInFullScreen == NO) {
                size = 110;// for iPad standard full screen
            } else {
                size = 110;// for iPad split view, small screen
            }
        } else {
            size = 110;// for iPhone
        }
    }
    if ([cellID containsString:@"notification"]) {
        size = 50;// for iPhone
    }
    
    
    return CGSizeMake(width, size);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    CGRect frame = [UIApplication sharedApplication].delegate.window.frame;
    _isRunningInFullScreen = CGRectEqualToRect(CGRectMake(frame.origin.x, frame.origin.y, size.width, size.height), [UIApplication sharedApplication].delegate.window.screen.bounds);
    [_menuDisplays reloadData];
    [self hideNavbar:NO];
    [self hideToolbar:NO];
}

- (void)cloudDataDidUpdated:(NSNotification *)notification {
    // check
    NSLog(@"iCloud data was updated in the server side");
    [_parent updateMonthlyReports:[NSDate date] fromCloud:YES];
    [_parent setRecordsForCurrentMonth];
    [self.menuDisplays reloadData];
    //
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    //track parent
    _parent = self.parentViewController;
    
    [_parent setRecordsForCurrentMonth];
    _goalDat = [[[_parent constDat] objectForKey:@"mainMenuDisp"] mutableCopy];
    
    //detect if data is empty. display "add new" cell instead
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.viewWithBg addObject:self];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudDataDidUpdated:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    _isRunningInFullScreen = CGRectEqualToRect(CGRectMake([UIApplication sharedApplication].delegate.window.frame.origin.x, [UIApplication sharedApplication].delegate.window.frame.origin.y, [UIApplication sharedApplication].delegate.window.frame.size.width, [UIApplication sharedApplication].delegate.window.frame.size.height), [UIApplication sharedApplication].delegate.window.screen.bounds);
    [self dataDisplayUpdate];
    //try to update mdisp
    [_mDisplay setText:[_parent mIdentifier]];
    [self checkMonthlyReportNotification];
    
    [self hideNavbar:YES];
    
}

- (void)updateTabLang {
    [self.parent updateTabDisplayLanguage];
}

- (void)updateNavigationTitle:(NSString *)str {
    [self.navigationItem setTitle:[self localizeWithText:str]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self readBgImage];
}

- (void)checkMonthlyReportNotification {
    // Check if new month, hasn't registered send notification
    NSUserDefaults *save = [NSUserDefaults standardUserDefaults];
    NSString *thisMonth = [self getMonthYear:[NSDate date]];
    BOOL isNewReport = NO;
    if ([save objectForKey:@"Notification-monthlyReport"]) {
        if (![[save objectForKey:@"Notification-monthlyReport"] isEqualToString:thisMonth]) {
            isNewReport = YES;
            // notified monthly report. now reset to this month after displaying push notification.
            [save setObject:thisMonth forKey:@"Notification-monthlyReport"];
            [save synchronize];
        }
    } else {
        //since empty, no monthly reports available yet. Just add entry
        [save setObject:thisMonth forKey:@"Notification-monthlyReport"];
        [save synchronize];
    }
    if (isNewReport == YES) {
        [self addNotification:@"newReport"];
    }
}

- (void)addNotification:(NSString *)notificationIdentifier {
    [_goalDat insertObject:[NSString stringWithFormat:@"%@/notificationCell", notificationIdentifier] atIndex:0];
    [self.parent setCurrentNotificationValue:[self.parent currentNotificationValue]+1];
    
    //
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate displayNotification];
}

- (void)readBgImage {
    
    //check if app delegate has latest image
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (appDelegate.commonBGImages) {
        self.bgImg.image = appDelegate.commonBGImages;
    } else {
        self.bgImg.image = [UIImage imageNamed:@"mibg-01"];
    }
    
}

- (void)executeBackgroundUpdate:(UIImage *)updatedImage {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.bgImg duration:1.2f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.bgImg setImage:updatedImage];
        } completion:nil];
    });
}

- (void)checkForUpdates {
    NSURL *url = [NSURL URLWithString:@"https://kojigames.wordpress.com/updates"];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // updates returned here
                
            });
        }
    }];
    [task resume];
    //[_goalDat insertObject:@"non/notificationCell" atIndex:0];
}

//------
- (NSString *)localizeWithText:(NSString *)inputIdentifier {
    return NSLocalizedString(inputIdentifier, nil);
}

- (void)dataDisplayUpdate {
    
    //update record
    [_parent setRecordsForCurrentMonth];
    
    _goalDat = [[[_parent constDat] objectForKey:@"mainMenuDisp"] mutableCopy];
    
    //detect if data is empty. display "add new" cell instead
    if (![_parent currentMonthData]) {
        //_goalDat = [[[_parent constDat] objectForKey:@"mainMenuDispEmpty"] mutableCopy];
    }
    
    //check for push notification, or available updates
    [self checkForUpdates];
    
    //try to fetch user-goals
    //_goalDats
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    
    if ([saveData objectForKey:@"goal-hrs"]) {
        if (![(NSNumber *)[saveData objectForKey:@"goal-hrs"] isEqual:@0]) {
            _goalHours = [[saveData objectForKey:@"goal-hrs"] stringValue];
        } else {
            _goalHours = nil;
        }
    } else {
        _goalHours = nil;
    }
    //
    if ([saveData objectForKey:@"goal-pubs"]) {
        if (![(NSNumber *)[saveData objectForKey:@"goal-pubs"] isEqual:@0]) {
            _goalPubs = [[saveData objectForKey:@"goal-pubs"] stringValue];
        } else {
            _goalPubs = nil;
        }
    } else {
        _goalPubs = nil;
    }
    //
    if ([saveData objectForKey:@"goal-vids"]) {
        if (![(NSNumber *)[saveData objectForKey:@"goal-vids"] isEqual:@0]) {
            _goalVids = [[saveData objectForKey:@"goal-vids"] stringValue];
        } else {
            _goalVids = nil;
        }
    } else {
        _goalVids = nil;
    }
    //
    if ([saveData objectForKey:@"goal-rvs"]) {
        if (![(NSNumber *)[saveData objectForKey:@"goal-rvs"] isEqual:@0]) {
            _goalRvs = [[saveData objectForKey:@"goal-rvs"] stringValue];
        } else {
            _goalRvs = nil;
        }
    } else {
        _goalRvs = nil;
    }
    
    [_menuDisplays reloadData];
}

- (NSString *)getMonthYear:(NSDate *)returnedDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-YYYY"];
    return [dateFormat stringFromDate:returnedDate]; // 06-1993
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

@end
