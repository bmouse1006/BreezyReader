//
//  RecFeedsDataSource.h
//  SmallReader
//
//  Created by Jin Jin on 10-10-31.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import "BaseReaderDataSouce.h"
#import "RecFeedsCell.h"

@interface RecFeedsDataSource : BaseReaderDataSouce {
	RecFeedsCell* _tempCell;
}

@property (nonatomic, assign) IBOutlet RecFeedsCell* tempCell;

@end
