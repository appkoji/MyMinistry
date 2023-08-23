//
//  InputValCell.h
//  MyMinistry
//
//  Created by Koji Murata on 08/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputValCell : UICollectionViewCell <UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView *multiCollectionview;
@property (strong, nonatomic) NSArray *mcvData;

@property (weak, nonatomic) id parent;

@property (strong, nonatomic) IBOutlet UILabel *currentDateDisp;
@property (strong, nonatomic) IBOutlet UILabel *datatypeDisplay;
@property (strong, nonatomic) IBOutlet UILabel *currentValue;
@property (strong, nonatomic) IBOutlet UITextField *editableFieldDisplay;
@property (strong, nonatomic) IBOutlet UITextView *inputTextField;

@property NSString *action;

- (IBAction)questionPressed:(id)sender;

@property float outputValue;
@property NSInteger selectedCategoryIndex;
@property NSInteger cellType;
@property int minimumRequiredValue;

@property int lastValue;

@property (strong, nonatomic) UIPanGestureRecognizer *pan;
@property (strong, nonatomic) IBOutlet UIImageView *activeIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *dataTypeIcon;
@property (strong, nonatomic) IBOutlet UIVisualEffectView *vfxView;
@property UISelectionFeedbackGenerator *feedback;

@property NSString *dataTypeIdentifier;

- (void)startupCollectionView:(NSArray *)inputDatas;
- (void)initializeCellObject;
- (void)updateValue;
- (void)resetData;
- (void)maskVFX;

- (NSString *)localizeWithText:(NSString *)inputIdentifier;

@end
