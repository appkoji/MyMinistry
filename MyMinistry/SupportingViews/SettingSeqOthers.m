//
//  SettingSeqOthers.m
//  MyMinistry
//
//  Created by Koji Murata on 21/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "SettingSeqOthers.h"
#import "SetupReadyView.h"

@interface SettingSeqOthers ()


@property (strong, nonatomic) IBOutlet UILabel *nameAskLabel;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UIButton *nextBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarBtn;

@property NSString *lang;

- (IBAction)textFieldStartEditing:(id)sender;
- (IBAction)textfieldDidChange:(id)sender;
- (IBAction)doneEditingText:(id)sender;


@end

@implementation SettingSeqOthers

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_nameTextField.layer setMasksToBounds:YES];
    [_nameTextField.layer setCornerRadius:10.0f];
    [_nextBtn.layer setMasksToBounds:YES];
    [_nextBtn.layer setCornerRadius:10.0f];
    
    [_doneBarBtn setEnabled:NO];
    [self setNextBtnEnabled:NO];
    
    //claim language tag
    NSUserDefaults *saveDat = [NSUserDefaults standardUserDefaults];
    _lang = [saveDat objectForKey:@"userSetting-lang"];
    
    //set localized string
    if ([_lang isEqualToString:@"JA"]) {
        [_doneBarBtn setTitle:@"完了"];
        [_nameTextField setPlaceholder:@"お名前"];
        [_nextBtn setTitle:@"次へ" forState:UIControlStateNormal];
        [_nameAskLabel setText:@"あなたのお名前はなんですか？"];
    } else {
        //english
        [_doneBarBtn setTitle:@"Done"];
        [_nameTextField setPlaceholder:@"Name"];
        [_nextBtn setTitle:@"Next" forState:UIControlStateNormal];
        [_nameAskLabel setText:@"What is your name?"];
    }
}

- (void)setNextBtnEnabled:(BOOL)state {
    if (state == YES) {
        [_nextBtn setEnabled:YES];
        [_nextBtn setAlpha:1.0];
    } else {
        [_nextBtn setEnabled:NO];
        [_nextBtn setAlpha:0.5];
    }
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
    
    id dest = [segue destinationViewController];
    [dest setParent:self];
    
    //save username
    NSUserDefaults *saveDat = [NSUserDefaults standardUserDefaults];
    [saveDat setObject:_nameTextField.text forKey:@"userSetting-name"];
    [saveDat synchronize];
    
}


- (IBAction)textFieldStartEditing:(id)sender {
    [_doneBarBtn setEnabled:YES];
}

- (IBAction)textfieldDidChange:(id)sender {
    if ([_nameTextField.text isEqualToString:@""] || _nameTextField.text == nil) {
        [self setNextBtnEnabled:NO];
    } else {
        [self setNextBtnEnabled:YES];
    }
}

- (IBAction)doneEditingText:(id)sender {
    [_doneBarBtn setEnabled:NO];
    [_nameTextField endEditing:YES];
    if ([_nameTextField.text isEqualToString:@""] || _nameTextField.text == nil) {
        [self setNextBtnEnabled:NO];
    } else {
        [self setNextBtnEnabled:YES];
    }
}

@end
