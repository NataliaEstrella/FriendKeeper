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
#import "DGActivityIndicatorView.h"


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)

@interface ViewController () <VKSideMenuDelegate, VKSideMenuDataSource>

@property (nonatomic, strong) VKSideMenu *menuLeft;
@property (nonatomic) NSMutableArray *testArray;
@property (nonatomic) DGActivityIndicatorView *loadingView;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *outerImageCircle;

@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self startLoading];
    self.testArray = [[NSMutableArray alloc] init];
    [self getContacts];
    
    // Init default left-side menu with custom width
    self.menuLeft = [[VKSideMenu alloc] initWithWidth:220 andDirection:VKSideMenuDirectionLeftToRight];
    self.menuLeft.dataSource = self;
    self.menuLeft.delegate   = self;
    
}

-(IBAction)buttonMenuLeft:(id)sender {
    [self.menuLeft show];
    [self stopLoading];
}


#pragma mark - VKSideMenuDataSource

-(NSInteger)numberOfSectionsInSideMenu:(VKSideMenu *)sideMenu {
    return 1;
}

-(NSInteger)sideMenu:(VKSideMenu *)sideMenu numberOfRowsInSection:(NSInteger)section {
    
    return self.testArray.count;
}

-(VKSideMenuItem *)sideMenu:(VKSideMenu *)sideMenu itemForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    VKSideMenuItem *item = [VKSideMenuItem new];
    ContactManager *contactObject = self.testArray[indexPath.row];
    item.title = contactObject.name;
    
    return item;
}



#pragma mark - Contact API Manager 
//To be placed eventually in its own manager file with a data block and completion handler

-(void)getContacts {
    
CNContactStore *store = [[CNContactStore alloc] init];
[store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
    
    // make sure the user granted us access
    
    if (!granted) {
        dispatch_async(dispatch_get_main_queue(), ^{

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
    
    
    CNContactFormatter *formatter = [[CNContactFormatter alloc] init];
    
    for (CNContact *contact in contacts) {
        ContactManager *object = [[ContactManager alloc] init];

       
//         NSArray<CNLabeledValue<CNPhoneNumber*>*> *phoneString = contact.phoneNumbers;
//        object.phoneNumber = phoneString;
//        NSLog(@"number = %@", phoneString);
        
        NSString *name = [formatter stringFromContact:contact];
        object.name = name;
        NSLog(@"contact = %@", name);
        
//        NSData *data = contact.imageData;
//        object.image = data;
        
        [self.testArray addObject:object];
    }
}];
    
}

- (void)startLoading {
    
    DGActivityIndicatorView *activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeTriangleSkewSpin tintColor:[UIColor colorWithRed:239.0/255.0 green:29.0/255.0 blue:29.0/255.0 alpha:1.0]];
    CGFloat width = self.view.bounds.size.width / 20.0f;
    CGFloat height = self.view.bounds.size.height / 20.0f;
    
    activityIndicatorView.frame = CGRectMake(0, 0, width, height);
    [self.view addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    [activityIndicatorView setCenter:self.view.center];
    
    self.loadingView = activityIndicatorView;
    [self.navigationController setNavigationBarHidden:YES];
    [self.outerImageCircle setHidden:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stopLoading];
        [UIView animateWithDuration:.5
                         animations:^{
                             [self.navigationController setNavigationBarHidden:NO];
                         }];
        
    });
}

- (void)stopLoading {

    [self.loadingView stopAnimating];
    [self.outerImageCircle setHidden:NO];
    self.loadingView.alpha = 0;
}

#pragma mark - VKSideMenuDelegate

-(void)sideMenu:(VKSideMenu *)sideMenu didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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



@end
