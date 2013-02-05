//
//  TLNoResultsTableDataModel.m
//  Dart Meister
//
//  Created by Tim Moose on 1/4/13.
//
//

#import "TLNoResultsTableDataModel.h"
#import "TLIndexPathItem.h"

@implementation TLNoResultsTableDataModel

- (id)initWithRows:(NSInteger)rows blankCellId:(NSString *)blankCellId noResultsCellId:(NSString *)noResultsCellId noResultsText:(NSString *)noResultsText
{
    rows = MAX(rows, 1);
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:rows];
    for (NSInteger i = 0; i < rows; i++) {
        NSString *identifier = [NSString stringWithFormat:@"%d", i];
        if (i == rows-1) {
            TLIndexPathItem *item = [[TLIndexPathItem alloc] initWithIdentifier:identifier sectionName:nil cellIdentifier:noResultsCellId data:noResultsText];
            [items addObject:item];
        } else {
            TLIndexPathItem *item = [[TLIndexPathItem alloc] initWithIdentifier:identifier sectionName:nil cellIdentifier:blankCellId data:nil];
            [items addObject:item];
        }
    }
    return [self initWithIndexPathItems:items];
}

@end
