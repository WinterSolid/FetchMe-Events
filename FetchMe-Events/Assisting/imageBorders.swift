//
//  imageBorders.swift
//  FetchMe-Events
//  Assisted - CGPoint
//  Created by Zakee Tanksley on 9/25/21.
//

import Foundation
import UIKit

extension UIImage {
    
    private static var isStroked = [String: Bool]()
    
    /// Describes the state of image being already stroked
    var isStroked: Bool {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return UIImage.isStroked[tmpAddress] ?? false
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            UIImage.isStroked[tmpAddress] = newValue
        }
    }
    
    /// - Parameter color: color to use as stroke
    /// - Returns: color filled image that is scaled up
    func colorized(with color: UIColor = .white) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        defer {
            UIGraphicsEndImageContext()
        }

        guard let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return self }


        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        color.setFill()
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.clip(to: rect, mask: cgImage)
        context.fill(rect)

        guard let colored = UIGraphicsGetImageFromCurrentImageContext() else { return self }

        return colored
    }
    
    // Adds stroke to image
    func stroked(with color: UIColor = .white, thickness: CGFloat = 2, quality: CGFloat = 10) -> UIImage {
        
        if (self.isStroked == true) {
            print("already stroked")
            return self
        }
        
        guard let cgImage = cgImage else { return self }

        // Colorize the stroke image to reflect border color
        let strokeImage = colorized(with: color)

        guard let strokeCGImage = strokeImage.cgImage else { return self }

        // Rendering quality of the stroke
        let step = quality == 0 ? 10 : abs(quality)

        let oldRect = CGRect(x: thickness, y: thickness, width: size.width, height: size.height).integral
        let newSize = CGSize(width: size.width + 2 * thickness, height: size.height + 2 * thickness)
        let translationVector = CGPoint(x: thickness, y: 0)


        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)

        guard let context = UIGraphicsGetCurrentContext() else { return self }

        defer {
            UIGraphicsEndImageContext()
        }
        context.translateBy(x: 0, y: newSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.interpolationQuality = .high

        for angle: CGFloat in stride(from: 0, to: 360, by: step) {
            let vector = translationVector.rotated(around: .zero, byDegrees: angle)
            let transform = CGAffineTransform(translationX: vector.x, y: vector.y)

            context.concatenate(transform)

            context.draw(strokeCGImage, in: oldRect)

            let resetTransform = CGAffineTransform(translationX: -vector.x, y: -vector.y)
            context.concatenate(resetTransform)
        }

        context.draw(cgImage, in: oldRect)

        guard let stroked = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        
        self.isStroked = true
        
        return stroked
    }
    
}

extension CGPoint {
    
    func rotated(around origin: CGPoint, byDegrees: CGFloat) -> CGPoint {
        let dx = x - origin.x
        let dy = y - origin.y
        let radius = sqrt(dx * dx + dy * dy)
        /*There are approximately 6.28 Radians in a full circle
        in radians*/
        //Radians
        let azimuth = atan2(dy, dx)
        // Radians
        let newAzimuth = azimuth + byDegrees * .pi / 180.0
        let x = origin.x + radius * cos(newAzimuth)
        let y = origin.y + radius * sin(newAzimuth)
        return CGPoint(x: x, y: y)
    }
    
}

