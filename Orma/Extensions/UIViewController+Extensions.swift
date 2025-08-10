//
//  UIViewController+Extensions.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import UIKit

extension UIApplication {
    static var rootViewController: UIViewController? {
        shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
