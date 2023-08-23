//
//  MMAlertView.m
//  MyMinistry
//
//  Created by Koji Murata on 11/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "MMAlertView.h"

@interface MMAlertView ()

@property (strong, nonatomic) IBOutlet UIView *alertView;

@property (strong, nonatomic) IBOutlet UILabel *alertTitle;
@property (strong, nonatomic) IBOutlet UITextView *alertText;

- (IBAction)alertCancelAction:(id)sender;
- (IBAction)alertDestructiveAction:(id)sender;

@end

@implementation MMAlertView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_alertView.layer setMasksToBounds:YES];
    [_alertView.layer setCornerRadius:5.0];
    [_alertView setAlpha:0.0];
    
}

- (void)displayAlertWithTitle:(NSString *)title description:(NSString *)description {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.alertTitle setText:title];
        [self.alertText setText:description];
        [_alertView setAlpha:0.0];
        [_alertView setTransform:CGAffineTransformMakeScale(0.6, 0.6)];
        [UIView animateWithDuration:0.1f animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [_alertView setAlpha:1.0];
            [_alertView setTransform:CGAffineTransformMakeScale(1.1f, 1.1f)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.05f animations:^{
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                [_alertView setTransform:CGAffineTransformMakeScale(1.0f, 1.0f)];
            }];
        }];
    });
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)alertCancelAction:(id)sender {
    [_delegate mmAlertviewDidRespond:NO :self];
}

- (IBAction)alertDestructiveAction:(id)sender {
    [_delegate mmAlertviewDidRespond:YES :self];
}

@end
