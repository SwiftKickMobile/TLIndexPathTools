//
//  TLIndexPathDataModel.h
//  TractableLabs
//
//  Created by Tim Moose on 07/16/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * TLIndexPathDataModelNilSectionName;

@interface TLIndexPathDataModel : NSObject
@property (strong, nonatomic, readonly) NSString *identifierKeyPath;
@property (strong, nonatomic, readonly) NSString *sectionNameKeyPath;
@property (strong, nonatomic, readonly) NSString *cellIdentifierKeyPath;
@property (nonatomic, readonly) NSInteger numberOfSections;
@property (strong, nonatomic, readonly) NSArray *sectionNames;
@property (strong, nonatomic, readonly) NSArray *sections;
@property (strong, nonatomic, readonly) NSArray *items;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString *)sectionNameForSection:(NSInteger)section;
- (NSInteger)sectionForSectionName:(NSString *)sectionName;
- (NSString *)sectionTitleForSection:(NSInteger)section;
- (id<NSFetchedResultsSectionInfo>)sectionInfoForSection:(NSInteger)section;
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)containsItem:(id)item;
- (NSIndexPath *)indexPathForItem:(id)item;
- (id)identifierForItem:(id)item;
- (id)itemForIdentifier:(id)identifier;
- (id)currentVersionOfItem:(id)anotherVersionOfItem;
- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)indexPath;
- (id)initWithItems:(NSArray *)items andSectionNameKeyPath:(NSString *)sectionNameKeyPath andIdentifierKeyPath:(NSString *)identifierKeyPath;
- (id)initWithItems:(NSArray *)items andSectionNameKeyPath:(NSString *)sectionNameKeyPath andIdentifierKeyPath:(NSString *)identifierKeyPath andCellIdentifierKeyPath:(NSString *)cellIdentifierKeyPath;
- (id)initWithIndexPathItems:(NSArray *)items;
@end
