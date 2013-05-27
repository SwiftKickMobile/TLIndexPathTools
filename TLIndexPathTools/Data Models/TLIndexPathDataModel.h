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
 TODO
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * TLIndexPathDataModelNilSectionName;

@interface TLIndexPathDataModel : NSObject
@property (strong, nonatomic) NSString *title;
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
- (id)identifierAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)containsItem:(id)item;
- (NSIndexPath *)indexPathForItem:(id)item;
- (NSIndexPath *)indexPathForIdentifier:(id)identifier;
- (id)identifierForItem:(id)item;
- (id)itemForIdentifier:(id)identifier;
- (id)currentVersionOfItem:(id)anotherVersionOfItem;
- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)indexPath;
- (id)initWithItems:(NSArray *)items andSectionNameKeyPath:(NSString *)sectionNameKeyPath andIdentifierKeyPath:(NSString *)identifierKeyPath;
- (id)initWithItems:(NSArray *)items andSectionNameKeyPath:(NSString *)sectionNameKeyPath andIdentifierKeyPath:(NSString *)identifierKeyPath andCellIdentifierKeyPath:(NSString *)cellIdentifierKeyPath;
- (id)initWithIndexPathItems:(NSArray *)items;
- (id)initWithSectionInfos:(NSArray *)sectionInfos andIdentifierKeyPath:(NSString *)identifierKeyPath andCellIdentifierKeyPath:(NSString *)cellIdentifierKeyPath;
- (id)initWithIndexPathItemSectionInfos:(NSArray *)sectionInfos;
@end
