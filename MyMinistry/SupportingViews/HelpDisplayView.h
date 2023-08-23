//
//  HelpDisplayView.h
//  MyMinistry
//
//  Created by Koji Murata on 25/03/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface HelpDisplayView : UIViewController

// view that display video
@property (weak, nonatomic) IBOutlet UIView *shortDisplayView;
@property (nonatomic) AVPlayer *avPlayer;
@property NSString *inputDat;

- (IBAction)closeView:(id)sender;

@end
