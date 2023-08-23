//
//  MonthYearPicker.m
//  MyMinistry
//
//  Created by Koji Murata on 10/03/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "MonthYearPicker.h"
#import "MonthYearCell.h"

@interface MonthYearPicker ()

@end

@implementation MonthYearPicker

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _monthDat.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *rStr = [_monthDat objectAtIndex:indexPath.row];
    NSString *dataDateString = [rStr stringByReplacingOccurrencesOfString:@"dat-" withString:@""];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-yyyy"];
    NSLog(@"DateFormat -> %@ dataDateString: %@", dateFormat, dataDateString);
    NSDate *fDate = [dateFormat dateFromString:dataDateString];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate monthYearDidPicked:fDate];
    }];
    
    //
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MonthYearCell *myc = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    [myc setAccessibilityValue:[_monthDat objectAtIndex:indexPath.row]];
    [myc.monthview setText:[self getDateFrom:[_monthDat objectAtIndex:indexPath.row]]];
    return myc;
    
}

- (NSString *)getDateFrom:(NSString *)inputFormattedDate {
    
    NSUserDefaults *save = [NSUserDefaults standardUserDefaults];
    NSString *userLang = [save objectForKey:@"userSetting-lang"];
    NSArray *cmd = [inputFormattedDate componentsSeparatedByString:@"-"];
    NSString *monthDisp;
    NSString *dayDisp = cmd[2];
    
    //day setting per language
    if ([userLang isEqualToString:@"JA"]) {
        dayDisp = [NSString stringWithFormat:@"%@日", dayDisp];
    }
    
    if ([cmd[1] isEqualToString:@"01"]) {
        if ([userLang isEqualToString:@"JA"]) {
            monthDisp = @"1月";
        } else {
            monthDisp = @"January";
        }
    } if ([cmd[1] isEqualToString:@"02"]) {
        if ([userLang isEqualToString:@"JA"]) {
            monthDisp = @"2月";
        } else {
            monthDisp = @"February";
        }
    } if ([cmd[1] isEqualToString:@"03"]) {
        if ([userLang isEqualToString:@"JA"]) {
            monthDisp = @"3月";
        } else {
            monthDisp = @"March";
        }
    } if ([cmd[1] isEqualToString:@"04"]) {
        if ([userLang isEqualToString:@"JA"]) {
            monthDisp = @"4月";
        } else {
            monthDisp = @"April";
        }
    } if ([cmd[1] isEqualToString:@"05"]) {
        if ([userLang isEqualToString:@"JA"]) {
            monthDisp = @"5月";
        } else {
            monthDisp = @"May";
        }
    } if ([cmd[1] isEqualToString:@"06"]) {
        if ([userLang isEqualToString:@"JA"]) {
            monthDisp = @"6月";
        } else {
            monthDisp = @"June";
        }
    } if ([cmd[1] isEqualToString:@"07"]) {
        if ([userLang isEqualToString:@"JA"]) {
            monthDisp = @"7月";
        } else {
            monthDisp = @"July";
        }
    } if ([cmd[1] isEqualToString:@"08"]) {
        if ([userLang isEqualToString:@"JA"]) {
            monthDisp = @"8月";
        } else {
            monthDisp = @"August";
        }
    } if ([cmd[1] isEqualToString:@"09"]) {
        if ([userLang isEqualToString:@"JA"]) {
            monthDisp = @"9月";
        } else {
            monthDisp = @"September";
        }
    } if ([cmd[1] isEqualToString:@"10"]) {
        if ([userLang isEqualToString:@"JA"]) {
            monthDisp = @"10月";
        } else {
            monthDisp = @"October";
        }
    } if ([cmd[1] isEqualToString:@"11"]) {
        if ([userLang isEqualToString:@"JA"]) {
            monthDisp = @"11月";
        } else {
            monthDisp = @"November";
        }
    } if ([cmd[1] isEqualToString:@"12"]) {
        if ([userLang isEqualToString:@"JA"]) {
            monthDisp = @"12月";
        } else {
            monthDisp = @"December";
        }
    }
    return [NSString stringWithFormat:@"%@ %@", monthDisp, dayDisp];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setMonth:(id)sender {
    
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
