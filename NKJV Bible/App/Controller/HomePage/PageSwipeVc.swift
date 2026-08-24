//
//  PageSwipeVc.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 28/09/21.
//

import UIKit

@available(iOS 13.4, *)
class PageSwipeVc: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, PageControllerDelegate {

    
    var identifiers: NSArray = ["FirstNavigationController", "SecondNavigationController"]
    override func viewDidLoad() {

        self.dataSource = self
        self.delegate = self
        App_Protocol.delegatePageController = self
        
        let startingViewController = getPageFor(index: UserDefaults.standard.integer(forKey: "BookChapter"))
        let viewControllers: NSArray = [startingViewController as Any]
        self.setViewControllers((viewControllers as! [UIViewController]), direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        
        self.tabDisable()
    }
    
    func tabDisable() {
        for recognizer in self.gestureRecognizers {
            if recognizer is UITapGestureRecognizer {
                recognizer.isEnabled = false
            }
        }
    }

    
    
    func disaBlePageControll() {
        for recognizer in self.gestureRecognizers {
           recognizer.isEnabled = false
       }
    }
    
    func enablePageControll() {
        for recognizer in self.gestureRecognizers {
           recognizer.isEnabled = true
       }
       self.tabDisable()
    }
    
    
    
    
    func ReloadAllData(index: Int) {
          let pageController  = self.storyboard?.instantiateViewController(identifier: "ReaderSourceViewController") as? ReaderSourceViewController
        pageController!.Pageindex = index
    }

    
    func getPageFor(index: Int) -> ReaderSourceViewController? {
        guard  let pageController  = self.storyboard?.instantiateViewController(identifier: "ReaderSourceViewController") as? ReaderSourceViewController else { return nil }
        pageController.Pageindex = index
        return pageController
    }
    

    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore
        viewController: UIViewController) -> UIViewController? {
        guard let beforePage = viewController as? ReaderSourceViewController else { return nil }
        NotificationCenter.default.post(name: Notification.Name("showFrame"), object: nil)
        let beforePageIndex = beforePage.Pageindex
        let newIndex = UserDefaults.standard.integer(forKey: "BookChapter") - 1
        
        if newIndex < 1 {
            return nil
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.57) {
                App_Protocol.delegateReader?.mainContainer()
            }
            return getPageFor(index: newIndex)
        }

    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let afterPage = viewController as? ReaderSourceViewController else { return nil }
        NotificationCenter.default.post(name: Notification.Name("showFrame"), object: nil)
        let afterPageIndex = afterPage.Pageindex
        let BookName =  UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName
        let Ch_Count = BibleContent.sharedInstance.AudioBibleListCount(selecterBookName: BookName)
        let newIndex = UserDefaults.standard.integer(forKey: "BookChapter") + 1

        if newIndex < 1 || newIndex > Ch_Count {
            return nil
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.57) {
                App_Protocol.delegateReader?.mainContainer()
            }
            return getPageFor(index: newIndex)
        }
       
    }
    
    



    func presentationCountForPageViewController(pageViewController: UIPageViewController!) -> Int {
        return self.identifiers.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController!) -> Int {
        return 0
    }

}
