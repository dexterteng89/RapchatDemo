//
//  BRBattleStore.m
//  BattleRap
//
//  Created by Dexter Teng on 4/20/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import "BRBattleStore.h"

@implementation BRBattleStore

+ (BRBattleStore *)sharedStore
{
    static BRBattleStore *sharedStore = nil;
    if (!sharedStore)
    {
        sharedStore = [[super allocWithZone:nil] init];
    }
    
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)createBattleWith:(NSString *)friendName
{
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:@"id"];
    
    NSDictionary *postDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"nil", @"category",userid,@"user_id",friendName,@"friend_handle", nil];
    
    NSError *error;
    
    NSData *file1Data = [NSJSONSerialization dataWithJSONObject:postDictionary options:0 error:&error];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://rapchat-staging.herokuapp.com/battles"]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [file1Data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: file1Data];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

//- (void)updateBattleWith:(NSInteger)battleID andWith:(BRVerse *)verse
//{
//    
//}


- (void)populateBattlesWithArray:(NSMutableArray *)data
{
    battles = data;
}

- (void)populateUsers
{
    NSString *stringAPICall = @"http://rapchat-staging.herokuapp.com/users";
    NSURLRequest* rapchatAPIRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringAPICall]];
    [NSURLConnection sendAsynchronousRequest:rapchatAPIRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^ void (NSURLResponse* myResponse, NSData* myData, NSError* theirError)
     {
         //begin parse method
         users = [self parseDataWithResponse:myResponse andData:myData andError:theirError];
         [self.delegate usersDidFinishPostingUsers:users];
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

- (NSMutableArray *)getUsers
{
    return users;
}

- (void)populateBattles
{
    int rap_id = [[NSUserDefaults standardUserDefaults] integerForKey:@"id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *stringAPICall = [NSString stringWithFormat:@"http://rapchat-staging.herokuapp.com/users/%i/battles", rap_id];
    NSURLRequest* rapchatAPIRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringAPICall]];
    [NSURLConnection sendAsynchronousRequest:rapchatAPIRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^ void (NSURLResponse* myResponse, NSData* myData, NSError* theirError)
     {
         //begin parse method
         battles = [self parseDataWithResponse:myResponse andData:myData andError:theirError];
         [self.delegate usersDidFinishPostingBattles:battles];
     }];
}

- (NSMutableArray *)getBattles
{
    return battles;
}

@end
