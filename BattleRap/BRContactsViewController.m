//
//  BRContactsViewController.m
//  BattleRap
//
//  Created by Henry Dearborn on 4/20/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import "BRContactsViewController.h"
#import "BRRecordViewController.h"

@implementation BRContactsViewController
@synthesize dismissBlock, checkedIndexPath;

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        self.navigationItem.title = @"Battle with...";
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBattle)];
        
        self.navigationItem.leftBarButtonItem = cancelButton;
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

    self.tableView.tableFooterView = [[UIView alloc] init];
    [self doNSURLRequestThenparse];
}

- (void)doNSURLRequestThenparse
{
    NSString *stringAPICall = @"http://rapchat-staging.herokuapp.com/users";
    NSURLRequest* rapchatAPIRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringAPICall]];
    [NSURLConnection sendAsynchronousRequest:rapchatAPIRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^ void (NSURLResponse* myResponse, NSData* myData, NSError* theirError)
     {
          if((userHandles = [self parseDataWithResponse:myResponse andData:myData andError:theirError]) == nil)
          {
              NSLog(@"Some shit went wrong");
          }
         [self.tableView reloadData];
     }];
}

- (id)parseDataWithResponse:(NSURLResponse*)myResponse andData:(NSData*)myData andError:(NSError*)theirError
{
    
    if (theirError)
    {
        NSLog(@"RapChatAPIError: %@", [theirError description]);
        return nil;
    }
    else
    {
        NSError *jsonError;
        NSArray *arrayFromJSON = (NSArray *)[NSJSONSerialization JSONObjectWithData:myData
                                                                            options:NSJSONReadingAllowFragments
                                                                              error:&jsonError];
        return arrayFromJSON;
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
   if (userHandles != nil)
   {
       return userHandles.count;
   }
   else
   {
       return 0;
   }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
//    if (indexPath.row == 0) {
//        cell.textLabel.text = @"Brian";
//    } else if (indexPath.row == 1) {
//        cell.textLabel.text = @"Dexter";
//    } else if (indexPath.row == 2) {
//        cell.textLabel.text = @"James";
//    }
    
    cell.textLabel.text = [[userHandles objectAtIndex:[indexPath row]] valueForKey:@"handle"];
    
    if ([self.checkedIndexPath isEqual:indexPath])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    BRRecordViewController *recordViewController = [[BRRecordViewController alloc] init];
    
    //DATA - set opponent propert of newly created battle object
    //set accessory to checkmark by listening for updates to model
    
    if(self.checkedIndexPath)
    {
        UITableViewCell* uncheckCell = [tableView
                                        cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.checkedIndexPath = indexPath;
    
    
    recordViewController.dismissBlock = dismissBlock;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Contacts" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.navigationController pushViewController:recordViewController animated:YES];
}

#pragma mark - Private Methods

- (void)cancelBattle
{
    //code for setting battle object data to nil
    
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:dismissBlock];
}

@end
