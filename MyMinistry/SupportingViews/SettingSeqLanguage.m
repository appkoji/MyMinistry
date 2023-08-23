//
//  SettingSeqLanguage.m
//  MyMinistry
//
//  Created by Koji Murata on 21/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "SettingSeqLanguage.h"
#import "SettingSeqOthers.h"

@interface SettingSeqLanguage ()
- (IBAction)languageBtnPressed:(id)sender;

@end

@implementation SettingSeqLanguage

- (void)dismissSetupScene {
    [self.parent dismissViewControllerAnimated:YES completion:^{
        //start the app
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //configure parent <navigation viewController>
    self.parent = self.parentViewController;
    NSLog(@"parentView Controller %@", self.parent);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    id destView = [segue destinationViewController];
    [destView setParentNav:self.parent];
    
    if ([sender accessibilityIdentifier]) {
        NSLog(@"user has selected language %@", [sender accessibilityIdentifier]);
        
        //update language save data
        NSUserDefaults *saveDat = [NSUserDefaults standardUserDefaults];
        [saveDat setObject:[sender accessibilityIdentifier] forKey:@"userSetting-lang"];
        [saveDat synchronize];
        
        //auto-update language setting
        if ([[sender accessibilityIdentifier] containsString:@"JA"]) {
            self.navigationController.navigationBar.topItem.title = @"もどる";
        } else {
            self.navigationController.navigationBar.topItem.title = @"Back";
        }
    }
}

- (IBAction)languageBtnPressed:(id)sender {
    
    
}

@end
