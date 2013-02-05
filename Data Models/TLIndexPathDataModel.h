//
//  TLIndexPathDataModel.h
//
//  Copyright (c) 2013 Tim Moose (http://tractablelabs.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

/**
 A data model for building NSIndexPath-based components, such as UITableView
 and UICollectionView controllers. The main benefit of using TLIndexPathDataModel
 is that it greatly simplifies managing dyncamically changing tables while ensuring
 smooth animation between states.
 
 TLIndexPathDataModelUpdates takes two instandes of TLIndexPathDataModel, computes
 the changes, and provides methods for applying the changes to a UITableView
 or UICollectionView as a batch update with smooth animations.
 
 TLTableViewController is a base table view controller provided for quickly
 integrating TLIndexPathDataModel into a project.
 
 TLInMemoryFetchedResultsController is a subclass of NSFetchedResultsController
 that uses TLIndexPathDataModel internally to provide in-memory filtering and
 sorting against the base Core Data fetch result with smooth animations
 (which NSFetchedResultsController can't do).
 
 TLIndexPathItem can be used as the item class TLIndexPathDataModel. It has
 customizable identifier, sectionName, and cellIdentifier properties that
 TLIndexPathDataModel can use to manage the table. TLIndexPathItem is typically
 used when the table has heterogeneous rows (multiple cell or data types).
 */

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
