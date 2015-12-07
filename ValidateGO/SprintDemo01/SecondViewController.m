//
//  SecondViewController.m
//  SprintDemo01
//
//  Created by Esteban Garro on 2015-12-03.
//  Copyright © 2015 Blabcake. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController () {
    dispatch_queue_t httpQueue;
}

@end

@implementation SecondViewController

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    httpQueue = dispatch_queue_create("HTTP Queue",NULL);

    self.routineOutlet.text = @"";
    self.requestOutlet.text = @"";
    self.taskOutlet.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)startTest:(id)sender {
    [self logToTaskLog:@"Starting test..."];
    [self backgroundRoutine];
    [self performGETRequest];
    [self performPOSTRequest];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        [self writeToFile];
        __block NSString *fileContents = [self readFromFile];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self logToRequestLog:fileContents];
        });
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        [self sortFixedList];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        [self generateAndSortList];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        __block NSString *hash = [self hashImageFile];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self logToRequestLog:hash];
        });
    });
}

-(void)logToTaskLog:(NSString *)str {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.taskOutlet.text = [self.taskOutlet.text stringByAppendingFormat:@"\n%@",str];
    });
}

-(void)logToRequestLog:(NSString *)str {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.requestOutlet.text = [self.requestOutlet.text stringByAppendingFormat:@"\n%@",str];
    });
}

#pragma mark NotiferUpdater Methods
-(void)notifierRegisteredChange:(MainNotifier *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.routineOutlet.text = sender.acc;
    });
}

#pragma mark TestInterface Methods

-(void)backgroundRoutine {
    [self logToTaskLog:@"Executing background routine"];
    _broker = [[MainNotifier alloc] init];
    _broker.delegate = self;
    //GoGostressedRunGoRoutine();
    GoGostressedRunGoRoutine(_broker);
}

-(BOOL)writeToFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"randomFile.txt"];
    
    NSDate *start = [NSDate date];
    if (GoGostressedWriteToFile(filePath)) {
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
        [self logToTaskLog:[NSString stringWithFormat:@"Writing file execution Time: %f", executionTime]];
        return YES;
    } else {
        [self logToTaskLog:@"GO generated an error while writing file"];
        return NO;
    }
}

-(NSString *)readFromFile {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"BlabCake" ofType:@"txt"];
    NSDate *start = [NSDate date];
    NSString *resp = GoGostressedReadFromFile(filePath);
    if (![resp isEqualToString:@""]) {
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
        [self logToTaskLog:[NSString stringWithFormat:@"Reading file execution Time: %f", executionTime]];
        return resp;
    }
    
    return @"ERROR READING FILE with GO :(:(";
}

-(void)performGETRequest {
    dispatch_async(httpQueue, ^{
        __block NSString *site = GoGostressedHTTPGetCall();
        dispatch_async(dispatch_get_main_queue(), ^{
            [self logToRequestLog:site];
        });
    });
}

-(void)performPOSTRequest {
    dispatch_async(httpQueue, ^{
        __block NSString *site = GoGostressedHTTPPostCall();
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (site) {
                    [self logToRequestLog:@"POST Request Completed!"];
            } else {
                [self logToTaskLog:@"Error processing post request. Empty response!"];
            }
        });
    });
}

-(BOOL)sortFixedList {
    BOOL resp = NO;
    
    NSDate *start = [NSDate date];
        resp = GoGostressedSortFixedList();
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
    [self logToTaskLog:[NSString stringWithFormat:@"Time sorting a fixed list: %f", executionTime]];
    
    return resp;
}

-(BOOL)generateAndSortList {
    BOOL resp = NO;
    
    NSDate *start = [NSDate date];
        resp = GoGostressedGenerateAndSort();
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
    [self logToTaskLog:[NSString stringWithFormat:@"Time generating and sorting a list: %f", executionTime]];
    
    return resp;
}

-(NSString *)hashImageFile {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Yosemite" ofType:@"png"];
    NSDate *start = [NSDate date];
        NSString *resp = GoGostressedHashFile(filePath);
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
    [self logToTaskLog:[NSString stringWithFormat:@"Time hashing file: %f", executionTime]];

    return resp;
}


@end
