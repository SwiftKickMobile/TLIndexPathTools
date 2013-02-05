//
//  TLIndexPathDataModel.m
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

#import "TLIndexPathDataModel.h"
#import <CoreData/CoreData.h>
#import "TLIndexPathItem.h"

const NSString *TLIndexPathDataModelNilSectionName = @"__TLIndexPathDataModelNilSectionName__";

@interface TLSectionInfo : NSObject <NSFetchedResultsSectionInfo>
@property (nonatomic, readonly) NSString *indexTitle;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSUInteger numberOfObjects;
@property (nonatomic, readonly) NSArray *objects;
- (id)initWithSection:(NSInteger)section andObjects:(NSArray *)objects andName:(NSString *)name andIndexTitle:(NSString *)indexTitle;
@end

@interface TLIndexPathDataModel ()
@property (strong, nonatomic) NSMutableDictionary *rowCountBySection;
@property (strong, nonatomic) NSMutableDictionary *itemsByIdentifier;
@property (strong, nonatomic) NSMutableDictionary *sectionNamesBySection;
@property (strong, nonatomic) NSMutableDictionary *sectionsBySectionName;
@property (strong, nonatomic) NSMutableDictionary *identifiersByIndexPath;
@property (strong, nonatomic) NSMutableDictionary *indexPathsByIdentifier;
@end

@implementation TLIndexPathDataModel

@synthesize identifierKeyPath = _identifierKeyPath;
@synthesize sectionNameKeyPath = _sectionNameKeyPath;
@synthesize numberOfSections = _sectionCount;
@synthesize rowCountBySection = _rowCountBySection;
@synthesize itemsByIdentifier = _itemsByIdentifier;
@synthesize identifiersByIndexPath = _identifiersByIndexPath;
@synthesize indexPathsByIdentifier = _indexPathsByIdentifier;
@synthesize items = _items;
@synthesize sectionNames = _sectionNames;
@synthesize sections = _sections;

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    NSNumber *rowCount = [self.rowCountBySection objectForKey:[NSNumber numberWithInteger:section]];
    return rowCount.integerValue;
}

- (NSString *)sectionNameForSection:(NSInteger)section
{
    NSString *sectionName = [self.sectionNamesBySection objectForKey:[NSNumber numberWithInteger:section]];
    return sectionName;
}

- (NSInteger)sectionForSectionName:(NSString *)sectionName
{
    NSNumber *section = [self.sectionsBySectionName objectForKey:sectionName];
    return section ? section.integerValue : NSNotFound;
}

- (NSString *)sectionTitleForSection:(NSInteger)section
{
    NSString *sectionName = [self sectionNameForSection:section];
    if ([TLIndexPathDataModelNilSectionName isEqualToString:sectionName]) {
        return nil;
    }
    return sectionName;
}

- (id<NSFetchedResultsSectionInfo>)sectionInfoForSection:(NSInteger)section
{
    if (self.sections.count <= section) {
        return nil;
    }
    return self.sections[section];
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    id identifier = [self.identifiersByIndexPath objectForKey:indexPath];
    id item = [self.itemsByIdentifier objectForKey:identifier];
    return item;
}

- (BOOL)containsItem:(id)item
{
    return [self indexPathForItem:item] != nil;
}

- (NSIndexPath *)indexPathForItem:(id)item
{
    id identifier = [self identifierForItem:item];
    NSIndexPath *indexPath = [self.indexPathsByIdentifier objectForKey:identifier];
    return indexPath;
}

- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellIdentifierKeyPath) {
        id item = [self itemAtIndexPath:indexPath];
        return [item valueForKeyPath:self.cellIdentifierKeyPath];
    }
    return nil;
}

- (id)initWithIndexPathItems:(NSArray *)items
{
    return [self initWithItems:items andSectionNameKeyPath:TLIndexPathItemSectionName andIdentifierKeyPath:TLIndexPathItemIdentifier andCellIdentifierKeyPath:TLIndexPathItemCellIdentifier];
}

- (id)initWithItems:(NSArray *)items andSectionNameKeyPath:(NSString *)sectionNameKeyPath andIdentifierKeyPath:(NSString *)identifierKeyPath
{
    return [self initWithItems:items andSectionNameKeyPath:sectionNameKeyPath andIdentifierKeyPath:identifierKeyPath andCellIdentifierKeyPath:nil];
}

