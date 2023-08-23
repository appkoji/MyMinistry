//
//  InstructionViewController.m
//  MyMinistry
//
//  Created by Koji Murata on 15/03/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "InstructionViewController.h"
#import "InstructionView.h"

@interface InstructionViewController ()

@property (strong, nonatomic) NSArray *instructionSequence;
@property int pendingIndex;
@end

@implementation InstructionViewController


- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    NSArray *cmd = [[_instructionSequence objectAtIndex:index] componentsSeparatedByString:@"/"];
    NSString *pageID = cmd[0];
    
    if (([self.instructionSequence count] == 0) || (index >= [self.instructionSequence count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    InstructionView *pageContent = [self.storyboard instantiateViewControllerWithIdentifier:pageID];
    pageContent.pageIndex = index;
    
    pageContent.inputTitleString = [self localizeWithText:cmd[1]];
    pageContent.inputDescriptionString = [self localizeWithText:cmd[2]];
    pageContent.inputBackgroundImage = [UIImage imageNamed:cmd[3]];
    
    
    if (cmd.count > 4) {
        pageContent.inputVideoUrl = cmd[4];
    }
    
    return pageContent;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((InstructionView*) viewController).pageIndex;
    NSInteger totalCount = _instructionSequence.count;

    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
    NSLog(@"pageViewController index:%ld/total:%ld", index, totalCount);
    if (index == totalCount) {
        [_nextBtn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
        [_nextBtn setTag:1];
    } else {
        [_nextBtn setImage:[UIImage imageNamed:@"nextBtn"] forState:UIControlStateNormal];
        [_nextBtn setTag:0];
    }
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((InstructionView*) viewController).pageIndex;
    NSInteger totalCount = _instructionSequence.count;

    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    NSLog(@"pageViewController index:%ld/total:%ld", index, totalCount);
    if (index == totalCount) {
        [_nextBtn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
        [_nextBtn setTag:1];
    } else {
        [_nextBtn setImage:[UIImage imageNamed:@"nextBtn"] forState:UIControlStateNormal];
        [_nextBtn setTag:0];
    }
    
    if (index == [self.instructionSequence count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}


 
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _instructionSequence = @[@"InstUp/t1/d1/titleImg",@"InstDn/t2/d2/titleImg-2",@"InstVid/t3/d3/titleImg-3/smartBarVid",@"InstUp/t4/d4/mibg-01"];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    UIViewController *startingViewController = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = @[startingViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
    }];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    [self.view bringSubviewToFront:_nextBtn];
}

- (void)changePage:(UIPageViewControllerNavigationDirection)direction {
    
    NSUInteger index = ((InstructionView *)[self.pageController.viewControllers objectAtIndex:0]).pageIndex;
    NSInteger totalCount = _instructionSequence.count-1;
    
    
    NSLog(@"changePage index:%ld / count:%ld", index,totalCount);
    if (index == NSNotFound || index >= totalCount) {
        return;
    } else {
        index++;
        InstructionView *viewController = (InstructionView *)[self viewControllerAtIndex:index];
        if (viewController == nil) {
            return;
        } else {
            [self.pageController setViewControllers:@[viewController]
                                          direction:direction
                                           animated:YES
                                         completion:nil];
        }
    }
    
    //
    if (index == totalCount) {
        [_nextBtn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
        [_nextBtn setTag:1];
    } else {
        [_nextBtn setImage:[UIImage imageNamed:@"nextBtn"] forState:UIControlStateNormal];
        [_nextBtn setTag:0];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)localizeWithText:(NSString *)inputIdentifier {
    /*
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"localizedDisplayTexts" ofType:@"plist"]];
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    NSString *userLang = @"EN";
    if ([saveData objectForKey:@"userSetting-lang"]) {
        userLang = [saveData objectForKey:@"userSetting-lang"];
    }
    return [[dic objectForKey:inputIdentifier] objectForKey:userLang];
     */
    return NSLocalizedString(inputIdentifier, nil);

}

- (void)setViewControllers:(NSArray *)viewControllers direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^ _Nullable)(BOOL))completion {
    
}

- (IBAction)nextAction:(id)sender {
    if ([sender tag] == 0) {
        [self changePage:UIPageViewControllerNavigationDirectionForward];
    } else {
        //save setting
        [[NSUserDefaults standardUserDefaults] setObject:@"EN" forKey:@"userSetting-lang"]; //set instructions finished
        [[NSUserDefaults standardUserDefaults] setObject:@"DONE" forKey:@"appGuide"]; //set english languages
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //close view
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
}

@end
