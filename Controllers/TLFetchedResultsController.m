//
//  TLFetchedResultsController.m
//  DealerCarStory
//
//  Created by Tim Moose on 5/17/13.
//
//

#import "TLFetchedResultsController.h"

@interface TLFetchedResultsController ()
@property (strong, nonatomic) dispatch_queue_t batchQueue;
@property (strong, nonatomic) NSLock *batchBarrier;
@property (strong, nonatomic) NSFetchedResultsController *backingController;
@property (strong, nonatomic, readonly) NSString *identifierKeyPath;
@end

@implementation TLFetchedResultsController

- (void)dealloc {
    //the delegate property is an 'assign' property
    //not technically needed because the FRC will dealloc when we do, but it's a good idea.
    self.backingController.delegate = nil;
}

#pragma mark - Initialization

- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath identifierKeyPath:(NSString *)identifierKeyPath cacheName:(NSString *)name
{    
    if (self = [super init]) {
        _backingController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:sectionNameKeyPath cacheName:name];
        _backingController.delegate = self;
        _batchQueue = dispatch_queue_create("tl-fetched-results-controller-queue", DISPATCH_QUEUE_SERIAL);
        _batchBarrier = [[NSLock alloc] init];        
    }
    return self;
}

#pragma mark - Fetching data

- (BOOL)performFetch:(NSError *__autoreleasing *)error
{
    BOOL result = [self.backingController performFetch:error];
    if (result) {
        NSArray *fetchedItems =  self.backingController.fetchedObjects;
        TLIndexPathDataModel *dataModel = [[TLIndexPathDataModel alloc] initWithItems:fetchedItems andSectionNameKeyPath:self.backingController.sectionNameKeyPath andIdentifierKeyPath:self.identifierKeyPath andCellIdentifierKeyPath:self.dataModel.cellIdentifierKeyPath];
        self.dataModel = dataModel;
    }
    return result;
}

#pragma mark - Configuration information

- (void)setFetchRequest:(NSFetchRequest *)fetchRequest
{
    // TODO
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    // TODO
}

- (NSString *)cacheName
{
    return self.backingController.cacheName;
}

+ (void)deleteCacheWithName:(NSString *)name
{
    [NSFetchedResultsController deleteCacheWithName:name];
}

- (NSString *)identifierKeyPath
{
    //fall back to objectID in case the data model doesn't have a value defined.
    NSString *identifierKeyPath = self.dataModel.identifierKeyPath ? self.dataModel.identifierKeyPath : @"objectID";
    return identifierKeyPath;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSArray *fetchedItems =  self.backingController.fetchedObjects;
    TLIndexPathDataModel *dataModel = [[TLIndexPathDataModel alloc] initWithItems:fetchedItems andSectionNameKeyPath:self.backingController.sectionNameKeyPath andIdentifierKeyPath:self.identifierKeyPath andCellIdentifierKeyPath:self.dataModel.cellIdentifierKeyPath];
    self.dataModel = dataModel;
}

- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName
{
    return sectionName;
}

@end
