//
//  RecordDispCell.h
//  MyMinistry
//
//  Created by Koji Murata on 11/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordDispCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UITextView *lbl_refNotes;
@property (strong, nonatomic) IBOutlet UILabel *lbl_pubs;
@property (strong, nonatomic) IBOutlet UILabel *lbl_vids;
@property (strong, nonatomic) IBOutlet UILabel *lbl_time;
@property (strong, nonatomic) IBOutlet UILabel *lbl_rvs;
@property (strong, nonatomic) IBOutlet UILabel *lbl_bss;
@property (strong, nonatomic) IBOutlet UILabel *lbl_dayDateDisp;

@end
