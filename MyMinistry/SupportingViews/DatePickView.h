//
//  DatePickView.h
//  MyMinistry
//
//  Created by Koji Murata on 09/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePickView : UIViewController

@property (weak, nonatomic) id parent;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (strong, nonatomic) NSDate *currentDate;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end
