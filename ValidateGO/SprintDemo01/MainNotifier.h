//
//  MainNotifier.h
//  SprintDemo01
//
//  Created by Esteban Garro on 2015-12-03.
//  Copyright © 2015 Blabcake. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NotifierUpdater;

@interface MainNotifier : NSObject <GoGostressedNotifier>

@property(nonatomic, weak) id<NotifierUpdater>delegate;
@property(nonatomic, strong) NSString *acc;

@end

@protocol NotifierUpdater <NSObject>
-(void)notifierRegisteredChange:(MainNotifier *)sender;
@end
