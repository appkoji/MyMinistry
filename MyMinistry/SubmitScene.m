//
//  SubmitScene.m
//  MyMinistry
//
//  Created by Koji Murata on 23/02/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "SubmitScene.h"
#import "DispCell.h"
#import "PrintedReportGenerator.h"
#import "ImageViewer.h"
#import "AppDelegate.h"

@interface SubmitScene ()
@property (strong, nonatomic) IBOutlet UIImageView *bgImg;
@property (strong, nonatomic) UIImage *printedReportImg;
@property NSArray *dataDisplay;
@property BOOL isRunningInFullScreen;
@end

@implementation SubmitScene

// Generating/Sending Reports

- (void)sendReportSMS:(id)sender {
    
    NSString *message = [NSString stringWithFormat:@"%@\n\nMade by SmartMinistry for iOS", [self generateReportString]];
    
    NSArray *items = @[message,[NSURL URLWithString:@"https://apple.co/2Hy1xaG"]];
    
    // build an activity view controller
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    controller.excludedActivityTypes = @[UIActivityTypePostToFacebook,UIActivityTypePostToTwitter,UIActivityTypePostToVimeo,UIActivityTypePostToWeibo,UIActivityTypePostToFlickr,UIActivityTypeAssignToContact];
    
    [self presentActivityController:controller withSourceRect:[sender frame]];
    
}

- (void)presentActivityController:(UIActivityViewController *)controller withSourceRect:(CGRect)screct {
    
    // for iPad: make the presentation a Popover
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    popController.sourceView = self.view;
    popController.sourceRect = screct;
    
    // access the completion handler
    controller.completionWithItemsHandler = ^(NSString *activityType,
                                              BOOL completed,
                                              NSArray *returnedItems,
                                              NSError *error){
        // react to the completion
        if (completed) {
            // user shared an item
            NSLog(@"We used activity type%@", activityType);
        } else {
            // user cancelled
        }
        
        if (error) {
            NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
        }
    };
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
            break;
        case MessageComposeResultSent:
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}
//







- (void)keyboardDidOpen:(NSNotification *)notification {
    
    //get keyboard height
    CGRect kbRect = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
    _reportCollections.contentInset = contentInsets;
    _reportCollections.scrollIndicatorInsets = contentInsets;
    
    //show keyboard hide
    [_keyboardClose setEnabled:YES];
    
    if (_editingTextView.tag == 2) {
        [_editingTextView setTag:0];
        [_editingTextView setText:@""];
    }
    
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *theCell = [collectionView cellForItemAtIndexPath:indexPath];
    //sendSms
    
    if ([theCell.accessibilityValue isEqualToString:@"sendSms"]) {
        //open sms
        [self sendReportSMS:theCell];
    }
    
    if ([theCell.accessibilityValue isEqualToString:@"sendPrinted"]) {
        //open printed version, get ready to send
        PrintedReportGenerator *prg = [self.storyboard instantiateViewControllerWithIdentifier:@"PrintedReportGenerator"];
        prg.parent = self;
        self.printedReportImg = [prg generatePrintedReport];
        //
        ImageViewer *iv = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewer"];
        [self.navigationController pushViewController:iv animated:YES];
        //
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            //background thread| generate image function
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                //update ui on main thread
                [iv.imageView setImage:self.printedReportImg];
            });
        });
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


- (NSString *)generateReportString {
    
    //Field Service Report
    //Month: March 2018
    NSString *rm = [NSString stringWithFormat:@"%@: %@",[self localizeWithText:@"fsr"], self.reportingMonth];
    NSString *pubs = [NSString stringWithFormat:@"%@: %@",[self localizeWithText:@"pubs"], [[_inputData objectForKey:@"tot-pubs"] stringValue]];
    NSString *vids = [NSString stringWithFormat:@"%@: %@",[self localizeWithText:@"vids"], [[_inputData objectForKey:@"tot-vids"] stringValue]];
    NSString *time = [NSString stringWithFormat:@"%@: %@",[self localizeWithText:@"time"], [[_inputData objectForKey:@"tot-hours"] stringValue]];
    NSString *rvs = [NSString stringWithFormat:@"%@: %@",[self localizeWithText:@"rvs"], [[_inputData objectForKey:@"tot-rvs"] stringValue]];
    NSString *bss = [NSString stringWithFormat:@"%@: %@",[self localizeWithText:@"bss"], [[_inputData objectForKey:@"tot-bss"] stringValue]];
    
    //Create
    if (!_editingTextView.text || [_editingTextView.text isEqualToString:@""] || _editingTextView.tag == 2) {
        return [NSString stringWithFormat:@"%@\n\n%@\n%@\n%@\n%@\n%@", rm, pubs, vids, time, rvs, bss];
    }
    return [NSString stringWithFormat:@"%@\n\n%@\n%@\n%@\n%@\n%@\n%@", rm, pubs, vids, time, rvs, bss, _editingTextView.text];
    
}




- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *theCell = [collectionView cellForItemAtIndexPath:indexPath];
    [theCell setAlpha:1.0f];
}
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *theCell = [collectionView cellForItemAtIndexPath:indexPath];
    [theCell setAlpha:0.5f];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //config collectionView inset
    CGFloat deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSLog(@"device version");
    if (deviceVersion < 11.0) {
        [collectionView setContentInset:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height+20.00, 0, 50, 0)];
    }
    return _dataDisplay.count;
}

