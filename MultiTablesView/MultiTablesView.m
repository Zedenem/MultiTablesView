//
//  MultiTablesView.m
//  MultiTablesView
//
//  Created by Zouhair on 20/06/13.
//  Copyright (c) 2013 Zedenem. All rights reserved.
//

#import "MultiTablesView.h"
#import <QuartzCore/QuartzCore.h>
#import "UITableView+FixedTableHeaderView.h"

#pragma mark - Interface
@interface MultiTablesView () <UITableViewDataSource, UITableViewDelegate>

/** @name Setup */
#pragma mark Setup
- (void)setup;

/** @name Properties */
#pragma mark Properties
@property (nonatomic, retain) NSMutableArray *tableViews;
@property (nonatomic, readonly) CGFloat defaultNextTableViewHorizontalGap;

/** @name Levels Details */
#pragma mark Levels Details
- (NSInteger)indexOfTableView:(UITableView *)tableView;

/** @name Default Headers and Footers Heights */
#pragma mark Default Headers and Footers Heights
- (CGFloat)defaultHeightForHeaderInSection:(NSInteger)section atLevel:(NSInteger)level;
- (CGFloat)defaultHeightForFooterInSection:(NSInteger)section atLevel:(NSInteger)level;

@end

#pragma mark - Implementation
@implementation MultiTablesView

#pragma mark Properties
@synthesize dataSource = _dataSource;
- (void)setDataSource:(id<MultiTablesViewDataSource>)dataSource {
	if (![_dataSource isEqual:dataSource]) {
		_dataSource = dataSource;
		[self reloadData];
	}
}
@synthesize delegate = _delegate;
- (void)setDelegate:(id<MultiTablesViewDelegate>)delegate {
	if (![_delegate isEqual:delegate]) {
		_delegate = delegate;
		[self reloadData];
	}
}

@synthesize tableViews = _tableViews;
@synthesize nextTableViewHorizontalGap = _nextTableViewHorizontalGap;
@dynamic defaultNextTableViewHorizontalGap;
- (CGFloat)defaultNextTableViewHorizontalGap {
	return 44.0;
}

@synthesize currentTableView = _currentTableView;
- (UITableView *)currentTableView {
	return [self tableViewAtIndex:self.currentTableViewIndex];
}
@synthesize currentTableViewIndex = _currentTableViewIndex;


-(void)setCurrentTableViewIndex:(NSUInteger)currentTableViewIndex{
    _currentTableViewIndex = currentTableViewIndex;
    if ([self.delegate respondsToSelector:@selector(multiTablesView:levelDidChange:)]) {
        [self.delegate multiTablesView:self levelDidChange:self.currentTableViewIndex];
    }
}

- (void)addPanGestureRecognizer {
	if ([self.gestureRecognizers count] == 0) {
		UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragTableView:)];
		[self addGestureRecognizer:panGestureRecognizer];
		[panGestureRecognizer release];
	}
}
- (void)removePanGestureRecognizer {
	[self removeGestureRecognizer:[self.gestureRecognizers lastObject]];
}

#pragma mark Setup
- (void)setup {
	[self setAutomaticPush:YES];
	[self setNextTableViewHorizontalGap:[self defaultNextTableViewHorizontalGap]];
	[self addPanGestureRecognizer];
}

#pragma mark View Lifecycle
- (void)awakeFromNib {
	[super awakeFromNib];
	[self setup];
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setup];
    }
    return self;
}
- (void)dealloc {
	[self setDataSource:nil];
	[self setDelegate:nil];
	[self setTableViews:nil];
	[_tableViews release];
	[self setCurrentTableViewIndex:NSNotFound];
	[super dealloc];
}

