//
//  SecondViewController.h
//  SprintDemo01
//
//  Created by Esteban Garro on 2015-12-03.
//  Copyright © 2015 Blabcake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestInterface.h"
#import "MainNotifier.h"

@interface SecondViewController : UIViewController <TestInterface, NotifierUpdater>

@property(nonatomic,strong) MainNotifier *broker;
@property(nonatomic,strong) IBOutlet UILabel *routineOutlet;
@property(nonatomic,strong) IBOutlet UITextView *requestOutlet;
@property(nonatomic,strong) IBOutlet UITextView *taskOutlet;

@end

