//
//  GoalSettingScene.m
//  MyMinistry
//
//  Created by Koji Murata on 27/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "GoalSettingScene.h"
#import "AppDelegate.h"
#import "OverviewScene.h"
#import "ArraySelectionView.h"

@interface GoalSettingScene ()
@property (strong, nonatomic) IBOutlet UIImageView *bgImg;
@property BOOL isRunningInFullScreen;
@end

@implementation GoalSettingScene


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"populatingData.coun %ld", _populatingData.count);
    return _populatingData.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSLog(@"did select at index path %ld", indexPath.row);
}

- (void)cellDidTap:(InputValCell *)theCell {
    NSLog(@"returned celldidTap");
    
    if ([theCell.action isEqualToString:@"langDisplay"]) {
        //display list
        ArraySelectionView *asv = [self.storyboard instantiateViewControllerWithIdentifier:@"ArraySelectionView"];
        asv.parentView = self;
        asv.inputData = [[self appLogic] objectForKey:@"language"];
        asv.savingObjectKey = @"userSetting-lang";
        asv.preselectedObject = [[NSUserDefaults standardUserDefaults] objectForKey:asv.savingObjectKey];
        [self presentViewController:asv animated:YES completion:^{
        }];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
        
    NSArray *cmd = [[_populatingData objectAtIndex:indexPath.row] componentsSeparatedByString:@"/"];
    
    NSString *cellID = cmd[0];
    
    InputValCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.parent = self;
    
    if (cell.datatypeDisplay) {
        [cell.datatypeDisplay setText:[cell localizeWithText:cmd[1]]];
    }
    
    //input default values
    if ([cmd[1] isEqualToString:@"goal-hrs"]) {
        [cell setDataTypeIdentifier:cmd[1]];
        [cell.currentValue setText:[NSString stringWithFormat:@"%d", _goalTime]];
        [cell setOutputValue:(int)_goalTime];
    }
    if ([cmd[1] isEqualToString:@"goal-pubs"]) {
        [cell setDataTypeIdentifier:cmd[1]];
        [cell.currentValue setText:[NSString stringWithFormat:@"%d", _goalPubs]];
        [cell setOutputValue:(int)_goalPubs];
    }
    if ([cmd[1] isEqualToString:@"goal-vids"]) {
        [cell setDataTypeIdentifier:cmd[1]];
        [cell.currentValue setText:[NSString stringWithFormat:@"%d", _goalVids]];
        [cell setOutputValue:(int)_goalVids];
    }
    if ([cmd[1] isEqualToString:@"goal-rvs"]) {
        [cell setDataTypeIdentifier:cmd[1]];
        [cell.currentValue setText:[NSString stringWithFormat:@"%d", _goalRvs]];
        [cell setOutputValue:(int)_goalRvs];
    }
    
    if (cell.dataTypeIcon) {
        [cell.dataTypeIcon setImage:[UIImage imageNamed:cmd[2]]];
    }
    if (cell.activeIndicator) {
        [cell.layer setCornerRadius:35.0f];
        [cell.layer setMasksToBounds:YES];
        [cell.layer setBorderColor:[UIColor whiteColor].CGColor];
        [cell.layer setBorderWidth:0.5f];
    }
    if ([cellID containsString:@"valueSetting"]) {
        [cell.vfxView.layer setCornerRadius:25.0f];
        [cell.vfxView.layer setMasksToBounds:YES];
    }
    
    //language setting button, add action
    if ([cmd[1] isEqualToString:@"langDisplay"]) {
        [cell setAction:@"langDisplay"];
    }
    
    //startup multicollectinview
    if (cell.multiCollectionview) {
        [cell startupCollectionView:@[@"Regular\nPioneer",@"Auxiliary\nPioneer",@"Custom"]];
    }
    
    //NSLog(@"creating collectionViewCell -> %@ forData %@", cell, cmd);
    
    return cell;
}

- (void)settingToValue:(int)newVal forData:(NSString *)dataType {
    NSLog(@"settingToValue %d forKey %@", newVal, dataType);
    
    // save to local storage
    [_save setObject:[NSNumber numberWithInt:newVal] forKey:dataType];
    [_save synchronize];
    
}

- (void)saveToValue:(NSString *)newVal forData:(NSString *)dataType {
    NSLog(@"settingToValue %@ forKey %@", newVal, dataType);
    
    // save to local storage
    [_save setObject:newVal forKey:dataType];
    [_save synchronize];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *cmd = [[_populatingData objectAtIndex:indexPath.row] componentsSeparatedByString:@"/"];
    float width = collectionView.frame.size.width-30;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (_isRunningInFullScreen == NO) {
            width = collectionView.frame.size.width-30;
        } else {
            width = collectionView.frame.size.width-300;
        }
    }
    
    return CGSizeMake(width, [cmd[3] floatValue]);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    CGRect frame = [UIApplication sharedApplication].delegate.window.frame;
    _isRunningInFullScreen = CGRectEqualToRect(CGRectMake(frame.origin.x, frame.origin.y, size.width, size.height), [UIApplication sharedApplication].delegate.window.screen.bounds);
    [_collectionView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _populatingData = [NSMutableArray new];
    _save = [NSUserDefaults standardUserDefaults];
    
    // display user defaults
    if ([_save objectForKey:@"goal-hrs"]) {
        _goalTime = [[_save objectForKey:@"goal-hrs"] intValue];
    } else {
        _goalTime = -0;
    }
    if ([_save objectForKey:@"goal-pubs"]) {
        _goalPubs = [[_save objectForKey:@"goal-pubs"] intValue];
    } else {
        _goalPubs = -0;
    }
    if ([_save objectForKey:@"goal-vids"]) {
        _goalVids = [[_save objectForKey:@"goal-vids"] intValue];
    } else {
        _goalVids = -0;
    }
    if ([_save objectForKey:@"goal-rvs"]) {
        _goalRvs = [[_save objectForKey:@"goal-rvs"] intValue];
    } else {
        _goalRvs = -0;
    }
    
    // populate data cellIdentifier.title.
    //[_populatingData addObject:@"breakCell/non/non/5"];
    [_populatingData addObject:@"breakCell/non/non/5"];
    [_populatingData addObject:@"lblCell/goal-smg/non/30"];
    [_populatingData addObject:@"editableCell/goal-hrs/time/70"];
    [_populatingData addObject:@"editableCell/goal-pubs/pubs/70"];
    [_populatingData addObject:@"editableCell/goal-vids/vids/70"];
    [_populatingData addObject:@"editableCell/goal-rvs/contacts/70"];
    [_populatingData addObject:@"breakCell/non/non/5"];

    //valueSettingCell

    NSLog(@"check GoalSettingScene %@", _populatingData);
    [_collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    _isRunningInFullScreen = CGRectEqualToRect(CGRectMake([UIApplication sharedApplication].delegate.window.frame.origin.x, [UIApplication sharedApplication].delegate.window.frame.origin.y, [UIApplication sharedApplication].delegate.window.frame.size.width, [UIApplication sharedApplication].delegate.window.frame.size.height), [UIApplication sharedApplication].delegate.window.screen.bounds);
    [self readBgImage];
    
}

- (void)viewDidAppear:(BOOL)animated {
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

- (NSDictionary *)appLogic {
    return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"appLogic" ofType:@"plist"]];
}

@end