#pragma mark Reload Datas
- (void)reloadData {
	NSInteger numberOfLevels = 1;
	if ([self.dataSource respondsToSelector:@selector(numberOfLevelsInMultiTablesView:)]) {
		numberOfLevels = [self.dataSource numberOfLevelsInMultiTablesView:self];
	}
	if (numberOfLevels > 0) {
		if (!self.tableViews) {
			self.tableViews = [NSMutableArray arrayWithCapacity:numberOfLevels];
		}
		else  {
			[self.tableViews enumerateObjectsUsingBlock:^(UITableView *tableView, NSUInteger idx, BOOL *stop) {
				if (idx > numberOfLevels) {
					[tableView removeFromSuperview];
				}
			}];
			if ([self.tableViews count] > numberOfLevels) {
				[self.tableViews removeObjectsInRange:NSMakeRange(numberOfLevels, [self.tableViews count] - 1)];
			}
		}
		for (int i = 0; i < numberOfLevels; i++) {
			CGRect tableViewFrame = self.bounds;
			if (i > 0) {
				tableViewFrame = CGRectMake(self.bounds.size.width + 20.0, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
			}
			UITableView *tableView = nil;
			if (i < [self.tableViews count]) {
				tableView = [self.tableViews objectAtIndex:i];
				[tableView setFrame:tableViewFrame];
				[tableView reloadData];
				[tableView.fixedTableHeaderView removeFromSuperview];
				[tableView setFixedTableHeaderView:nil];
			}
			else {
				tableView = [[[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain] autorelease];
				[self.tableViews addObject:tableView];
				[self addSubview:tableView];
				
				// Add a Shadow to the table View
				tableView.layer.shadowColor = [[UIColor blackColor] CGColor];
				tableView.layer.shadowOffset = CGSizeMake(-2, 0);
				tableView.layer.masksToBounds = NO;
				tableView.layer.shadowRadius = 5.0;
				tableView.layer.shadowOpacity = 0.4;
				tableView.layer.shouldRasterize = YES;
				tableView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
				UIBezierPath *path = [UIBezierPath bezierPathWithRect:tableView.bounds];
				tableView.layer.shadowPath = path.CGPath;
				
				[tableView setDelegate:self];
				[tableView setDataSource:self];
			}
			
			// Set UITableView separator style
			UITableViewCellSeparatorStyle separatorStyle = UITableViewCellSeparatorStyleSingleLine;
			if ([self.delegate respondsToSelector:@selector(multiTablesView:separatorStyleForLevel:)]) {
				separatorStyle = [self.delegate multiTablesView:self separatorStyleForLevel:i];
			}
			[tableView setSeparatorStyle:separatorStyle];
			
			if ([self.delegate respondsToSelector:@selector(multiTablesView:tableHeaderViewAtLevel:)]) {
				[tableView setTableHeaderView:[self.delegate multiTablesView:self tableHeaderViewAtLevel:i]];
			}
			else {
				[tableView setTableHeaderView:nil];
			}
			
			if ([self.delegate respondsToSelector:@selector(multiTablesView:fixedTableHeaderViewAtLevel:)]) {
				UIView *fixedTableHeaderView = [self.delegate multiTablesView:self fixedTableHeaderViewAtLevel:i];
				[fixedTableHeaderView setFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, fixedTableHeaderView.frame.size.width, fixedTableHeaderView.frame.size.height)];
				
				// Add a Shadow to the fixed table header view
				fixedTableHeaderView.layer.shadowColor = [[UIColor blackColor] CGColor];
				fixedTableHeaderView.layer.shadowOffset = CGSizeMake(-2, 0);
				fixedTableHeaderView.layer.masksToBounds = NO;
				fixedTableHeaderView.layer.shadowRadius = 5.0;
				fixedTableHeaderView.layer.shadowOpacity = 0.4;
				fixedTableHeaderView.layer.shouldRasterize = YES;
				fixedTableHeaderView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
				UIBezierPath *path = [UIBezierPath bezierPathWithRect:fixedTableHeaderView.bounds];
				fixedTableHeaderView.layer.shadowPath = path.CGPath;
				
				[self addSubview:fixedTableHeaderView];
				[tableView setFixedTableHeaderView:fixedTableHeaderView];
			}
		}
	}
}
- (UITableViewCell *)dequeueReusableCellForLevel:(NSInteger)level withIdentifier:(NSString *)identifier {
	return [[self tableViewAtIndex:level] dequeueReusableCellWithIdentifier:identifier];
}

#pragma mark Levels Details
- (NSInteger)numberOfLevels {
	return [self.tableViews count];
}
- (NSInteger)indexOfTableView:(UITableView *)tableView {
	return [self.tableViews indexOfObject:tableView];
}
- (UITableView *)tableViewAtIndex:(NSInteger)index {
	UITableView *tableView = nil;
	if (index >= 0 && index < [self.tableViews count]) {
		tableView = [self.tableViews objectAtIndex:index];
	}
	return tableView;
}
- (NSIndexPath *)indexPathForSelectedRowAtLevel:(NSInteger)level {
	return [[self tableViewAtIndex:level] indexPathForSelectedRow];
}

-(void)animateRight{
    CGFloat newXCoordinate = self.bounds.size.width;
    UITableView *draggedTableView = self.currentTableView;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         [draggedTableView setFrame:CGRectMake(newXCoordinate, self.bounds.origin.y, self.frame.size.width, self.frame.size.height)];
                    	 [draggedTableView.fixedTableHeaderView setCenter:CGPointMake(draggedTableView.center.x, draggedTableView.fixedTableHeaderView.center.y)];
					 }
                     completion:^(BOOL finished) {
                     }];
}

#pragma mark Levels Dragging Animations & Interactions
- (void)dragTableView:(UIPanGestureRecognizer *)panGestureRecognizer {
	UITableView *draggedTableView = self.currentTableView;
	
	// Calculate default X Coordinate of current Table View
	CGFloat draggedTableViewDefaultXCoordinate = 0.0;
	UITableView *previousTableView = [self tableViewAtIndex:self.currentTableViewIndex-1];
	if (self.currentTableViewIndex > 0) {
		draggedTableViewDefaultXCoordinate = previousTableView.frame.origin.x + self.nextTableViewHorizontalGap;
	}
	
	switch (panGestureRecognizer.state) {
		case UIGestureRecognizerStateEnded: {
			if (self.currentTableViewIndex > 0) {
				if ([panGestureRecognizer velocityInView:draggedTableView].x > 500.0 || draggedTableView.frame.origin.x > self.bounds.size.width/3*2) {
					draggedTableViewDefaultXCoordinate = self.bounds.size.width;
					if (self.currentTableViewIndex > 0) {
						draggedTableViewDefaultXCoordinate = self.bounds.size.width + 20;
					}
					[self setCurrentTableViewIndex:self.currentTableViewIndex-1];
				}
			}
			[UIView animateWithDuration:0.2
								  delay:0.0
								options:UIViewAnimationCurveEaseInOut
							 animations:^{
								 [draggedTableView setFrame:CGRectMake(draggedTableViewDefaultXCoordinate, self.bounds.origin.y, self.frame.size.width, self.frame.size.height)];
								 [draggedTableView.fixedTableHeaderView setCenter:CGPointMake(draggedTableView.center.x, draggedTableView.fixedTableHeaderView.center.y)];
							 }
							 completion:^(BOOL finished) {
							 }];
		} break;
		default: {
			CGFloat newXCenter = MAX(draggedTableView.center.x + [panGestureRecognizer translationInView:draggedTableView].x, draggedTableViewDefaultXCoordinate + draggedTableView.frame.size.width/2);
			[draggedTableView setCenter:CGPointMake(newXCenter, draggedTableView.center.y)];
			[draggedTableView.fixedTableHeaderView setCenter:CGPointMake(draggedTableView.center.x, draggedTableView.fixedTableHeaderView.center.y)];
			[panGestureRecognizer setTranslation:CGPointZero inView:draggedTableView];
		} break;
	}
}

