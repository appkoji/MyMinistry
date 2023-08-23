//
//  AddContact.m
//  MyMinistry
//
//  Created by Koji Murata on 22/10/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "AddContact.h"
#import "ReturnVisits.h"

@interface AddContact ()

@property (strong, nonatomic) IBOutlet UIView *visibleView;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) NSMutableArray *inputDat;

- (IBAction)btnAction:(id)sender;

@end

@implementation AddContact

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_visibleView.layer setCornerRadius:15.0f];
    [_visibleView.layer setMasksToBounds:YES];
    
    [_textField.layer setCornerRadius:10.0f];
    [_textField.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_textField.layer setBorderWidth:0.8];
    
    [_saveBtn.layer setCornerRadius:8.0f];
    [_cancelBtn.layer setCornerRadius:8.0f];
    
}

- (IBAction)btnAction:(id)sender {
    
    if (sender == _saveBtn) {
        
        // get save data
        NSUserDefaults *save = [NSUserDefaults standardUserDefaults];
        
        //unarchive or create new dataset
        if ([save objectForKey:@"user_returnVisits"]) {
            _inputDat = [[NSKeyedUnarchiver unarchiveObjectWithData:[save objectForKey:@"user_returnVisits"]] mutableCopy];
        } else {
            _inputDat = [NSMutableArray new];
        }
        
        //new data
        NSMutableDictionary *sampleEntry = [[NSMutableDictionary alloc] init];
        [sampleEntry setObject:_textField.text forKey:@"name"];
        [_inputDat addObject:sampleEntry];
        
        //archive
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:_inputDat];
        [save setObject:archivedData forKey:@"user_returnVisits"];
        
        [self dismissViewControllerAnimated:YES completion:^{
            //update collection
            [self->_parent reloadContactsData];
        }];
        
    } else if (sender == _cancelBtn) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

@end
