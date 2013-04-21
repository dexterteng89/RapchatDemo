//
//  BRListViewController.m
//  BattleRap
//
//  Created by Henry Dearborn on 4/20/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import "BRListViewController.h"
#import "BRContactsViewController.h"
#import "BRBattleViewController.h"
#import "BRLoginViewController.h"
#import "BRBattleStore.h"

@interface BRListViewController ()
{
    BRBattleStore *battleStore;
    NSArray *theUsers;
    NSArray *theBattles;
}
@end

@implementation BRListViewController


- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        self.navigationItem.title = @"RapChat";
        
        UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createBattle)];
        
        self.navigationItem.rightBarButtonItem = createButton;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    battleStore = [BRBattleStore sharedStore];
    battleStore.delegate = self;
    [self refreshData];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView reloadData];

}

- (void)refreshData
{
    [battleStore populateUsers];
    [battleStore populateBattles];
}

- (void) usersDidFinishPostingUsers:(NSMutableArray *)users
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults integerForKey:@"id"] == NAN) {
        NSString *name = [defaults objectForKey:@"handle"];
        NSArray *theUser = [NSArray arrayWithObjects: @"handle",nil];
        NSDictionary *me = [users dictionaryWithValuesForKeys:theUser];
        NSArray *orderedHandles = [me objectForKey:@"handle"];
        for (int i = 0; i < orderedHandles.count; i++)
        {
            if ([[orderedHandles objectAtIndex:i] isEqual:name])
            {
                
                [defaults setInteger:[[[users objectAtIndex:i] valueForKey:@"id"] integerValue]  forKey:@"id"];
                
                break;
            }
        }
    }
    theUsers = (NSArray *)users;
}

- (void)usersDidFinishPostingBattles:(NSMutableArray *)battles
{
    theBattles = (NSArray *)battles;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //login verification
    BRLoginViewController *lvc = [[BRLoginViewController alloc] init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"handle"] == nil) {
        
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self setModalPresentationStyle:UIModalPresentationFormSheet];
            [self presentViewController:lvc animated:NO completion:nil];
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (theBattles != nil)
    {
        return theBattles.count;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // placeholder configuration
//    if (indexPath.row == 0) {
//        cell.textLabel.text = @"Me VS. Brian";
//        cell.detailTextLabel.text = @"Round 2 - Your Turn!";
//    } else if (indexPath.row == 1) {
//        cell.textLabel.text = @"Scott VS. Me";
//        cell.detailTextLabel.text = @"Round 3 - Scott's Turn!";
//    }
    
    //Each cell is a battle with a user_id VS friend_id
    //numbers from id correlate to the cell in theUsers
    
    int friend_id = [[[theBattles objectAtIndex:[indexPath row]] valueForKey:@"friend_id"] integerValue] - 1;
    
    int user_id = [[[theBattles objectAtIndex:[indexPath row]] valueForKey:@"user_id"] integerValue] - 1;
    
    NSString *rapResponder = [[theUsers objectAtIndex:friend_id] valueForKey:@"handle"];
    NSString *rapStarter = [[theUsers objectAtIndex:user_id] valueForKey:@"handle"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ VS %@", rapStarter, rapResponder];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

     BRBattleViewController *battleViewController = [[BRBattleViewController alloc] init];

     self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Home"
                                                      style:UIBarButtonItemStylePlain
                                                     target:nil
                                                     action:nil];
    
     [self.navigationController pushViewController:battleViewController animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - Private Methods
- (void)createBattle
{
    //create new battle item in mode
//    ...
    
    BRContactsViewController *contactsViewController =
                        [[BRContactsViewController alloc] init];
    
    [contactsViewController setDismissBlock:^{
        [self.tableView reloadData];
    }];
    
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:contactsViewController];
    
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];

    [self presentViewController:navController animated:YES completion:nil];
}

@end

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */
