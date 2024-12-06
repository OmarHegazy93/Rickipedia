//
//  main.swift
//  Rickipedia
//
//  Created by Omar Hegazy on 05/12/2024.
//


import Foundation
import UIKit

let appDelegateClass: AnyClass = NSClassFromString("TestingAppDelegate") ?? AppDelegate.self

UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    nil,
    NSStringFromClass(appDelegateClass)
)
