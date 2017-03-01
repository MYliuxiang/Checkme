/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                Contains shared helper methods on HKHealthStore that are specific to Fit's use cases.
            
*/

#import "HKHealthStore+AAPLExtensions.h"

@implementation HKHealthStore (AAPLExtensions)

- (void)aapl_mostRecentQuantitySampleOfType:(HKQuantityType *)quantityType predicate:(NSPredicate *)predicate completion:(void (^)(HKQuantity *, NSError *))completion {
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    // Since we are interested in retrieving the user's latest sample, we sort the samples in descending order, and set the limit to 1. We are not filtering the data, and so the predicate is set to nil.
    
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType predicate:nil limit:1 sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results) {
            if (completion) {
                completion(nil, error);
            }
            
            return;
        }
        
        if (completion) {
            // If quantity isn't in the database, return nil in the completion block.
            HKQuantitySample *quantitySample = results.firstObject;
            HKQuantity *quantity = quantitySample.quantity;
            
            completion(quantity, error);
        }
    }];
    
    [self executeQuery:query];
       
     
    
    //*****************************  hjz   ******************************
    //运动数据
    //步数
    // Set your start and end date for your query of inter est
    
    /*
    NSDate *startDate, *endDate;
    
    // Use the sample type for step count
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create a predicate to set start/end date bounds of the query
    predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    
    // Create a sort descriptor for sorting by start date
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:YES];
    
    
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType
                                                                 predicate:predicate
                                                                     limit:HKObjectQueryNoLimit
                                                           sortDescriptors:@[sortDescriptor]
                                                            resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                                                
                                                                if(!error && results)
                                                                {
                                                                    for(HKQuantitySample *samples in results)
                                                                    {
                                                                        // your code here
                                                                    }
                                                                }
                                                                
                                                            }];
    
   
    [self executeQuery:sampleQuery];
*/
   //**************************  hjz  *********************************
    
}

@end
