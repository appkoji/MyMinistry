//
//  EditReports.h
//  MyMinistry
//
//  Created by Koji Murata on 11/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditReportsDelegate
- (void)didEditReport:(NSMutableDictionary *)updatedReport;
@end

@interface EditReports : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

//nav bar
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelNavBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneNavBtn;


@property (unsafe_unretained) id <EditReportsDelegate> delegate;
@property (strong, nonatomic) IBOutlet UICollectionView *displayCollections;
@property (weak, nonatomic) id mainParent;
@property (weak, nonatomic) id parent;

@property (strong, nonatomic) NSMutableDictionary *editableDatas;
@property (strong, nonatomic) IBOutlet UIToolbar *editToolbar;
@property (weak, nonatomic) UINavigationBar *navBar;


- (IBAction)deleteAction:(id)sender;

- (IBAction)toolBarActions:(id)sender;

@end
