//
//  ViewReports.h
//  MyMinistry
//
//  Created by Koji Murata on 08/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonthYearPicker.h"
#import "EditReports.h"

@interface ViewReports : UIViewController  <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MYPickerDelegate, EditReportsDelegate>

- (IBAction)selectMonthYear:(id)sender;

- (IBAction)openOptions:(id)sender;

@property (strong, nonatomic) IBOutlet UICollectionView *currentCollectionView;
@property (weak, nonatomic) id mainParent;


- (void)removeReport;

@end