#pragma mark Default Headers and Footers Heights
- (CGFloat)defaultHeightForHeaderInSection:(NSInteger)section atLevel:(NSInteger)level {
	return [self tableViewAtIndex:level].sectionHeaderHeight;
}
- (CGFloat)defaultHeightForFooterInSection:(NSInteger)section atLevel:(NSInteger)level {
	return [self tableViewAtIndex:level].sectionFooterHeight;
}

#pragma mark - UITableViewDataSource
#pragma mark Sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger numberOfSections = 0;
	if ([self.dataSource respondsToSelector:@selector(multiTablesView:numberOfSectionsAtLevel:)]) {
		numberOfSections = [self.dataSource multiTablesView:self numberOfSectionsAtLevel:[self indexOfTableView:tableView]];
	}
	return numberOfSections;
}
#pragma mark Sections Headers & Footers
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *titleForHeaderInSection = nil;
    if ([self.dataSource respondsToSelector:@selector(multiTablesView:level:titleForHeaderInSection:)]) {
		titleForHeaderInSection = [self.dataSource multiTablesView:self level:self.currentTableViewIndex titleForHeaderInSection:section];
	}
	return titleForHeaderInSection;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	NSString *titleForFooterInSection = nil;
    if ([self.dataSource respondsToSelector:@selector(multiTablesView:level:titleForFooterInSection:)]) {
		titleForFooterInSection = [self.dataSource multiTablesView:self level:self.currentTableViewIndex titleForFooterInSection:section];
	}
	return titleForFooterInSection;
}
#pragma mark Rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger numberOfRows = 0;
	if ([self.dataSource respondsToSelector:@selector(multiTablesView:level:numberOfRowsInSection:)]) {
		numberOfRows = [self.dataSource multiTablesView:self level:[self indexOfTableView:tableView] numberOfRowsInSection:section];
	}
	return numberOfRows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	if ([self.dataSource respondsToSelector:@selector(multiTablesView:level:cellForRowAtIndexPath:)]) {
		cell = [self.dataSource multiTablesView:self level:[self indexOfTableView:tableView] cellForRowAtIndexPath:indexPath];
	}
	return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ([self.dataSource respondsToSelector:@selector(multiTablesView:level:canEditRowAtIndexPath:)]) {
        cell = [self.dataSource multiTablesView:self level:[self indexOfTableView:tableView] canEditRowAtIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
#pragma mark Sections Headers & Footers
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	CGFloat heightForHeader = 0.0;
	if ([self.delegate respondsToSelector:@selector(multiTablesView:level:heightForHeaderInSection:)]) {
		heightForHeader = [self.delegate multiTablesView:self level:[self indexOfTableView:tableView] heightForHeaderInSection:section];
	}
	else {
		heightForHeader = [self defaultHeightForHeaderInSection:section atLevel:[self indexOfTableView:tableView]];
	}
	return heightForHeader;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	CGFloat heightForFooter = 0.0;
	if ([self.delegate respondsToSelector:@selector(multiTablesView:level:heightForFooterInSection:)]) {
		heightForFooter = [self.delegate multiTablesView:self level:[self indexOfTableView:tableView] heightForFooterInSection:section];
	}
	else {
		heightForFooter = [self defaultHeightForFooterInSection:section atLevel:[self indexOfTableView:tableView]];
	}
	return heightForFooter;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView * viewForHeaderInSection = nil;
    if ([self.delegate respondsToSelector:@selector(multiTablesView:level:viewForHeaderInSection:)]) {
		viewForHeaderInSection = [self.delegate multiTablesView:self level:[self indexOfTableView:tableView] viewForHeaderInSection:section];
	}
    return viewForHeaderInSection;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView * viewForFooterInSection = nil;
    if ([self.delegate respondsToSelector:@selector(multiTablesView:level:viewForFooterInSection:)]) {
		viewForFooterInSection = [self.delegate multiTablesView:self level:[self indexOfTableView:tableView] viewForFooterInSection:section];
	}
    return viewForFooterInSection;
}
#pragma mark Rows
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.delegate respondsToSelector:@selector(multiTablesView:level:willDisplayCell:forRowAtIndexPath:)]) {
		[self.delegate multiTablesView:self level:[self indexOfTableView:tableView] willDisplayCell:cell forRowAtIndexPath:indexPath];
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.delegate respondsToSelector:@selector(multiTablesView:level:willSelectRowAtIndexPath:)]) {
		return [self.delegate multiTablesView:self level:[self indexOfTableView:tableView] willSelectRowAtIndexPath:indexPath];
	}
	else {
		return indexPath;
	}
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.delegate respondsToSelector:@selector(multiTablesView:level:didSelectRowAtIndexPath:)]) {
		[self.delegate multiTablesView:self level:[self indexOfTableView:tableView] didSelectRowAtIndexPath:indexPath];
	}
    if (self.automaticPush) {
        [self pushNextTableView:tableView];
    }
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(multiTablesView:level:commitEditingStyle:forRowAtIndexPath:)]) {
		[self.delegate multiTablesView:self level:[self indexOfTableView:tableView] commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
	}
}
#pragma mark Push Level
-(void)pushNextTableView:(UITableView*)tableView {
    NSInteger indexOfTableView = [self indexOfTableView:tableView];
	
    for (int i = indexOfTableView + 1; i < [self numberOfLevels]; i++) {
		[[self tableViewAtIndex:i] reloadData];
	}
    
	[self setCurrentTableViewIndex:indexOfTableView + 1];
    
	[UIView animateWithDuration:0.2
						  delay:0.0
						options:UIViewAnimationCurveEaseOut
					 animations:^{
						 for (int i = self.currentTableViewIndex; i < [self numberOfLevels]; i++) {
							 UITableView *nextTableView = [self tableViewAtIndex:i];
							 [nextTableView setFrame:CGRectMake(self.bounds.size.width + 20, nextTableView.frame.origin.y, nextTableView.frame.size.width, nextTableView.frame.size.height)];
						 	 [nextTableView.fixedTableHeaderView setCenter:CGPointMake(nextTableView.center.x, nextTableView.fixedTableHeaderView.center.y)];
						 }
					 }
					 completion:^(BOOL finished) {
						 [UIView animateWithDuration:0.2
											   delay:0.0
											 options:UIViewAnimationCurveEaseOut
										  animations:^{
											  [self.currentTableView setFrame:CGRectMake(tableView.frame.origin.x + self.nextTableViewHorizontalGap, self.currentTableView.frame.origin.y, self.currentTableView.frame.size.width, self.currentTableView.frame.size.height)];
											  [self.currentTableView.fixedTableHeaderView setCenter:CGPointMake(self.currentTableView.center.x, self.currentTableView.fixedTableHeaderView.center.y)];
										  }
										  completion:^(BOOL finished) {}
						  ];
					 }];
}

#pragma mark Pop Levels
- (void)popCurrentTableViewAnimated:(BOOL)animated {
	if (self.currentTableViewIndex > 0) {
		// Calculate default X Coordinate of current Table View
		CGFloat tableViewDefaultXCoordinate = self.bounds.size.width;
		if (self.currentTableViewIndex > 0) {
			tableViewDefaultXCoordinate = self.bounds.size.width + 20;
		}
		
		[UIView animateWithDuration:animated?0.2:0.0
							  delay:0.0
							options:UIViewAnimationCurveEaseInOut
						 animations:^{
							 [self.currentTableView setFrame:CGRectMake(tableViewDefaultXCoordinate, self.bounds.origin.y, self.frame.size.width, self.frame.size.height)];
							 [self.currentTableView.fixedTableHeaderView setCenter:CGPointMake(self.currentTableView.center.x, self.currentTableView.fixedTableHeaderView.center.y)];
						 }
						 completion:^(BOOL finished) {
							 [self setCurrentTableViewIndex:self.currentTableViewIndex-1];
						 }];
	}
}

@end
