//
//  PanPhotoDelegate.swift
//  GHPhotoBrowser
//
//  Created by Sansi Mac on 2019/1/24.
//  Copyright © 2019 jinjin. All rights reserved.
//

import Foundation
import UIKit

protocol PanPhotoDelegate: NSObjectProtocol {
    func panBegan(_ locationPoint: CGPoint)
    func panChanged(_ locationPoint: CGPoint)
    func panCancelledOfEnded()
}