- (id)initWithItems:(NSArray *)items andSectionNameKeyPath:(NSString *)sectionNameKeyPath andIdentifierKeyPath:(NSString *)identifierKeyPath andCellIdentifierKeyPath:(NSString *)cellIdentifierKeyPath
{
    if (self = [super init]) {
        
        NSMutableArray *identifiedItems = [[NSMutableArray alloc] init];
        NSMutableArray *sectionNames = [[NSMutableArray alloc] init];
        NSMutableArray *sections = [[NSMutableArray alloc] init];
        
        _identifierKeyPath = identifierKeyPath;
        _sectionNameKeyPath = sectionNameKeyPath;
        _cellIdentifierKeyPath = cellIdentifierKeyPath;
        _rowCountBySection = [[NSMutableDictionary alloc] init];
        _sectionNamesBySection = [[NSMutableDictionary alloc] init];
        _sectionsBySectionName = [[NSMutableDictionary alloc] init];
        _itemsByIdentifier = [[NSMutableDictionary alloc] init];
        _identifiersByIndexPath = [[NSMutableDictionary alloc] init];
        _indexPathsByIdentifier = [[NSMutableDictionary alloc] init];
        _sectionNames = sectionNames;
        _sections = sections;
        _items = identifiedItems;
        
        NSInteger section = 0;
        NSInteger row = -1;
        NSString *previousSectionName;
        NSMutableArray *itemsForSection = [[NSMutableArray alloc] init];
        for (id item in items) {
            
            id identifier = [self identifierForItem:item];
            if (!identifier || [_itemsByIdentifier objectForKey:identifier]) continue;
            [identifiedItems addObject:item];
            
            row++;
            
            [_itemsByIdentifier setObject:item forKey:identifier];
            
            NSString *sectionName = [self sectionNameForItem:item];
            NSNumber *sectionNumber = [NSNumber numberWithInteger:section];
            if (previousSectionName && ![previousSectionName isEqualToString:sectionName]) {
                [_rowCountBySection setObject:[NSNumber numberWithInteger:row] forKey:[NSNumber numberWithInteger:section]];
                TLSectionInfo *sectionInfo = [[TLSectionInfo alloc] initWithSection:section andObjects:itemsForSection andName:previousSectionName andIndexTitle:previousSectionName];
                [sections addObject:sectionInfo];
                [sectionNames addObject:previousSectionName];
                [_sectionNamesBySection setObject:previousSectionName forKey:sectionNumber];
                [_sectionsBySectionName setObject:sectionNumber forKey:previousSectionName];
                section++;
                row = 0;
                itemsForSection = [[NSMutableArray alloc] init];
            }
            previousSectionName = sectionName;
            
            [itemsForSection addObject:item];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [_identifiersByIndexPath setObject:identifier forKey:indexPath];
            [_indexPathsByIdentifier setObject:indexPath forKey:identifier];
        }
        
        if (itemsForSection.count) {
            NSNumber *sectionNumber = [NSNumber numberWithInteger:section];
            TLSectionInfo *sectionInfo = [[TLSectionInfo alloc] initWithSection:section andObjects:itemsForSection andName:previousSectionName andIndexTitle:previousSectionName];
            [sections addObject:sectionInfo];
            [_rowCountBySection setObject:[NSNumber numberWithInteger:row+1] forKey:[NSNumber numberWithInteger:section]];
            if (previousSectionName) {
                [sectionNames addObject:previousSectionName];
                [_sectionNamesBySection setObject:previousSectionName forKey:sectionNumber];
                [_sectionsBySectionName setObject:sectionNumber forKey:previousSectionName];
            }
        }
        
        if (sections.count == 0) {
            [sections addObject:[[TLSectionInfo alloc] initWithSection:0 andObjects:nil andName:[TLIndexPathDataModelNilSectionName copy] andIndexTitle:nil]];
            [sectionNames addObject:TLIndexPathDataModelNilSectionName];
            [_sectionNamesBySection setObject:TLIndexPathDataModelNilSectionName forKey:@(0)];
            [_sectionsBySectionName setObject:@(0) forKey:TLIndexPathDataModelNilSectionName];            
        }
        
        _sectionCount = sections.count;
    }
    return self;}

- (id)identifierForItem:(id)item
{
    id identifier;
    if (self.identifierKeyPath) {
        identifier = [item valueForKeyPath:self.identifierKeyPath];
    } else {
        identifier = item;
    }
    return identifier;
}

- (id)itemForIdentifier:(id)identifier
{
    return [self.itemsByIdentifier objectForKey:identifier];
}

- (id)currentVersionOfItem:(id)anotherVersionOfItem
{
    id identifier = [self identifierForItem:anotherVersionOfItem];
    id item = [self itemForIdentifier:identifier];
    return item;
}

- (NSString *)sectionNameForItem:(id)item
{
    NSString *sectionName;
    if (self.sectionNameKeyPath) {
        sectionName = [item valueForKeyPath:self.sectionNameKeyPath];
    } else {
        sectionName = [TLIndexPathDataModelNilSectionName copy];
    }
    return sectionName;
}

@end

@implementation TLSectionInfo

@synthesize indexTitle = _indexTitle;
@synthesize name = _name;
@synthesize numberOfObjects = _numberOfObjects;
@synthesize objects = _objects;

- (id)initWithSection:(NSInteger)section andObjects:(NSArray *)objects andName:(NSString *)name andIndexTitle:(NSString *)indexTitle
{
    if (self = [super init]) {
        _objects = objects;
        _numberOfObjects = objects.count;
        _name = [name isEqualToString:[TLIndexPathDataModelNilSectionName copy]] ? nil : name;
        _indexTitle = indexTitle;
        
    }
    return self;
}

@end