- (IBAction)closeKB:(id)sender {
    
    NSUserDefaults *save = [NSUserDefaults standardUserDefaults];
    
    [_nameTextView endEditing:YES];
    [_editingTextView endEditing:YES];
    
    //update name
    [save setObject:_nameTextView.text forKey:@"userDat-name"];
    [save synchronize];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _reportCollections.contentInset = contentInsets;
    _reportCollections.scrollIndicatorInsets = contentInsets;
    
    [_keyboardClose setEnabled:NO];
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSArray *cmd = [[_dataDisplay objectAtIndex:indexPath.row] componentsSeparatedByString:@"/"];
    NSString *cellID = cmd[0];
    NSUserDefaults *save = [NSUserDefaults standardUserDefaults];
    
    //cell that displays constant data
    DispCell *theCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    theCell.parent = self;
    theCell.accessibilityValue = cmd[2]; // store commanding value
    [theCell.nameDisplay setText:[self localizeWithText:cmd[2]]];
    
    if (theCell.inputTextView) {
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidOpen:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        // notes
        if ([cmd[2] isEqualToString:@"notes"]) {
            _editingTextView = theCell.inputTextView;
            if (theCell.inputTextView.tag == 1) {
                [theCell.inputTextView setTag:2];
                [theCell.inputTextView setText:[self localizeWithText:@"notesPlaceholder"]];
            }
        }
        
        // input name
        if ([cmd[2] isEqualToString:@"userName"]) {
            _nameTextView = theCell.inputTextView;
            if ([save objectForKey:@"userDat-name"]) {
                [theCell.inputTextView setText:[save objectForKey:@"userDat-name"]];
            } else {
                [theCell.inputTextView setText:[[UIDevice currentDevice] name]];
            }
        }
        
        
    }
    
    // populate data
    if ([cmd[2] isEqualToString:@"pubs"]) {
        [theCell.valueDisplay setText:[[_inputData objectForKey:@"tot-pubs"] stringValue]];
    } if ([cmd[2] isEqualToString:@"vids"]) {
        [theCell.valueDisplay setText:[[_inputData objectForKey:@"tot-vids"] stringValue]];
    } if ([cmd[2] isEqualToString:@"time"]) {
        [theCell.valueDisplay setText:[self timeFormatted:[[_inputData objectForKey:@"tot-hours"] intValue]]];
    } if ([cmd[2] isEqualToString:@"rvs"]) {
        [theCell.valueDisplay setText:[[_inputData objectForKey:@"tot-rvs"] stringValue]];
    } if ([cmd[2] isEqualToString:@"bss"]) {
        [theCell.valueDisplay setText:[[_inputData objectForKey:@"tot-bss"] stringValue]];
    }
    
    //round corners
    if ([cellID isEqualToString:@"sendBtn"]) {
        [theCell.nameDisplay.layer setMasksToBounds:YES];
        [theCell.nameDisplay.layer setCornerRadius:15.0f];
    } if ([cellID isEqualToString:@"notesCell"]) {
        [theCell.layer setMasksToBounds:YES];
        [theCell.layer setCornerRadius:10.0f];
    }
    
    return theCell;
}

- (NSString *)timeFormatted:(int)unformattedTime {
    // input unformattedTime is in minutes.
    // convert to seconds first!
    
    int totalSeconds = unformattedTime*60;
    
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d",hours, minutes];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *cmd = [[_dataDisplay objectAtIndex:indexPath.row] componentsSeparatedByString:@"/"];
    float cellSize = [cmd[1] floatValue];
    float cellWidth = collectionView.frame.size.width-30;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (_isRunningInFullScreen == YES) {
            cellWidth = collectionView.frame.size.width-200;
        } else {
            cellWidth = collectionView.frame.size.width-30;
        }
    }
    return CGSizeMake(cellWidth, cellSize);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    CGRect frame = [UIApplication sharedApplication].delegate.window.frame;
    _isRunningInFullScreen = CGRectEqualToRect(CGRectMake(frame.origin.x, frame.origin.y, size.width, size.height), [UIApplication sharedApplication].delegate.window.screen.bounds);
    [_reportCollections reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(![MFMessageComposeViewController canSendText]) {
        _dataDisplay = @[@"labelDisp/50/monthlyReport",@"notesCell/44/userName",@"dataDisp/35/pubs",@"dataDisp/35/vids",@"dataDisp/35/time",@"dataDisp/35/rvs",@"dataDisp/35/bss",@"space/10/-",@"notesCell/180/notes",@"space/8/-",@"sendBtn/50/sendPrinted",@"space/10/-"];

    } else {
        _dataDisplay = @[@"labelDisp/50/monthlyReport",@"notesCell/44/userName",@"dataDisp/35/pubs",@"dataDisp/35/vids",@"dataDisp/35/time",@"dataDisp/35/rvs",@"dataDisp/35/bss",@"space/10/-",@"notesCell/180/notes",@"space/8/-",@"sendBtn/50/sendSms",@"sendBtn/50/sendPrinted",@"space/10/-"];

    }
    // populate data
    NSLog(@"submitted data %@", _inputData);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    _isRunningInFullScreen = CGRectEqualToRect(CGRectMake([UIApplication sharedApplication].delegate.window.frame.origin.x, [UIApplication sharedApplication].delegate.window.frame.origin.y, [UIApplication sharedApplication].delegate.window.frame.size.width, [UIApplication sharedApplication].delegate.window.frame.size.height), [UIApplication sharedApplication].delegate.window.screen.bounds);
    [self readBgImage];
}

- (void)readBgImage {
    NSLog(@"attempt to claim image from app delegate, update with transition");
    //check if app delegate has latest image
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate updateBGImageEntry];
    if (appDelegate.commonBGImages) {
        self.bgImg.image = appDelegate.commonBGImages;
    } else {
        self.bgImg.image = [UIImage imageNamed:@"mibg-02"];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)localizeWithText:(NSString *)inputIdentifier {
    return NSLocalizedString(inputIdentifier, nil);
}



@end
