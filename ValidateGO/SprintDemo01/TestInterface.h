//
//  TestInterface.h
//  GO-Stressed
//
//  Created by Esteban Garro on 2015-12-03.
//  Copyright © 2015 Blabcake. All rights reserved.
//

@protocol TestInterface <NSObject>

-(void)backgroundRoutine;
-(BOOL)writeToFile;
-(NSString *)readFromFile;
-(void)performGETRequest;
-(void)performPOSTRequest;
-(BOOL)sortFixedList;
-(BOOL)generateAndSortList;
-(NSString *)hashImageFile;

@end
