//
//  ReturnVisits.m
//  MyMinistry
//
//  Created by Koji Murata on 06/04/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "ReturnVisits.h"
#import "DispCell.h"
#import "AppDelegate.h"
#import "RVEditor.h"
#import "AddContact.h"

@interface ReturnVisits ()

//all the rv data lists containing NSDictionary
@property NSMutableArray *inputDat;

// selection pointer
@property NSInteger selectedDataPointer;
@property NSDictionary *selectedRVData;

@end

@implementation ReturnVisits

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _inputDat.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedDataPointer = indexPath.row;
    _selectedRVData = [_inputDat objectAtIndex:indexPath.row];
    
    // open view from here!!
    RVEditor *rve = [self.storyboard instantiateViewControllerWithIdentifier:@"RVEditor"];
    rve.inputRVData = self.selectedRVData;
    [self.navigationController pushViewController:rve animated:YES];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    /*
    if ([segue.identifier isEqualToString:@"viewDataSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[RVEditor class]] == YES) {
            NSLog(@"segue to RVEditor");
            
            RVEditor *rve = (RVEditor *)segue.destinationViewController;
            rve.inputRVData = self.selectedRVData;
            
        }
    }*/
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    //extract data
    NSString *cellID = @"contactsCell";
    
    //cell that displays constant data
    DispCell *theCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    NSDictionary *theData = [_inputDat objectAtIndex:indexPath.row];
    
    [theCell.nameDisplay setText:[theData objectForKey:@"name"]];
    [theCell.valueDisplay setText:[theData objectForKey:@"nextVisit"]];
    
    //[theCell.layer setCornerRadius:10.0f];
    [theCell.layer setMasksToBounds:YES];
    
    return theCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //CELL SIZE
    
    //iPhone
    float cellSize = 60;
    float width = collectionView.frame.size.width-30;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        //iPad
        width = collectionView.frame.size.width-200;
        //cellSize = 120;
    }
    return CGSizeMake(width, cellSize);
}

- (void)reloadContactsData {
    
    NSUserDefaults *save = [NSUserDefaults standardUserDefaults];
    NSData *saveData = [save objectForKey:@"user_returnVisits"];
    NSError  * _Nullable nErr;
    
    //_inputDat = [[NSKeyedUnarchiver unarchiveObjectWithData:[save objectForKey:@"user_returnVisits"]] mutableCopy];
    
    //_inputDat = [[NSKeyedUnarchiver unarchivedObjectOfClass:[NSDictionary class] fromData:saveData error:NULL]];
    
    //[NSLog(@"Error -> %@", nErr)];
    
    [_collectionView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //load return visit data
    NSUserDefaults *save = [NSUserDefaults standardUserDefaults];
    
    if ([save objectForKey:@"user_returnVisits"]) {
        
        //unarchive data
        _inputDat = [[NSKeyedUnarchiver unarchiveObjectWithData:[save objectForKey:@"user_returnVisits"]] mutableCopy];
        
    } else {
        
        //no detected returnVisits
        
        _inputDat = [NSMutableArray new];
        
        
        //RV Data Sequences using NSSidctionary
        /*
         @{key:value}
         name NSString
         isBS BOOL
         description NSString
         nextVisit NSDate
         address NSString
         mapCoord CGPoint
         visitNotes NSArray @[NSDate, NSString]
         */
        
        /*
         
        NSMutableDictionary *sampleEntry = [[NSMutableDictionary alloc] init];
        [sampleEntry setObject:@"Koji Murata" forKey:@"name"];
        [sampleEntry setObject:@0 forKey:@"isBS"];
        [sampleEntry setObject:@"Koji is very interested in the truth. Although needs focus as of now." forKey:@"description"];
        [sampleEntry setObject:@"2018-04-11" forKey:@"nextVisit"];
        [sampleEntry setObject:@"27 Cambridge., Hillsborough., Alabang., Muntinlupa City., 1780" forKey:@"address"];
        [sampleEntry setObject:@"14.439784/121.033308" forKey:@"mapCoord"];
        [sampleEntry setObject:@[@[@"2018-04-01",@"First visit. What will happen when people die?"],@[@"2018-04-05",@"Gave 2018 Wt-2018-no.1"]] forKey:@"visitNotes"];
        
        [_inputDat addObject:sampleEntry];
        */
    }
    
    //start adding data depending on number of user's return visits
    NSLog(@"check inputDat %@", _inputDat.description);
    
    //check if iCloud has data
}

- (void)fetchiCloudSaveData {
    
    // make sure all devices share same data
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self readBgImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)addAction:(id)sender {
    
    AddContact *ac = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContact"];
    ac.parent = self;
    [self.tabBarController presentViewController:ac animated:YES completion:^{
        
    }];
    
}


@end
