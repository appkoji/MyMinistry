//
//  ArraySelectionView.h
//  MyMinistry
//
//  Created by Koji Murata on 15/04/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArraySelectionView : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) id parentView;

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UITableView *displayTable;
@property (strong, nonatomic) NSArray *inputData;

@property (strong, nonatomic) NSString *savingObjectKey;

//for preselected objects
@property NSString *preselectedObject;

- (IBAction)cancelAction:(id)sender;

@end
