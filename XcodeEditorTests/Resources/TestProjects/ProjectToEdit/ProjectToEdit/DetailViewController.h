//
//  DetailViewController.h
//  ProjectToEdit
//
//  Created by Jasper Blues on 21/11/2015.
//  Copyright © 2015 appsquickly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

