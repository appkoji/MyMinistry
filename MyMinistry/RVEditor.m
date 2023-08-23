//
//  RVEditor.m
//  MyMinistry
//
//  Created by Koji Murata on 06/04/2018.
//  Copyright © 2018 KojiGames. All rights reserved.
//

#import "RVEditor.h"
#import "InputValCell.h"

@interface RVEditor ()
@property NSMutableArray *dataStruct;
@end

@implementation RVEditor

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataStruct.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    //extract data
    //NSArray *cmd = [[_dataStruct objectAtIndex:indexPath.row] componentsSeparatedByString:@"/"];
    NSString *cellID = [_dataStruct objectAtIndex:indexPath.row];
    
    //cell that displays constant data
    InputValCell *theCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    [theCell.layer setCornerRadius:10.0f];
    [theCell.layer setMasksToBounds:YES];
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
    if ([cellID isEqualToString:@"rvNameCell"]) {
        [theCell.editableFieldDisplay setText:[_inputRVData objectForKey:@"name"]];
    }
    if ([cellID isEqualToString:@"rvBasicInfoCell"]) {
        if ([_inputRVData objectForKey:@"description"]) {
            [theCell.inputTextField setText:[_inputRVData objectForKey:@"description"]];
        } else {
            [theCell.inputTextField setText:@"Notes..."];
        }
    }
    
    //required only when requested

    
    return theCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //CELL SIZE
    
    //iPhone
    float cellSize = 10;
    float width = collectionView.frame.size.width-30;
    
    //determine for each cell structure
    NSString *cellID = [_dataStruct objectAtIndex:indexPath.row];
    
    if ([cellID isEqualToString:@"rvNameCell"]) {
        cellSize = 58;
    } if ([cellID isEqualToString:@"isBSSelectorCell"]) {
        cellSize = 40;
    } if ([cellID isEqualToString:@"rvBasicInfoCell"]) {
        cellSize = 300;
    } if ([cellID isEqualToString:@"nextVisitDateCell"]) {
        cellSize = 60;
    } if ([cellID isEqualToString:@"rvAddressCell"]) {
        cellSize = 60;
    } if ([cellID isEqualToString:@"labelCell"]) {
        cellSize = 40;
    } if ([cellID isEqualToString:@"visitNotesCell"]) {
        cellSize = 100;
    }
    
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        //iPad
        width = collectionView.frame.size.width-200;
        cellSize += 20;
    }
    return CGSizeMake(width, cellSize);
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //structure view data
    /*
     */
    
    _dataStruct = [NSMutableArray new];
    [_dataStruct addObjectsFromArray:@[@"rvNameCell",@"rvBasicInfoCell"]];
    
    //check if this current data contains visit notes cell
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    
}

@end
