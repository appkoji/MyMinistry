//
//  SetupReadyView.m
//  MyMinistry
//
//  Created by Koji Murata on 21/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "SetupReadyView.h"
#import "SettingSeqLanguage.h"
#import "SettingSeqOthers.h"

@interface SetupReadyView ()
@property (strong, nonatomic) IBOutlet UILabel *readyLbl;
@property (strong, nonatomic) IBOutlet UILabel *welcomingLbl;
@property (strong, nonatomic) IBOutlet UIImageView *check;
@property (strong, nonatomic) IBOutlet UIButton *startBtn;
- (IBAction)start:(id)sender;
@property NSString *lang;
@end

@implementation SetupReadyView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_startBtn.layer setMasksToBounds:YES];
    [_startBtn.layer setCornerRadius:10.0f];
    
    //claim language tag
    NSUserDefaults *saveDat = [NSUserDefaults standardUserDefaults];
    _lang = [saveDat objectForKey:@"userSetting-lang"];
    NSString *userName = [saveDat objectForKey:@"userSetting-name"];
    
    if ([_lang isEqualToString:@"JA"]) {
        [_readyLbl setText:@"準備設定完了!"];
        [_welcomingLbl setText:[NSString stringWithFormat:@"ようこそ\n%@さん",userName]];
        [_startBtn setTitle:@"はじめる" forState:UIControlStateNormal];
    } else {
        [_readyLbl setText:@"You're ready!"];
        [_welcomingLbl setText:[NSString stringWithFormat:@"Welcome\n%@",userName]];
        [_startBtn setTitle:@"Begin" forState:UIControlStateNormal];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [_check setAlpha:0.0];
    [_check setTransform:CGAffineTransformMakeScale(0.3f, 0.3f)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [_check setAlpha:1.0];
            [_check setTransform:CGAffineTransformMakeScale(1.2f, 1.2f)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                [_check setTransform:CGAffineTransformMakeScale(1.0f, 1.0f)];
            }];
        }];
    });
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)start:(id)sender {
    
    NSUserDefaults *saveDat = [NSUserDefaults standardUserDefaults];
    [saveDat setObject:@"YES" forKey:@"firstSetup"];
    
    [[_parent parentNav] dismissViewControllerAnimated:YES completion:^{
        NSLog(@"ParentNav -> to be dismissed");
    }];
}

@end
