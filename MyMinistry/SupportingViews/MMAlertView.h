//
//  MMAlertView.h
//  MyMinistry
//
//  Created by Koji Murata on 11/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MMAlertViewDelegate
- (void)mmAlertviewDidRespond:(BOOL)response :(id)alertview;
@end

@interface MMAlertView : UIViewController

@property (unsafe_unretained) id <MMAlertViewDelegate> delegate;
@property (weak, nonatomic) id returningView;

- (void)displayAlertWithTitle:(NSString *)title description:(NSString *)description;

@end
