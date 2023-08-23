//
//  MonthYearCell.h
//  MyMinistry
//
//  Created by Koji Murata on 10/03/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonthYearCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *monthview;
@property (strong, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) id parent;
@property (strong, nonatomic) NSString *commandString;

@end
