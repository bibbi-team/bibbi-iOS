//
//  UIImage+Ext.swift
//  App
//
//  Created by Kim dohyun on 12/7/23.
//

import UIKit

import DesignSystem

extension UIImage {
    public func combinedTextWithBackground(target text: String, size: CGSize, attributedString: [NSAttributedString.Key : Any]) -> UIImage {
        let renderImage: UIGraphicsImageRenderer = UIGraphicsImageRenderer(size: size)
        let targetText: NSString = (text as NSString)
        
        let targetTextSize: CGSize = targetText.size(withAttributes: attributedString)
        let centerX = (size.width - targetTextSize.width) / 2
        let centerY = (size.height - targetTextSize.height) / 2
        let targetRect: CGRect = CGRect(x: centerX, y: centerY, width: targetTextSize.width, height: targetTextSize.height)
        let originalImage: UIImage = renderImage.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
            targetText.size(withAttributes: attributedString)
            targetText.draw(in: targetRect, withAttributes: attributedString)
        }
        return originalImage
    }
    
    public func combinedWithAlpha(with alpha: CGFloat, blendMode: CGBlendMode) -> UIImage {
        let renderImage: UIGraphicsImageRenderer = UIGraphicsImageRenderer(size: size)
        
        let originalImage: UIImage = renderImage.image { _ in
            draw(at: .zero, blendMode: blendMode, alpha: alpha)
        }
        
        return originalImage
    }
    
    public func resized(to size: CGSize) -> UIImage? {
        let renderImage: UIGraphicsImageRenderer = UIGraphicsImageRenderer(size: size)
        let originalImage: UIImage = renderImage.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
        return originalImage
    }
}

extension UIImage {
    public typealias TopBarIconType = NavigationBar.IconType
    public typealias TopBarImageType = NavigationBar.ImageType
    
    public enum NavigationBar {
        public enum ImageType {
            case bibbi
            case newBibbi
        }
        
        public enum IconType {
            case addPerson
            case arrowLeft
            case heartCalendar
            case setting
            case xmark
        }
    }
}

extension UIImage.NavigationBar.IconType {
    public var barButtonImage: UIImage? {
        switch self {
        case .addPerson:
            return DesignSystemAsset.addPerson.image
        case .arrowLeft:
            return UIImage(systemName: "chevron.backward")
        case .heartCalendar:
            return DesignSystemAsset.heartCalendar.image
        case .setting:
            return DesignSystemAsset.setting.image
        case .xmark:
            return DesignSystemAsset.xmark.image
        }
    }
}

extension UIImage.NavigationBar.ImageType {
    public var barImage: UIImage? {
        switch self {
        case .bibbi:
            return DesignSystemAsset.bibbiLogo.image
        case .newBibbi:
            return DesignSystemAsset.bibbiLogo.image
        }
    }
}
