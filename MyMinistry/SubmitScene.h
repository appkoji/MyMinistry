//
//  SubmitScene.h
//  MyMinistry
//
//  Created by Koji Murata on 23/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SubmitScene : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) NSDictionary *inputData;
@property (strong, nonatomic) NSString *reportingMonth;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *keyboardClose;
@property (strong, nonatomic) IBOutlet UICollectionView *reportCollections;

@property UITextView *nameTextView;
@property UITextView *editingTextView;

- (IBAction)closeKB:(id)sender;
- (void)sendReportSMS:(id)sender;

@end
