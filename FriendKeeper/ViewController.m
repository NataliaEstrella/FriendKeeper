//
//  ViewController.m
//  FriendKeeper
//
//  Created by Natalia Estrella on 5/18/16.
//  Copyright © 2016 Natalia Estrella. All rights reserved.
//

@import Contacts;
@import AddressBook;

#import "ViewController.h"
#import "VKSideMenu.h"
#import "ContactManager.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)

@interface ViewController () <VKSideMenuDelegate, VKSideMenuDataSource>

@property (nonatomic, strong) VKSideMenu *menuLeft;
@property (nonatomic) NSMutableArray *testArray;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;




@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self getContacts];
//    self.testArray = @[@"meow", @"dog", @"party"];
    self.testArray = [[NSMutableArray alloc] init];
    
    
    // Init default left-side menu with custom width
    self.menuLeft = [[VKSideMenu alloc] initWithWidth:220 andDirection:VKSideMenuDirectionLeftToRight];
    self.menuLeft.dataSource = self;
    self.menuLeft.delegate   = self;
    
    // Init custom right-side menu
    /* See more options in VKSideMenu.h */
        
    // Make stormtrooper image to be cool
    self.avatar.layer.cornerRadius  = self.avatar.frame.size.width * .5;
    self.avatar.layer.masksToBounds = YES;
    self.avatar.layer.borderColor   = [UIColor whiteColor].CGColor;
    self.avatar.layer.borderWidth   = 5.;
}

-(IBAction)buttonMenuLeft:(id)sender
{
    [self.menuLeft show];
}


#pragma mark - VKSideMenuDataSource

-(NSInteger)numberOfSectionsInSideMenu:(VKSideMenu *)sideMenu {
    return 1;
}

-(NSInteger)sideMenu:(VKSideMenu *)sideMenu numberOfRowsInSection:(NSInteger)section {
    
    return self.testArray.count;
}

-(VKSideMenuItem *)sideMenu:(VKSideMenu *)sideMenu itemForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // This solution is provided for DEMO propose only
    // It's beter to store all items in separate arrays like you do it in your UITableView's. Right?
    VKSideMenuItem *item = [VKSideMenuItem new];
    
    ContactManager *contactObject = self.testArray[indexPath.row];
    
    item.title = contactObject.name;
    
    return item;
}

#pragma mark - VKSideMenuDelegate

-(void)sideMenu:(VKSideMenu *)sideMenu didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"SideMenu didSelectRow: %@", indexPath);
}

-(void)sideMenuDidShow:(VKSideMenu *)sideMenu
{
    NSLog(@"%@ VKSideMenue did show", sideMenu == self.menuLeft ? @"LEFT" : @"RIGHT");
}

-(void)sideMenuDidHide:(VKSideMenu *)sideMenu
{
    NSLog(@"%@ VKSideMenue did hide", sideMenu == self.menuLeft ? @"LEFT" : @"RIGHT");
}


#pragma mark - Contact API Manager 
//To be placed eventually in its own manager file

-(void)getContacts {
    
CNContactStore *store = [[CNContactStore alloc] init];
[store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
    
    // make sure the user granted us access
    
    if (!granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // user didn't grant access;
            // so, again, tell user here why app needs permissions in order  to do it's job;
            // this is dispatched to the main queue because this request could be running on background thread
        });
        return;
    }
    
    // build array of contacts
    
    NSMutableArray *contacts = [NSMutableArray array];
    
    NSError *fetchError;
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactIdentifierKey, [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]]];
    
    BOOL success = [store enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact *contact, BOOL *stop) {
        [contacts addObject:contact];
    }];
    if (!success) {
        NSLog(@"error = %@", fetchError);
    }
    
    // you can now do something with the list of contacts, for example, to show the names
    
    CNContactFormatter *formatter = [[CNContactFormatter alloc] init];
    
    for (CNContact *contact in contacts) {
        ContactManager *object = [[ContactManager alloc] init];
        
        NSString *string = [formatter stringFromContact:contact];
        object.name = string;
        NSLog(@"object.name = %@", object.name);
        NSLog(@"contact = %@", string);
        
        [self.testArray addObject:object];
    }
}];
}

@end
