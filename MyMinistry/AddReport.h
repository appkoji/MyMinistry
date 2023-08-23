//
//  AddReport.h
//  MyMinistry
//
//  Created by Koji Murata on 08/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMAlertView.h"

@interface AddReport : UIViewController  <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, MMAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *recordingElements;
@property (weak, nonatomic) id parent;
- (IBAction)saveFunc:(id)sender;

//update live data status
@property int pubs;
@property int vids;
@property int hours;
@property int rvs;
@property int bss;
@property (strong, nonatomic) NSString *refNotes;
@property (strong, nonatomic) NSDate *currentDate;


- (void)displayHelp:(NSString *)helpID;
- (void)didReturnTapFunctionFor:(NSString *)actionId;
- (NSString *)setMonthDate:(NSDate *)returnedDate;
- (IBAction)closeKeyboard:(id)sender;

@end
