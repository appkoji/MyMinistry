//
//  EditReports.m
//  MyMinistry
//
//  Created by Koji Murata on 11/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "EditReports.h"
#import "InputValCell.h"
#import "ViewReports.h"
#import "ParentTabView.h"
#import "AppDelegate.h"
#import "DatePickView.h"

@interface EditReports ()
@property (strong, nonatomic) IBOutlet UIImageView *bgImg;
@property (strong, nonatomic) NSArray *inputDats;
@property BOOL isRunningInFullScreen;
@end

//
@implementation EditReports

float lastPos;

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    if ([self isMovingFromParentViewController]) {
        NSLog(@"pop");
        
    } else {
        NSLog(@"push");
    }
    
}

// meddling date
- (void)didReturnTapFunctionFor:(NSString *)actionId {
    if ([actionId isEqualToString:@"datePicker"]) {
        DatePickView *datePicker = [self.storyboard instantiateViewControllerWithIdentifier:@"CalendarDatePicker"];
        datePicker.parent = self;
        [datePicker setCurrentDate:[_editableDatas objectForKey:@"data-refDates"]];
        [self.navigationController pushViewController:datePicker animated:YES];
    }
}
// return edited date
- (void)sedtMonthDate:(NSDate *)date {
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //accomodate only when user is touching the view
    if (scrollView.contentOffset.y > lastPos) {
        //go down
        [self hideToolbar:YES];
        [self hideNavbar:YES];
    } else {
        [self hideToolbar:NO];
        [self hideNavbar:NO];
    }
    lastPos = scrollView.contentOffset.y;
}

- (NSString *)getDateFrom:(NSString *)inputFormattedDate {
    NSArray *cmd = [inputFormattedDate componentsSeparatedByString:@"-"];
    NSString *monthDisp = [self localizeWithText:cmd[0]];
    NSLog(@"DATE ASKED %@ - %@", monthDisp, cmd[0]);
    return [NSString stringWithFormat:@"%@ %@, %@", monthDisp, cmd[1], cmd[2]];
}

- (NSString *)setMonthDate:(NSDate *)returnedDate {
    
    // set new date
    [_editableDatas setObject:returnedDate forKey:@"data-refDates"];
    //
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-YYYY"];
    NSString *formattedDate = [dateFormat stringFromDate:returnedDate];
    //
    NSString *dateString = [self getDateFrom:formattedDate];
    [_displayCollections.visibleCells enumerateObjectsUsingBlock:^(__kindof InputValCell * _Nonnull theCell, NSUInteger idx, BOOL * _Nonnull stop) {
        if (theCell.currentDateDisp) {
            [theCell.currentDateDisp setText:dateString];
        }
    }];
    return dateString;
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _inputDats.count;
}

