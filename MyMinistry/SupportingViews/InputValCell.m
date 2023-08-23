//
//  InputValCell.m
//  MyMinistry
//
//  Created by Koji Murata on 08/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "InputValCell.h"
#import "AddReport.h"
#import "GoalSettingScene.h"
#import "ButtonCell.h"
#import "EditReports.h"
#import <AudioToolbox/AudioToolbox.h>


@implementation InputValCell

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectedCategoryIndex = indexPath.row;
    ButtonCell *theCell = (ButtonCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self setButtonCell:theCell highlighted:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    ButtonCell *theCell = (ButtonCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self setButtonCell:theCell highlighted:NO];
}

- (void)setButtonCell:(ButtonCell *)theCell highlighted:(BOOL)highlight {
    if (highlight == YES) {
        [theCell.vfxView setEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    } else {
        [theCell.vfxView setEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _mcvData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSString *cellID = @"btnCell";
    
    ButtonCell *theCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    [theCell.text setText:[_mcvData objectAtIndex:indexPath.row]];
    return theCell;
    
    //return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 80);
}

- (void)startupCollectionView:(NSArray *)inputDatas {
    _mcvData = inputDatas;
    _multiCollectionview.delegate = self;
    _multiCollectionview.dataSource = self;
    
}

- (void)maskVFX {
    [_vfxView.layer setCornerRadius:10];
    [_vfxView.layer setMasksToBounds:YES];
}

- (void)initializeCellObject {
    
    [self setUserInteractionEnabled:YES];
    
    if (_currentValue && self.tag == 0) {
        self.tag = 1;
        _outputValue = 0;
        [self updateValue];
    }
    if (_inputTextField) {
        if (!_inputTextField.delegate) {
            _inputTextField.delegate = self;
        }
    }
}

- (void)resetData {
    if (_inputTextField) {
        [_inputTextField setTag:5];
        [_inputTextField setText:@""];
    }
    if (_currentValue) {
        _outputValue = 0.0;
        [self updateValue];
    }
    if (_currentDateDisp) {
        //[_currentDateDisp setText:@""];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.parent isKindOfClass:[AddReport class]] && textView.tag == 5) {
        textView.tag = 0;
        [textView setText:@""];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if ([_parent respondsToSelector:@selector(setRefNotes:)] == YES) {
        [_parent setRefNotes:_inputTextField.text];
    }
    
    if ([_parent respondsToSelector:@selector(editableDatas)] == YES) {
        //[[_parent editableDatas] setObject:[NSNumber numberWithInt:extractedValue] forKey:self.dataTypeIdentifier];
        [[_parent editableDatas] setObject:textView.text forKey:@"data-refNotes"];
    }
    
}

- (void)updateValue {
    
    
    double extractedValue;
    
    if ([self.dataTypeIdentifier containsString:@"time"] || [self.dataTypeIdentifier containsString:@"hours"]) {
        
        /*
        int totalMinutes = (int)_outputValue;
        float decimal = _outputValue-totalMinutes;
        
        //DETECT OLD TIME FORMAT, and convert into new time format
        // app version
        float ver = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue];
        if (decimal > 0 && ver >= 2.0) {
            //convert to new format
            float decCalc = decimal*60;
            int cnvCalc = ((totalMinutes*60)+(int)decCalc)*1;// total minutes
            int totalSec = cnvCalc*60;
            NSLog(@"OLD TIME FORMAT %f -> minute:%d seconds:%d",_outputValue, cnvCalc, totalSec);
            _outputValue = cnvCalc;// seconds format
        }
        
        minutes = totalMinutes;
        
        // new cmds
        int scrollAdj = (int)_outputValue*60;
        NSString *converted = [self timeFormatted:scrollAdj];
        NSString *strVal = [converted stringByReplacingOccurrencesOfString:@"." withString:@":"];
        NSArray *mnDat = [strVal componentsSeparatedByString:@":"];
        
        // what to display on editing cell
        if ([[mnDat firstObject] intValue] < 1 && [[mnDat lastObject] intValue] < 1) {
            [_currentValue setText:@"00:00"];
        } else {
            [_currentValue setText:[NSString stringWithFormat:@"%@",strVal]];//minutes
        }
         */
        
        // app version
        int totalMinutes = (int)_outputValue;
        float decimal = _outputValue-totalMinutes; // check for decimal places
        
        // old time format has decimal places while new one does not have.
        if (decimal != 0) {
            //convert to new format
            float decCalc = decimal*60;
            int cnvCalc = ((totalMinutes*60)+(int)decCalc)*1;// get total minutes
            int totalSec = cnvCalc*60;
            NSLog(@"IS OLD TIME FORMAT %f -> minute:%d seconds:%d",_outputValue, cnvCalc, totalSec);
            //_outputValue = cnvCalc;// seconds format
        }
        
        //convert input data into
        //int totalMinutes = (int)_outputValue;
        NSString *tFormat = [self timeFormatted:totalMinutes];
        tFormat = [tFormat stringByReplacingOccurrencesOfString:@"." withString:@":"];
        
        [_currentValue setText:[NSString stringWithFormat:@"%@",tFormat]];
        extractedValue = totalMinutes;
        //        extractedValue = [_currentValue.text intValue];
        NSLog(@"totalMinutes %d extracted %f", totalMinutes, extractedValue);
        
    } else {
        [_currentValue setText:[NSString stringWithFormat:@"%.f",_outputValue]];
        extractedValue = [_currentValue.text intValue];
        
    }
    
    //extract value
    
    //apply this data to parent data
    if ([self.dataTypeIdentifier isEqualToString:@"pubs"]) {
        [_parent setPubs:(int)extractedValue];
    } if ([self.dataTypeIdentifier isEqualToString:@"vids"]) {
        [_parent setVids:(int)extractedValue];
    } if ([self.dataTypeIdentifier isEqualToString:@"time"]) {
        [_parent setHours:(int)extractedValue];
    } if ([self.dataTypeIdentifier isEqualToString:@"rvs"]) {
        [_parent setRvs:(int)extractedValue];
    } if ([self.dataTypeIdentifier isEqualToString:@"bss"]) {
        [_parent setBss:(int)extractedValue];
    }
    
    if ([self.dataTypeIdentifier isEqualToString:@"goal-hrs"]) {
        [_parent settingToValue:(int)extractedValue forData:self.dataTypeIdentifier];
    } if ([self.dataTypeIdentifier isEqualToString:@"goal-pubs"]) {
        [_parent settingToValue:(int)extractedValue forData:self.dataTypeIdentifier];
    } if ([self.dataTypeIdentifier isEqualToString:@"goal-vids"]) {
        [_parent settingToValue:(int)extractedValue forData:self.dataTypeIdentifier];
    } if ([self.dataTypeIdentifier isEqualToString:@"goal-rvs"]) {
        [_parent settingToValue:(int)extractedValue forData:self.dataTypeIdentifier];
    }
    
    //for data update
    if ([self.dataTypeIdentifier isEqualToString:@"data-pubs"]) {
        [[_parent editableDatas] setObject:[NSNumber numberWithInt:(int)extractedValue] forKey:self.dataTypeIdentifier];
    } if ([self.dataTypeIdentifier isEqualToString:@"data-vids"]) {
        [[_parent editableDatas] setObject:[NSNumber numberWithInt:(int)extractedValue] forKey:self.dataTypeIdentifier];
    } if ([self.dataTypeIdentifier isEqualToString:@"data-hours"]) {
        [[_parent editableDatas] setObject:[NSNumber numberWithInt:(int)extractedValue] forKey:self.dataTypeIdentifier];
    } if ([self.dataTypeIdentifier isEqualToString:@"data-rvs"]) {
        [[_parent editableDatas] setObject:[NSNumber numberWithInt:(int)extractedValue] forKey:self.dataTypeIdentifier];
    } if ([self.dataTypeIdentifier isEqualToString:@"data-bss"]) {
        [[_parent editableDatas] setObject:[NSNumber numberWithInt:(int)extractedValue] forKey:self.dataTypeIdentifier];
    }
    
    if (extractedValue != _lastValue) {
        [_feedback selectionChanged];
        [_feedback prepare];
        _lastValue = extractedValue;
    }
    
}

- (NSString *)timeFormatted:(int)inputMinutes {
    int totalSeconds = inputMinutes*60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d.%02d",hours, minutes];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (_dataTypeIdentifier) {
        [UIView animateWithDuration:0.05f animations:^{
            [_activeIndicator setAlpha:0.6f];
        }];
        
        AudioServicesPlaySystemSound(1519);
        
        _feedback = [[UISelectionFeedbackGenerator alloc] init];
        [_feedback prepare];
    }
    
    if (self.restorationIdentifier) {
        [self.parent didReturnTapFunctionFor:self.restorationIdentifier];
    }
    if (self.action) {
        [self.parent cellDidTap:self];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint newLocation = [touch locationInView:self];
    CGPoint prevLocation = [touch previousLocationInView:self];
    CGPoint velocity = CGPointMake(newLocation.x-prevLocation.x, prevLocation.y-newLocation.y);
    
    if (velocity.x > 0) {
        float velocityCalc = velocity.x;
        if ([self.dataTypeIdentifier containsString:@"time"] || [self.dataTypeIdentifier containsString:@"hours"]) {
            velocityCalc = velocity.x*5;
        }
        _outputValue += 0.1 * velocityCalc;
    } else {
        float velocityCalc = velocity.x;
        float nextValue;
        if ([self.dataTypeIdentifier containsString:@"time"] || [self.dataTypeIdentifier containsString:@"hours"]) {
            velocityCalc = velocity.x*8;
        }
        nextValue = _outputValue + (0.1 * velocityCalc);
        if (nextValue <= 0) {
            _outputValue = 0;
        } else {
            _outputValue = nextValue;
        }
    }
    
    [self updateValue];

}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _feedback = nil;
    [UIView animateWithDuration:0.2f animations:^{
        [_activeIndicator setAlpha:0.0f];
    }];
}

//------
- (NSString *)localizeWithText:(NSString *)inputIdentifier {
    return NSLocalizedString(inputIdentifier, nil);
}
//------

- (IBAction)questionPressed:(id)sender {
    
    // display SmartBar instruction.
    [_parent displayHelp:[sender accessibilityLabel]];
}

@end
