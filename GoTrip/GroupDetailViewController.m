//
//  GroupDetailViewController.m
//  GoTrip
//
//  Created by Andrew Liu on 11/23/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "GroupDetailViewController.h"
#import "Group.h"

@interface GroupDetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GroupDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


//MARK: delegate methods

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
////called after cellForRowAtIndexPath
//}

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
            cell = [tableView dequeueReusableCellWithIdentifier:@"descriptionCell"];

            if(!cell) {
                cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"descriptionCell"];
            }

            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"collectionCell"];

            if(!cell) {
                cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"colletionCell"];
            }
            break;
        case 2:
            // .. and so on for each section and cell
            break;
        default:
            break;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%d", arc4random_uniform(10) ];
    //TODO: cell
    return cell;
}




@end
