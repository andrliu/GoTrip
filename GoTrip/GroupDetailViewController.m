//
//  GroupDetailViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "GroupDetailViewController.h"
#import "Group.h"
#import "TextTableViewCell.h"
#import "ImageTableViewCell.h"
#import "ButtonTableViewCell.h"
#import "GroupCollectionViewCell.h"

@interface GroupDetailViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *collectionViewArray;
@property NSString *aString;

@end

@implementation GroupDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //TODO: clean that stuff. For testing only

    UIImage *image1 = [UIImage imageNamed:@"minsk"];
    UIImage *image2 = [UIImage imageNamed:@"portland"];
    UIImage *image3 = [UIImage imageNamed:@"sanfrancisco"];
    UIImage *image4 = [UIImage imageNamed:@"chicago"];
    self.collectionViewArray = @[image1,image2,image3,image4];

    self.aString = @"Excepteur sint occaecat \ncupidatat non proident, sunt in culpa qui officia desdolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip aute irure dolor in reprehenduptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint eserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Ut enim ad minim veniam, quis nostrud \nexercitation ullamco laboris nisi ut aliquip aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint eserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. \nUt enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint eserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiudaUt enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip aute irure dolor in reprehenduptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint eserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint eserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint eserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiudaUt enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip aute irure dolor in reprehenduptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint eserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint eserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint eserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiudaUt enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip aute irure dolor in reprehenduptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint eserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint eserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint eserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda  END.";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat theFloat = 0;


    CGFloat height = [self heightForString:self.aString];


    switch (indexPath.section)
    {
        case 0:
            theFloat = height*1.03 + 20;
            break;
        case 1:
            theFloat =  100.0;
            break;
        case 2:
            theFloat =  35.0;
            break;

        default:
            theFloat =  0;
            break;
    }

//    NSLog(@"section: %li row: %li height: %f",(long)indexPath.section, (long)indexPath.row, theFloat);

    return theFloat;

}

- (CGFloat)heightForString:(NSString *)theString
{

    CGRect textViewSize = [self.aString boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 16, CGFLOAT_MAX)
                                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                  attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}
                                                     context:nil];

    return textViewSize.size.height;

    //    UILabel *label = [[UILabel alloc]init];
    //    label.numberOfLines = 0;
    //    label.text = theString;
    //    label.font = [UIFont systemFontOfSize:14];
    //    CGSize aSize = [label sizeThatFits:CGSizeMake(self.tableView.frame.size.width - 16, CGFLOAT_MAX)];
    //
    //    return aSize.height;

}

//-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGFloat theFloat = 0;
//
//    switch (indexPath.section)
//        {
//            case 0:
//                theFloat = 44.0;
//                break;
//            case 1:
//                theFloat =  100.0;
//                break;
//            case 2:
//                theFloat =  44.0;
//                break;
//
//            default:
//                theFloat =  0;
//                break;
//        }
//
//    NSLog(@"section: %li row: %li height: %f",(long)indexPath.section, (long)indexPath.row, theFloat);
//    return 0;
//
//}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //TODO: return the individual array counts
    switch (section)
    {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 2;
            break;

        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            TextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
            //            cell.label.numberOfLines = 0;
            //            cell.label.text = self.aString;
            cell.textView.text = self.aString;

            cell.textView.scrollEnabled = NO;

            return cell;
        }
            break;

        case 1:
        {
            ImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];

            cell.collectionView.dataSource = self;
            cell.collectionView.delegate = self;
            cell.collectionView.pagingEnabled = YES;

            return cell;
        }
            break;

        case 2:
        {
            ButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell" forIndexPath:indexPath];
            return cell;
        }
            break;

        default:
            return nil;
            break;
    }

}




- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return self.collectionViewArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GroupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];

    cell.customImageView.image = self.collectionViewArray[indexPath.item];
    //    cell.customImageView.image = [UIImage imageNamed:@"textImage"];
    cell.backgroundColor = [UIColor blackColor];
    
    
    return cell;
}









@end
