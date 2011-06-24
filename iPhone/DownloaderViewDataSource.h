//
//  DownloaderViewDataSource.h
//  BreezyReader
//
//  Created by Jin Jin on 10-8-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseReaderDataSouce.h"
#import "DownloaderViewCell.h"


@interface DownloaderViewDataSource : BaseReaderDataSouce<UITableViewDataSource, DownloaderViewCellDelegate> {

}

-(void)refresh;

@end
