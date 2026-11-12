//
//  PageSwipeVc.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 28/09/21.
//

import UIKit
import Toast_Swift

@available(iOS 13.4, *)
class PageSwipeVc: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, PageControllerDelegate {

    
    var identifiers: NSArray = ["FirstNavigationController", "SecondNavigationController"]
    private var lastEndOfBookToastAt: TimeInterval = 0

    override func viewDidLoad() {

        self.dataSource = self
        self.delegate = self
        App_Protocol.delegatePageController = self
        
        let startingViewController = getPageFor(index: UserDefaults.standard.integer(forKey: "BookChapter"))
        let viewControllers: NSArray = [startingViewController as Any]
        self.setViewControllers((viewControllers as! [UIViewController]), direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        
        self.tabDisable()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let reader = App_Protocol.delegateReader as? UIViewController,
              let nav = reader.navigationController,
              nav.transitionCoordinator != nil,
              nav.topViewController !== reader else { return }
        holdChapterPageDuringPush()
    }

    /// Stops the chapter pager from sliding while Book Selection is opening.
    func holdChapterPageDuringPush() {
        for case let scrollView as UIScrollView in view.subviews {
            guard scrollView.contentSize.width > scrollView.bounds.width + 1 else { continue }
            let restingX = scrollView.bounds.width
            guard abs(scrollView.contentOffset.x - restingX) > 0.5 else { continue }
            scrollView.layer.removeAllAnimations()
            scrollView.setContentOffset(CGPoint(x: restingX, y: 0), animated: false)
        }
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
            if newIndex > Ch_Count {
                showEndOfBookToastIfNeeded()
            }
            return nil
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.57) {
                App_Protocol.delegateReader?.mainContainer()
            }
            return getPageFor(index: newIndex)
        }
       
    }

    private func showEndOfBookToastIfNeeded() {
        let now = Date().timeIntervalSince1970
        guard now - lastEndOfBookToastAt > 1.5 else { return }
        lastEndOfBookToastAt = now
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let host: UIView
            if let readerView = (App_Protocol.delegateReader as? UIViewController)?.view {
                host = readerView
            } else {
                host = self.view
            }
            host.makeToast("You’ve reached the end of the Book", duration: 2.0, position: .top)
        }
    }
    
    



    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard finished, completed else { return }
        guard let page = pageViewController.viewControllers?.first as? ReaderSourceViewController,
              let previous = previousViewControllers.first as? ReaderSourceViewController,
              page.Pageindex != previous.Pageindex else { return }
        (App_Protocol.delegateReader as? ReaderViewController)?.noteChapterSwipe()
    }

    func presentationCountForPageViewController(pageViewController: UIPageViewController!) -> Int {
        return self.identifiers.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController!) -> Int {
        return 0
    }

}
