//
//  InstructionViewController.h
//  MyMinistry
//
//  Created by Koji Murata on 15/03/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstructionViewController : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageController;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

- (IBAction)nextAction:(id)sender;


@end
