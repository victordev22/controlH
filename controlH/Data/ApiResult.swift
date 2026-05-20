//
//  ApiResult.swift
//  controlH
//
//  Created by user297436 on 5/19/26.
//
import Foundation

enum ApiResult<T> {
    case success(T)
    case error(Error)
}
