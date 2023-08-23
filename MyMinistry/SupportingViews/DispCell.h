//
//  DispCell.h
//  MyMinistry
//
//  Created by Koji Murata on 08/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DACircularProgressView.h"
#import <UIKit/UIKit.h>

@interface DispCell : UICollectionViewCell <UITextViewDelegate>

@property (weak, nonatomic) id parent;

@property (strong, nonatomic) IBOutlet UILabel *nameDisplay;
@property (strong, nonatomic) IBOutlet UILabel *valueDisplay;
@property (strong, nonatomic) IBOutlet UILabel *goalValueDisplay;

@property (strong, nonatomic) IBOutlet UIImageView *iconDisplay;
@property (strong, nonatomic) IBOutlet DACircularProgressView *timeProgressView;
@property (strong, nonatomic) IBOutlet UIVisualEffectView *vfxView;

@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;
@property (strong, nonatomic) IBOutlet UIImageView *completedCheck;

@property (strong, nonatomic) IBOutlet UITextView *inputTextView;

@property NSString *customFunc;

- (void)maskLabel;
- (void)displayCompletedCheckWithProgress:(int)progress total:(int)total;

@end
