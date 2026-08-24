//
//  QuizPdf.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 03/03/23.
//

import UIKit






//extension UITableView {
//
//    // Export pdf from UITableView and save pdf in drectory and return pdf file path
//    func exportAsPdfFromTable(pdfName:String) -> String {
//
//        let originalBounds = self.bounds
//        self.bounds = CGRect(x:originalBounds.origin.x, y: originalBounds.origin.y, width: self.contentSize.width, height: self.contentSize.height)
//        let pdfPageFrame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.contentSize.height)
//
//        let pdfData = NSMutableData()
//        UIGraphicsBeginPDFContextToData(pdfData, pdfPageFrame, nil)
//        UIGraphicsBeginPDFPageWithInfo(pdfPageFrame, nil)
//        guard let pdfContext = UIGraphicsGetCurrentContext() else { return "" }
//        self.layer.render(in: pdfContext)
//        UIGraphicsEndPDFContext()
//        self.bounds = originalBounds
//        // Save pdf data
//        return self.saveTablePdf(data: pdfData,name:pdfName)
//
//    }
//
//    // Save pdf file in document directory
//    func saveTablePdf(data: NSMutableData,name:String) -> String {
//
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let docDirectoryPath = paths[0]
//        let pdfPath = docDirectoryPath.appendingPathComponent("\(name).pdf")
//        if data.write(to: pdfPath, atomically: true) {
//            return pdfPath.path
//        } else {
//            return ""
//        }
//    }
//}




class QuizPdf: NSObject {

  func generatePdfFromCollectionView(_ collectionView: UICollectionView?, filename:String, success:(String) -> ()) {

      guard let collectionView = collectionView else {
          return
      }

      let pdfData = NSMutableData()

      let contentArea = CGRect(
          x: 0,
          y: 0,
          width: collectionView.contentSize.width,
          height: collectionView.contentSize.height
      )

      collectionView.frame = contentArea

      UIGraphicsBeginPDFContextToData(pdfData, contentArea, nil)

      UIGraphicsBeginPDFPage()
      collectionView.drawHierarchy(in: collectionView.bounds, afterScreenUpdates: true)
      UIGraphicsEndPDFContext()

      if let filepath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
          let fileFullPath = filepath + "/" + filename

          if pdfData.write(toFile: fileFullPath, atomically: true) {
              success(fileFullPath)
          }
      }
  }
}
