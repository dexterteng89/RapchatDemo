//
//  BRLoginViewController.m
//  BattleRap
//
//  Created by Henry Dearborn on 4/20/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import "BRLoginViewController.h"

@interface BRLoginViewController ()

@end

@implementation BRLoginViewController
@synthesize usernameField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"LoginView" bundle:nil];
    if (self) {
        usernameField.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:usernameField.text forKey:@"handle"];
    [defaults synchronize];
    [self postUserInformation];
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (void)postUserInformation
{
    NSString *userHandle = [[NSUserDefaults standardUserDefaults] objectForKey:@"handle"];
    
    NSDictionary *postDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:userHandle, @"handle", nil];
    
    NSError *error;
    
    NSData *file1Data = [NSJSONSerialization dataWithJSONObject:postDictionary options:0 error:&error];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://rapchat-staging.herokuapp.com/users"]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [file1Data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: file1Data];
    
    [NSURLConnection connectionWithRequest:request delegate:self];

}

#pragma mark - UITextViewDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [usernameField resignFirstResponder];
    return YES;
}

@end
