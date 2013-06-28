//
//  ViewController.m
//  MultiTablesView
//
//  Created by Zouhair on 20/06/13.
//  Copyright (c) 2013 Zedenem. All rights reserved.
//

#import "ViewController.h"
#import "MultiTablesView.h"

@interface ViewController () <MultiTablesViewDataSource, MultiTablesViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)dealloc {
	[super dealloc];
}

#pragma mark - MultiTablesViewDataSource
#pragma mark Levels
- (NSInteger)numberOfLevelsInMultiTablesView:(MultiTablesView *)multiTablesView {
	return 5;
}
#pragma mark Sections
- (NSInteger)multiTablesView:(MultiTablesView *)multiTablesView numberOfSectionsAtLevel:(NSInteger)level {
	return 1;
}
#pragma mark Sections Headers & Footers
- (NSString *)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level titleForHeaderInSection:(NSInteger)section {
	return [NSString stringWithFormat:@"{%d, %d}", section, level];
}
- (NSString *)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level titleForFooterInSection:(NSInteger)section {
	return nil;
}
#pragma mark Rows
- (NSInteger)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level numberOfRowsInSection:(NSInteger)section {
	return level * section + 5;
}
- (UITableViewCell *)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [multiTablesView dequeueReusableCellForLevel:level withIdentifier:CellIdentifier];
    if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	[cell.textLabel setText:[NSString stringWithFormat:@"{%d, %d, %d}", indexPath.row, indexPath.section, level]];
    
    return cell;
}

#pragma mark - MultiTablesViewDelegate
#pragma mark Levels
- (void)multiTablesView:(MultiTablesView *)multiTablesView levelDidChange:(NSInteger)level {
	if (multiTablesView.currentTableViewIndex == level) {
		[multiTablesView.currentTableView deselectRowAtIndexPath:[multiTablesView.currentTableView indexPathForSelectedRow] animated:YES];
	}
}
#pragma mark Rows
- (void)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}
- (void)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
#pragma mark Sections Headers & Footers
- (CGFloat)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level heightForFooterInSection:(NSInteger)section {
	return 0.0;
}
#pragma mark Fixed Table Headers
- (UIView *)multiTablesView:(MultiTablesView *)multiTablesView fixedTableHeaderViewAtLevel:(NSInteger)level {
	UILabel *fixedTableHeaderView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 22.0)];
	[fixedTableHeaderView setBackgroundColor:[UIColor redColor]];
	[fixedTableHeaderView setText:[NSString stringWithFormat:@"Level %d", level]];
	return fixedTableHeaderView;
}

@end
