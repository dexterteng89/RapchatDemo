//
//  BRBattleViewController.m
//  BattleRap
//
//  Created by Henry Dearborn on 4/20/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import "BRBattleViewController.h"
#import "BRRecordViewController.h"
#import "BRBattleViewCell.h"

@interface BRBattleViewController ()

@end

@implementation BRBattleViewController
@synthesize playing, audio;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        self.navigationItem.title = @"ME vs. @WesDearborn"; //link up to data here
        
        self.tableView.backgroundColor =
                [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
        self.tableView.opaque = NO;
        self.tableView.backgroundView = nil;
        self.tableView.separatorColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
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

    UIEdgeInsets inset = UIEdgeInsetsMake(9, 0, 0, 0);
    self.tableView.contentInset = inset;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //link to data to find out current round
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // dynamic based on data
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == [tableView numberOfSections] - 1 &&
        indexPath.row == 1) {
        //final cell becomes record a verse button
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"Record your verse!";
        cell.backgroundColor = [UIColor colorWithRed:255/255.0f
                                               green:256/255.0f
                                                blue:0/255.0f
                                               alpha:0.8f];;
        return cell;
    } else {
        //verse cells with playback button
        BRBattleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BRVerseCell"];
        
        if (cell == nil) {
            cell = [[BRBattleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BRVerseCell"];
        }
        
        cell.playButton.image = [UIImage imageNamed:@"PlayButton.png"];
        
        //need data to display who is challenger, who isn't    
        if (indexPath.row == 0) {
            cell.textLabel.text = @"My Verse";
        } else {
            cell.textLabel.text = @"@WesDearborn's Verse";
        }            
        return cell;
    }
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
    if (indexPath.section == [tableView numberOfSections] - 1 &&
        indexPath.row == 1) {
        //have final row open recordview
        BRRecordViewController *recordViewController =
        [[BRRecordViewController alloc] init];
        
        [recordViewController setDismissBlock:^{
            [self.tableView reloadData];
        }];
        
        UINavigationController *navController = [[UINavigationController alloc]
                                                 initWithRootViewController:recordViewController];
        
        [navController setModalPresentationStyle:UIModalPresentationFormSheet];
        
        [self presentViewController:navController animated:YES completion:nil];

        
    } else {
        BRBattleViewCell *cell = (BRBattleViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (!playing) {
            cell.playButton.image = [UIImage imageNamed:@"PauseButton.png"];
            playing = YES;
        } else if (playing) {
            cell.playButton.image = [UIImage imageNamed:@"PlayButton.png"];
            playing = NO;
        }     
        [self playVerseForRowAtIndexPath:indexPath];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *lbl = [[UILabel alloc] init];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.font = [UIFont fontWithName:@"Avenir-Medium" size:18];

    lbl.textColor = [UIColor blackColor];
    lbl.backgroundColor = [UIColor clearColor];

    if (section == 0) {
        lbl.text = @"ROUND I";
    } else if (section == 1) {
        lbl.text = @"ROUND II";
    } else if (section == 2) {
        lbl.text = @"ROUND III";
    }

    return lbl;
}


#pragma mark - Private Methods

- (void)playVerseForRowAtIndexPath:(NSIndexPath *)path
{
    if (playing) {
        //play
        //DATA - plug in sound file for row
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"verse" ofType:@"m4a"];
        audio = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath]
                                                       error:NULL];
        audio.delegate = self;
        [audio play];
        
    } else {
        //pause
        [audio pause];
        
    }
}


@end
