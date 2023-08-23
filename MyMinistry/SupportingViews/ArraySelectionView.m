//
//  ArraySelectionView.m
//  MyMinistry
//
//  Created by Koji Murata on 15/04/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "ArraySelectionView.h"
#import "OverviewScene.h"
#import "GoalSettingScene.h"
#import "MonthYearCell.h"

@interface ArraySelectionView ()

@end

@implementation ArraySelectionView

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //disable table to be edited
    [self.view setUserInteractionEnabled:NO];
    
    MonthYearCell *tvc = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"didSelectRow -> changed language setting %@", tvc.commandString);

    //apply selection
    /*
    NSUserDefaults *save = [NSUserDefaults standardUserDefaults];
    [save setObject:tvc.commandString forKey:@"userSetting-lang"];
    [save synchronize];
     */
    
    _preselectedObject = tvc.commandString;
    
    [_parentView saveToValue:tvc.commandString forData:self.savingObjectKey];
    
    [_displayTable reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            [[_parentView collectionView] reloadData];
        }];
    });
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _inputData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *cmd = [[_inputData objectAtIndex:indexPath.row] componentsSeparatedByString:@"-"];
    
    MonthYearCell *cell = (MonthYearCell *)[tableView dequeueReusableCellWithIdentifier:@"displayCell"];
    cell.parent = self;
    [cell.imageIcon setHidden:YES];
    
    //set text
    [cell.monthview setText:cmd.firstObject];
    
    // command
    NSString *selectedObj = cmd[1];
    
    cell.commandString = selectedObj;
    
    if (_preselectedObject) {
        // highlight selected cell
        if ([_preselectedObject isEqualToString:selectedObj]) {
            [cell.imageIcon setHidden:NO];
        }
    }
    
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_displayTable setDelegate:self];
    [_displayTable setDataSource:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (NSString *)localizeWithText:(NSString *)inputIdentifier {
    /*
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"localizedDisplayTexts" ofType:@"plist"]];
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    NSString *userLang = @"EN";
    if ([saveData objectForKey:@"userSetting-lang"]) {
        userLang = [saveData objectForKey:@"userSetting-lang"];
    }
    return [[dic objectForKey:inputIdentifier] objectForKey:userLang];
     */
    return NSLocalizedString(inputIdentifier, nil);

}


@end
