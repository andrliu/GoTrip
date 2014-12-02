//
//  GroupDetailViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "GroupDetailViewController.h"
#import "Group.h"
#import "Photo.h"
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

    PFQuery *photoQuery = [Photo query];
    [photoQuery whereKey:@"group" equalTo:self.group];
    [photoQuery orderByDescending:@"createdAt"];
    [photoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error)
         {
             [self errorAlertWindow:error.localizedDescription];
         }
         else
         {
             self.collectionViewArray = objects;
         }
     }];

    //TODO: clean that stuff. For testing only

    //    UIImage *image1 = [UIImage imageNamed:@"minsk"];
    //    UIImage *image2 = [UIImage imageNamed:@"portland"];
    //    UIImage *image3 = [UIImage imageNamed:@"sanfrancisco"];
    //    UIImage *image4 = [UIImage imageNamed:@"chicago"];
    //    self.collectionViewArray = @[image1,image2,image3,image4];

    self.navigationItem.title = self.group.name;
    self.aString = self.group.memo;
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
            theFloat =  44.0;
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
            return 3;
            break;

        default:
            return 0;
            break;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"Group description";
            break;
        case 1:
            return @"Uploaded images";
            break;
            //        case 2:
            //            return @"Control";
            //            break;

        default:
            return nil;
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

            switch (indexPath.row)
            {
                case 0:
                    [cell.button setTitle:@"Join group" forState:UIControlStateNormal];
//                    [cell.button.layer setCornerRadius:15];
                    break;

                case 1:
                    [cell.button setTitle:@"Report group" forState:UIControlStateNormal];
                    [cell.button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//                    [cell.button.layer setCornerRadius:15];
                    break;
                case 2:
                    [cell.button setHidden:YES];
                    break;

                default:
                    return nil;
                    break;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //            cell.backgroundColor = [UIColor colorWithRed:230.0/250.0 green:230.0/250.0 blue:230.0/250.0 alpha:0.5f];

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

    Photo *photoObj = self.collectionViewArray[indexPath.item];
    PFFile *imageFile = photoObj.imageData;
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (error)
         {
             [self errorAlertWindow:error.localizedDescription];
         }
         else
         {
             cell.customImageView.image = [UIImage imageWithData:data];
             cell.backgroundColor = [UIColor blackColor];

         }

     }];

    //    cell.customImageView.image = self.collectionViewArray[indexPath.item];
    //    cell.customImageView.image = [UIImage imageNamed:@"textImage"];
    cell.backgroundColor = [UIColor blackColor];

    return cell;
}


-(void)errorAlertWindow:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Ahtung!" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"😭 Mkay..." style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}



@end
