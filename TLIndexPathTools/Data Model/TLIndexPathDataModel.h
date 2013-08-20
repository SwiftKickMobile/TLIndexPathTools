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

 ITEM IDENTIFICATION RULES:
 
 TLIndexPathDataModel needs to be able to identify items in order to keep an internal
 mapping between items and index paths and to track items across versions of the data
 model. It does not assume that the item itself is a valid identifier (for example,
 if the item doesn not implement `NSCopying`, it cannot be used as a dictionary key).
 So the following set of rules are used to locate a valid identifier. Each rule
 is tried in turn until a non-nil value is found:
 
 1. If `identifierKeyPath` is specified (through an appropriate initializer),
    the data model attempts to use the item's value for this key path. If the key
    path is invalid for the given item, the next rule is tried.
 2. If the item is an instance of `TLIndexPathItem`, the value of the `identifier`
    property is tried.
 3. If the item is an instance of `NSManagedObject`, the `objectID` property is used.
 4. If the item conforms to `NSCopying`, the item itself is used.
 5. If all else fails, the item's memory address is returned as a string.

 SECTION NAME IDENTIFICATION RULES:
 
 1. If `sectionNameKeyPath` is specified (through the appropriate initializer),
    the data model attempts to use the item's value for this key path. If the key
    path is invalid for the given item, the next rule is tried.
 2. If the item is an instance of `TLIndexPathItem`, the value of the `sectionName`
    property is tried.
 3. The value TLIndexPathDataModelNilSectionName is used.
 
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

extern NSString * TLIndexPathDataModelNilSectionName;

@interface TLIndexPathDataModel : NSObject

/**
 The basic initializer.
 
 This initializer can only organize data into a single section and use the default
 item identification rules. Use one of the other initializers if you need multiple
 sections or need to specify an `identifierKeyPath`. An exception to this if your
 items are instance of the `TLIndexPathItem` wrapper class since the data model is
 aware of, and will make use of the buit in `identifier` and `sectionName` properties.
 
 @param items  the itmes that make up the data model
 */
- (id)initWithItems:(NSArray *)items;

/**
 Use this initializer to organize sections by the item `sectionNameKeyPath` property
 or to identify items by their `identifierKeyPath` property.
 
 @param items  the itmes that make up the data model
 @param sectionNameKeyPath  the item key path to use for orgnizing data into sections.
        Note that items do not need to be pre-sorted by sectionNameKeyPath. Specifying `nil`
        will result in a single section named `TLIndexPathDataModelNilSectionName`.
 @param identifierKeyPath  the item key path to use for identification. Specifying `nil`
        will result in the default object identification rules being used.
 */
- (id)initWithItems:(NSArray *)items sectionNameKeyPath:(NSString *)sectionNameKeyPath identifierKeyPath:(NSString *)identifierKeyPath;

/**
 Use this initializer to explicitly specify sections by providing an array of
 `TLIndexPathSectionInfo` objects. This initializer can be used to generate empty sections
 (by creating an empty `TLIndexPathSectionInfo` object).

 @param sectionInfos  the section info objects that make up the data model
 @param identifierKeyPath  the item key path to use for identification. Specifying `nil`
 will result in the default object identification rules being used.
*/
- (id)initWithSectionInfos:(NSArray *)sectionInfos identifierKeyPath:(NSString *)identifierKeyPath;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic, readonly) NSString *identifierKeyPath;
@property (strong, nonatomic, readonly) NSString *sectionNameKeyPath;
@property (nonatomic, readonly) NSInteger numberOfSections;
@property (strong, nonatomic, readonly) NSArray *sectionNames;
@property (strong, nonatomic, readonly) NSArray *sections;
@property (strong, nonatomic, readonly) NSArray *items;
@property (strong, nonatomic, readonly) NSArray *indexPaths;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString *)sectionNameForSection:(NSInteger)section;
- (NSInteger)sectionForSectionName:(NSString *)sectionName;
- (NSString *)sectionTitleForSection:(NSInteger)section;
- (id<NSFetchedResultsSectionInfo>)sectionInfoForSection:(NSInteger)section;
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
- (id)identifierAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)containsItem:(id)item;
- (NSIndexPath *)indexPathForItem:(id)item;
- (NSIndexPath *)indexPathForIdentifier:(id)identifier;
- (id)identifierForItem:(id)item;
- (id)itemForIdentifier:(id)identifier;
- (id)currentVersionOfItem:(id)anotherVersionOfItem;
@end
