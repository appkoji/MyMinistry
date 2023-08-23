//
//  ReturnVisits.h
//  MyMinistry
//
//  Created by Koji Murata on 06/04/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReturnVisits : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImg;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addBtn;

- (IBAction)addAction:(id)sender;
- (void)reloadContactsData;

@end
