//
//  GoalSettingScene.h
//  MyMinistry
//
//  Created by Koji Murata on 27/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputValCell.h"


@interface GoalSettingScene : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) NSUserDefaults *save;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *populatingData;

@property int goalTime;
@property int goalPubs;
@property int goalVids;
@property int goalRvs;

- (void)settingToValue:(int)newVal forData:(NSString *)dataType;
- (void)cellDidTap:(InputValCell *)theCell;
- (void)saveToValue:(NSString *)newVal forData:(NSString *)dataType;

@end
