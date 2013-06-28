//
//  UITableView+FixedTableHeaderView.m
//  MultiTablesView
//
//  Created by Zouhair on 20/06/13.
//  Copyright (c) 2013 Zedenem. All rights reserved.
//

#import "UITableView+FixedTableHeaderView.h"

#import <objc/runtime.h>

@implementation UITableView (FixedTableHeaderView)

static const char* fixedTableHeaderViewKey = "FixedTableHeaderView";

- (UIView *)fixedTableHeaderView {
    return objc_getAssociatedObject(self, fixedTableHeaderViewKey);
}

- (void)setFixedTableHeaderView:(UIView *)fixedTableHeaderView {
    objc_setAssociatedObject(self, fixedTableHeaderViewKey, fixedTableHeaderView, OBJC_ASSOCIATION_ASSIGN);
	[self setContentInset:UIEdgeInsetsMake(fixedTableHeaderView.frame.size.height, self.contentInset.left, self.contentInset.bottom, self.contentInset.right)];
}

@end
