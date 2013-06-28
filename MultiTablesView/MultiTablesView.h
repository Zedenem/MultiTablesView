//
//  MultiTablesView.h
//  MultiTablesView
//
//  Created by Zouhair on 20/06/13.
//  Copyright (c) 2013 Zedenem. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MultiTablesView;


/** @name MultiTablesViewDataSource protocol */
#pragma mark - MultiTablesViewDataSource protocol
@protocol MultiTablesViewDataSource <NSObject>

@optional
/** @name Levels */
#pragma mark Levels
- (NSInteger)numberOfLevelsInMultiTablesView:(MultiTablesView *)multiTablesView;

/** @name Sections */
#pragma mark Sections
- (NSInteger)multiTablesView:(MultiTablesView *)multiTablesView numberOfSectionsAtLevel:(NSInteger)level;

/** @name Sections Headers & Footers */
#pragma mark Sections Headers & Footers
- (NSString *)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level titleForHeaderInSection:(NSInteger)section;
- (NSString *)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level titleForFooterInSection:(NSInteger)section;

/** @name Fixed Table Headers */
#pragma mark Fixed Table Headers
- (NSString *)multiTablesView:(MultiTablesView *)multiTablesView titleForFixedTableHeaderViewAtLevel:(NSInteger)level;

/** @name Edit rows */
#pragma mark Edit rows
- (BOOL)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level canEditRowAtIndexPath:(NSIndexPath *)indexPath;

@required
/** @name Rows */
#pragma mark Rows
- (NSInteger)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end


/** @name MultiTablesViewDelegate protocol */
#pragma mark - MultiTablesViewDelegate protocol
@protocol MultiTablesViewDelegate <NSObject>

@optional
/** @name Levels */
#pragma mark Levels
- (void)multiTablesView:(MultiTablesView *)multiTablesView levelDidChange:(NSInteger)level;

/** @name Sections Headers & Footers */
#pragma mark Sections Headers & Footers
- (CGFloat)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level heightForHeaderInSection:(NSInteger)section;
- (CGFloat)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level heightForFooterInSection:(NSInteger)section;
- (UIView *)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level viewForHeaderInSection:(NSInteger)section;
- (UIView *)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level viewForFooterInSection:(NSInteger)section;

/** @name Rows */
#pragma mark Rows
- (UITableViewCellSeparatorStyle)multiTablesView:(MultiTablesView *)multiTablesView separatorStyleForLevel:(NSInteger)level;
- (void)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

/** @name Fixed Table Headers */
#pragma mark Fixed Table Headers
- (UIView *)multiTablesView:(MultiTablesView *)multiTablesView fixedTableHeaderViewAtLevel:(NSInteger)level;

/** @name Table Headers */
#pragma mark Table Headers
- (UIView *)multiTablesView:(MultiTablesView *)multiTablesView tableHeaderViewAtLevel:(NSInteger)level;

@end


/** @name MultiTablesView interface */
#pragma mark - MultiTablesView interface
@interface MultiTablesView : UIView

/** @name Properties */
#pragma mark Properties
@property (nonatomic, assign) IBOutlet id<MultiTablesViewDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id<MultiTablesViewDelegate> delegate;

@property (nonatomic, assign, readonly) UITableView *currentTableView;
@property (nonatomic, assign,readwrite) NSUInteger currentTableViewIndex;

@property (nonatomic, assign) BOOL automaticPush;
@property (nonatomic, assign) CGFloat nextTableViewHorizontalGap;


/** @name Reload Datas */
#pragma mark Reload Datas
- (void)reloadData;
- (UITableViewCell *)dequeueReusableCellForLevel:(NSInteger)level withIdentifier:(NSString *)identifier;

/** @name Levels Details */
#pragma mark Levels Details
- (NSInteger)numberOfLevels;
- (NSIndexPath *)indexPathForSelectedRowAtLevel:(NSInteger)level;
- (UITableView *)tableViewAtIndex:(NSInteger)index;

/** @name Push Level */
#pragma mark Push Level
-(void)pushNextTableView:(UITableView*)tableView;

/** @name Pop Levels */
#pragma mark Pop Levels
- (void)popCurrentTableViewAnimated:(BOOL)animated;

@end
