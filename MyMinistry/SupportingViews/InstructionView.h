//
//  InstructionView.h
//  MyMinistry
//
//  Created by Koji Murata on 15/03/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface InstructionView : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet UIView *videoDisplayView;

@property (nonatomic) AVPlayer *avPlayer;

@property NSInteger pageIndex;
@property NSString *inputTitleString;
@property NSString *inputDescriptionString;
@property UIImage *inputBackgroundImage;

@property NSString *inputVideoUrl;

@end
