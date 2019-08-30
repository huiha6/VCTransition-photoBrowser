//
//  PanPhotoDelegate.swift
//  GHPhotoBrowser
//
//  Created by Mac on 2019/1/24.
//  Copyright © 2019 gh. All rights reserved.
//

import Foundation
import UIKit

protocol GHPanPhotoDelegate: NSObjectProtocol {
    func panBegan(_ locationPoint: CGPoint)
    func panChanged(_ locationPoint: CGPoint)
    func panCancelledOfEnded()
}