- (void)setUpdatedData:(NSNumber *)nData forKey:(NSString *)key {
    [_editableDatas setObject:nData forKey:key];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSArray *cmd = [[_inputDats objectAtIndex:indexPath.row] componentsSeparatedByString:@"/"];
    NSString *cellID = cmd[1];

    //cell that displays constant data
    InputValCell *theCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    theCell.parent = self;
    [theCell initializeCellObject];
    
    //add corresponding datas for
    if (theCell.currentDateDisp) {
        [theCell.currentDateDisp setText:[self setMonthDate:[_editableDatas objectForKey:@"data-refDates"]]];
    }
    if (theCell.inputTextField) {
        [theCell.inputTextField setText:[_editableDatas objectForKey:@"data-refNotes"]];
    }
    if ([cellID containsString:@"editableCell"]) {
        if ([cmd[0] containsString:@"pubs"]) {
            [theCell setDataTypeIdentifier:@"data-pubs"];
            [theCell setOutputValue:[[_editableDatas objectForKey:@"data-pubs"] floatValue]];
            [theCell updateValue];
        } if ([cmd[0] containsString:@"vids"]) {
            [theCell setDataTypeIdentifier:@"data-vids"];
            [theCell setOutputValue:[[_editableDatas objectForKey:@"data-vids"] floatValue]];
            [theCell updateValue];
        } if ([cmd[0] containsString:@"time"]) {
            [theCell setDataTypeIdentifier:@"data-hours"];
            
            //input editableData
            float inputHours = [[_editableDatas objectForKey:@"data-hours"] floatValue];
            //pre detect old time format hh:mm to s
            /*
             some old time formats are recorded in hours, without any minutes time stamp
             eg. 1.00000 instead of 1.30000, which is hard to detect from standard detector.
             1.00000 will translate as 1 minute which is hardly possible in any case.
             
             most cases, single figure numbers must be translated as hour.
             1 -> 3600
             */
            
            if (inputHours < 24) {
                int totalMinutes = [[_editableDatas objectForKey:@"data-hours"] intValue];
                float decimal = inputHours-totalMinutes; //gives decimal places
                NSLog(@"InputHours %f <%@> decimals %f", inputHours, [_editableDatas objectForKey:@"data-hours"], decimal);
                if (decimal > 0) {
                    // has decimals, further decipher at later process
                } else {
                    // has no decimals, most probably an hour figure:
                    if (inputHours < 24) {
                        inputHours = inputHours*60;
                    }
                }
            }
            
            
            [theCell setOutputValue:inputHours];
            [theCell updateValue];
        } if ([cmd[0] containsString:@"rvs"]) {
            [theCell setDataTypeIdentifier:@"data-rvs"];
            [theCell setOutputValue:[[_editableDatas objectForKey:@"data-rvs"] floatValue]];
            [theCell updateValue];
        } if ([cmd[0] containsString:@"bss"]) {
            [theCell setDataTypeIdentifier:@"data-bss"];
            [theCell setOutputValue:[[_editableDatas objectForKey:@"data-bss"] floatValue]];
            [theCell updateValue];
        }
    }
    
    if (theCell.dataTypeIcon) {
        if (cmd.count > 3) {
            [theCell.dataTypeIcon setImage:[UIImage imageNamed:cmd[3]]];
        }
    }
    
    if (theCell.datatypeDisplay) {
        [theCell.datatypeDisplay setText:[self localizeWithText:cmd[0]]];
        [theCell.layer setMasksToBounds:YES];
        [theCell.layer setCornerRadius:35.0f];
        [theCell.layer setBorderColor:[UIColor whiteColor].CGColor];
        [theCell.layer setBorderWidth:0.5f];
    } else {
        [theCell.layer setMasksToBounds:YES];
        [theCell.layer setCornerRadius:10.0f];
    }
    
    return theCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *cmd = [[_inputDats objectAtIndex:indexPath.row] componentsSeparatedByString:@"/"];
    float cellSize = [cmd[2] floatValue];
    float width = collectionView.frame.size.width-30;
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
    [_displayCollections reloadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _inputDats = [[_mainParent constDat] objectForKey:@"datEditVals"];
    
    [_editToolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];
    [_editToolbar setTranslucent:YES];
    [self hideToolbar:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self readBgImage];
    
    //update bar button item titles localize
    [_cancelNavBtn setTitle:[self localizeWithText:@"cancel"]];
    [_doneNavBtn setTitle:[self localizeWithText:@"done"]];
    
    [_displayCollections reloadData];

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

- (void)hideToolbar:(BOOL)hide {
    [UIView animateWithDuration:0.2f animations:^{
        if (hide == YES) {
            [_editToolbar setAlpha:0.0];
            [_editToolbar setTransform:CGAffineTransformMakeTranslation(0, _editToolbar.frame.size.height)];
        } else {
            [_editToolbar setAlpha:1.0];
            [_editToolbar setTransform:CGAffineTransformMakeTranslation(0, 0)];
        }
    }];
}
- (void)hideNavbar:(BOOL)hide {
    
    CGRect navRect = _navBar.frame;
    float statBarRect = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    [UIView animateWithDuration:0.2f animations:^{
        if (hide == YES) {
            [_navBar setFrame:CGRectMake(0, statBarRect-navRect.size.height, navRect.size.width, navRect.size.height)];
            [_navBar.topItem setHidesBackButton:YES];
            [_cancelNavBtn setEnabled:NO];
            [_cancelNavBtn setTintColor: [UIColor clearColor]];
            [_doneNavBtn setEnabled:NO];
            [_doneNavBtn setTintColor: [UIColor clearColor]];
        } else {
            [_navBar setFrame:CGRectMake(0, statBarRect, navRect.size.width, navRect.size.height)];
            [_navBar.topItem setHidesBackButton:NO];
            [_cancelNavBtn setEnabled:YES];
            [_cancelNavBtn setTintColor: [UIColor whiteColor]];
            [_doneNavBtn setEnabled:YES];
            [_doneNavBtn setTintColor: [UIColor whiteColor]];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteAction:(id)sender {
    
    //display alert before deleting
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[self localizeWithText:@"deleteTitle"] message:[self localizeWithText:@"deleteDescription"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:[self localizeWithText:@"delete"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //delete handler
        [self.navigationController popViewControllerAnimated:YES];
        [self.parent removeReport];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[self localizeWithText:@"cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)toolBarActions:(id)sender {
    
    if (sender == _cancelNavBtn) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (sender == _doneNavBtn) {
        //for saving
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:[self localizeWithText:@"updateRecord"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [_editableDatas setObject:@2.0 forKey:@"saveData_version"];
            
            //saving data
            [_delegate didEditReport:_editableDatas];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[self localizeWithText:@"cancel"] style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:deleteAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        //
    }
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSString *)localizeWithText:(NSString *)inputIdentifier {
    return NSLocalizedString(inputIdentifier, nil);
}

@end
