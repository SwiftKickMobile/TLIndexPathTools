//
//  TLNoResultsTableDataModel.h
//  Dart Meister
//
//  Created by Tim Moose on 1/4/13.
//
//

#import "TLIndexPathDataModel.h"

@interface TLNoResultsTableDataModel : TLIndexPathDataModel
@property (nonatomic, readonly) NSInteger rows;
@property (strong, nonatomic, readonly) NSString *blankCellIdentifier;
@property (strong, nonatomic, readonly) NSString *noResultsCellIdentifier;
@property (strong, nonatomic, readonly) NSString *noResultsText;
- initWithRows:(NSInteger)rows blankCellId:(NSString *)blankCellId noResultsCellId:(NSString *)noResultsCellId noResultsText:(NSString *)noResultsText;
@end
