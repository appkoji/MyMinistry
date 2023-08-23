//
//  DispCell.m
//  MyMinistry
//
//  Created by Koji Murata on 08/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "DispCell.h"
#import "SubmitScene.h"

@implementation DispCell

- (void)maskLabel {
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    //keyboard did start editing
    
}

- (void)displayCompletedCheckWithProgress:(int)progress total:(int)total {
    
    float currentProg = (float)progress/(float)total;
    
    if (_completedCheck) {
        
        [_nameDisplay setTextColor:[UIColor whiteColor]];
        [_progressBar setHidden:YES];
        
        if (_progressBar) {
            [_progressBar setHidden:NO];
            [_progressBar setProgress:currentProg];
        }
        
        if (total > 0) {
            [_progressBar setHidden:NO];
            if (progress >= total) {
                [_completedCheck setHidden:NO];
                _iconDisplay.image = [_iconDisplay.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            } else {
                [_completedCheck setHidden:YES];
                _iconDisplay.image = [_iconDisplay.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            }
        }
    }
    
    NSLog(@"displayCompletedCheck for %@ value: %d/%d progress: %f", _nameDisplay.text, progress, total, currentProg);
    
}

@end
