//
//  MonthYearPicker.h
//  MyMinistry
//
//  Created by Koji Murata on 10/03/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MYPickerDelegate
- (void)monthYearDidPicked:(NSDate *)pickedDate;
@end

@interface MonthYearPicker : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (unsafe_unretained) id <MYPickerDelegate> delegate;
@property (strong, nonatomic) NSArray *monthDat;
@property (strong, nonatomic) IBOutlet UITableView *MonthDisplay;

- (IBAction)setMonth:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
