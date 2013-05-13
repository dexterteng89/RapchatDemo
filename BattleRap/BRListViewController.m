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
#import "BRUser.h"
#import "BRHTTPClient.h"

@interface BRListViewController ()
{
    BRBattleStore *battleStore;
    NSArray *theUsers;
    NSArray *theBattles;
}
- (void)createBattle;
- (void)refreshData;
@end

@implementation BRListViewController


- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        self.navigationItem.title = @"PASS THE MIC";
        
        UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createBattle)];
        
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStyleBordered target:self action:@selector(logout:)];
        
        self.navigationItem.rightBarButtonItem = createButton;
        self.navigationItem.leftBarButtonItem = logoutButton;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    battleStore = [BRBattleStore sharedStore];
    battleStore.delegate = self;
    [self refreshData];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //login verification
    [self checkForUser];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self refreshData];
    [self.tableView reloadData];
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
        return theBattles.count;
    else
        return 0;
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
    
    //Each cell is a battle with a user_id VS friend_id
    //numbers from id correlate to the cell in theUsers
    
    NSNumber *friend_id = [NSNumber numberWithInt:[[[theBattles objectAtIndex:[indexPath row]] valueForKey:@"friend_id"] integerValue]];
    
    NSNumber *user_id = [NSNumber numberWithInt:[[[theBattles objectAtIndex:[indexPath row]] valueForKey:@"user_id"] integerValue]];
    
    NSString* rapStarter;
    NSString* rapResponder;
    
    for (NSDictionary *newDict in theUsers)
    {
        if ([[newDict objectForKey:@"id"] isEqual:user_id] )
        {
            rapStarter = [newDict valueForKey:@"handle"];
        }
        
        
        if ([[newDict objectForKey:@"id"] isEqual:friend_id]) {
            rapResponder = [newDict valueForKey:@"handle"];
        }
    }
    
    
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

#pragma mark - Battle Store Delegate Methods

- (void) usersDidFinishPostingUsers:(NSMutableArray *)users
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults integerForKey:@"id"]) {
        //NSString *name = [defaults objectForKey:@"handle"];
        //NSArray *theUser = [NSArray arrayWithObjects: @"handle",nil];
        //NSDictionary *me = [users dictionaryWithValuesForKeys:theUser];
        //NSArray *orderedHandles = [me objectForKey:@"handle"];
        [defaults setInteger:23 forKey:@"id"];
        
        //        for (int i = 0; i < orderedHandles.count; i++)
        //        {
        //            if ([[orderedHandles objectAtIndex:i] isEqual:name])
        //            {
        //
        //                [defaults setInteger:[[[users objectAtIndex:i] valueForKey:@"id"] integerValue]  forKey:@"id"];
        //                [defaults synchronize];
        //                [battleStore populateBattles];
        //                [self.tableView reloadData];
        //                break;
        //            }
        //        }
    }
    [battleStore populateBattles];
    [self.tableView reloadData];
    theUsers = (NSArray *)users;
}

- (void)usersDidFinishPostingBattles:(NSMutableArray *)battles
{
    theBattles = (NSArray *)battles;
    [self.tableView reloadData];
}


#pragma mark - Private Methods

- (void)createBattle
{
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

- (void)checkForUser
{
    if (![[BRUser currentUser] authToken]) {
        
        BRLoginViewController *loginViewController = [[BRLoginViewController alloc] init];
        
        [self setModalPresentationStyle:UIModalPresentationFormSheet];
        [self presentViewController:loginViewController animated:NO completion:nil];
    }
}

- (void)refreshData
{
    [battleStore populateUsers];
    [self.tableView reloadData];
}

- (void)logout:(id)sender
{
    [[BRHTTPClient sharedClient] signOutWithSuccess:^(AFJSONRequestOperation *operation, id responseObject) {
        NSLog(@"Signout successful");
        
        [self checkForUser];
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        NSLog(@"Signout failed");
    }];
}


@end
