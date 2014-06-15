//
//  SEGalleryViewController.swift
//  sechi
//
//  Created by TCSASSEMBLER on 2014-06-13.
//  Copyright (c) 2014 TopCoder. All rights reserved.
//

/**
 *  View controller used for displaying a gallery of photos
 */
class SEGalleryViewController: SEViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    /**
     *  Index of a first photo that should be shown.
     */
    var startIndex: Int

    /**
     *  Array of photos that will be presented.
     */
    var mediaFiles: SEJobPhotoInfo[]!

    /**
     *  UIPageViewController used for displaying gallery
     */
    var pageViewController: UIPageViewController!

    /**
     *  Initializer that setups the view controller for displaying the item at index param as first.
     *
     *  @param mediaFiles mediaFiles array of photos to display
     *  @param index      index of photo that will be displayed as a first
     *
     *  @return initialized view controller on success, nil on failure
     */
    init(mediaFilesArray mediaFiles: SEJobPhotoInfo[], atIndex index: Int) {
        super.init(nibName: nil, bundle: nil)
        self.mediaFiles = mediaFiles
        self.startIndex = index
    }

    /**
     *  Initializer that setups the view controller for displaying the first item.
     *
     *  @param mediaFiles array of photos to display
     *
     *  @return initialized view controller on success, nil on failure
     */
    convenience init(mediaFilesArray mediaFiles: SEJobPhotoInfo[]) {
        self.init(mediaFilesArray: mediaFiles, atIndex: 0)
    }

    /**
     *  Setup UIPageViewController, show it's view on the screen. Prepare NSLayoutConstraints.
     */
    func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var background = UIImageView(image: UIImage(named: "bg.png"))
        background.contentMode = .ScaleAspectFill
        background.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(background)
        
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        
        self.addChildViewController(self.pageViewController)
        
        self.view.addSubview(self.pageViewController.view)
        
        self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.title = "SCHEDULE"
        
        var lineView = UIImageView(image: UIImage(named: "line_schedule"))
        lineView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(lineView)
        
        var views = ["pvc": self.pageViewController.view, "line": lineView, "bg": background]
        self.view.addConstraints(NSLayoutConstraint(visualFormat: "H:|[bg]|", options: nil, metrics: nil, views:views))

        self.view.addConstraints(NSLayoutConstraint(visualFormat: "V:|[bg]|", options: nil, metrics: nil, views:views))

        self.view.addConstraints(NSLayoutConstraint(visualFormat: "H:|[pvc]|", options: nil, metrics: nil, views:views))

        self.view.addConstraints(NSLayoutConstraint(visualFormat: "H:|[line]|", options: nil, metrics: nil, views:views))
        
        self.view.addConstraints(NSLayoutConstraint(visualFormat: "V:|-(64)-[line(==10)][pvc]|", options: nil, metrics: nil, views:views))
        
        self.pageViewController.didMoveToParentViewController(self)
    }

    /**
     *  Show desired photo as a first item before view will appear
     *
     *  @param animated
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController.navigationBarHidden {
            self.navigationController.setNavigationBarHidden(false, animated: animated)
        }
        self.setupNavigationBarBackButton()
        
        if self.startIndex >= self.mediaFiles.count {
            startIndex = 0
        }
        
        self.pageViewController.setViewControllers([self.viewControllerAtIndex: self.startIndex], direction: .Forward, animated: false, completion: nil)
    }

    func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return true
    }

    func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
        return true
    }

    /**
     *  Inform view controllers from UIPageViewController that the device will change orientation
     *
     *  @param toInterfaceOrientation
     *  @param duration
     */
    func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        for vc in self.pageViewController.viewControllers {
            vc.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        }
    }

    /**
     *  Update UI after device change orientation
     *
     *  @param fromInterfaceOrientation
     */
    func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.view.setNeedsLayout()
        self.pageViewController.view.setNeedsLayout()
        
        for vc in self.pageViewController.viewControllers {
            vc.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
            
            vc.view.setNeedsUpdateConstraints()
            vc.view.setNeedsLayout()
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_main_queue(), {
            () -> () in
            var index = self.mediaFiles.indexOfObject((self.pageViewController.viewControllers.lastObject as SEPhotoViewController).jobPhotoInfo)
            
            self.pageViewController.setViewControllers([self.viewControllerAtIndex: index], direction: .Forward, animated: false, completion: nil)
        })
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController {
        var currentIndex = self.mediaFiles.indexOfObject((viewController as SEPhotoViewController).jobPhotoInfo)
        
        return self.viewControllerAtIndex(currentIndex + 1)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController {
        var currentIndex = self.mediaFiles.indexOfObject((viewController as SEPhotoViewController).jobPhotoInfo)
        
        return self.viewControllerAtIndex(currentIndex - 1)
    }

    func pageViewController(pageViewController: UIPageViewController, spineLocationForInterfaceOrientation orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        var allPageControllers = pageViewController.viewControllers
        
        if let allPageControllers = pageViewController.viewControllers? {
            self.pageViewController.setViewControllers(allPageControllers, direction: .Forward, animated: false, completion: nil)
        } else {
            var defaultViewController = UIViewController()
            self.pageViewController.setViewControllers([defaultViewController], direction: .Forward, animated: false, completion: nil)
        }
        
        return .Min;
    }

    /**
     *  Method returns view controller with photo to display in UIPageViewController
     *
     *  @param index index of photo that should be used
     *
     *  @return initialized view controller or nil on failure
     */
    func viewControllerAtIndex(index: Int) -> UIViewController? {
        if index >= 0 && index < self.mediaFiles.count {
            return SEPhotoViewController(jobPhotoInfo: self.mediaFiles[index])
        }
        return nil
    }

}
