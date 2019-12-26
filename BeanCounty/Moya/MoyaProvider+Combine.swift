//
//  MoyaProvider+Combine.swift
//  BeanCounty
//
//  Created by Max Desiatov on 26/12/2019.
//  Copyright © 2019 Digital Signal Limited. All rights reserved.
//

import Combine
import Foundation
import Moya

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension MoyaProvider {
  /// Designated request-making method.
  ///
  /// - Parameters:
  ///   - target: Entity, which provides specifications necessary for a `MoyaProvider`.
  ///   - callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
  /// - Returns: `AnyPublisher<Response, MoyaError`
  func requestPublisher(
    _ target: Target,
    callbackQueue: DispatchQueue? = nil
  ) -> AnyPublisher<Response, MoyaError> {
    return MoyaPublisher { [weak self] subscriber in
      self?.request(target, callbackQueue: callbackQueue, progress: nil) { result in
        switch result {
        case let .success(response):
          _ = subscriber.receive(response)
          subscriber.receive(completion: .finished)
        case let .failure(error):
          subscriber.receive(completion: .failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
  }

  /// Designated request-making method with progress.
  func requestWithProgressPublisher(
    _ target: Target,
    callbackQueue: DispatchQueue? = nil
  ) -> AnyPublisher<ProgressResponse, MoyaError> {
    let response = MoyaPublisher<ProgressResponse> { [weak self] subscriber in
      let cancellableToken = self?.request(
        target,
        callbackQueue: callbackQueue,
        progress: { progress in
          _ = subscriber.receive(progress)
        }
      ) { result in
        switch result {
        case .success:
          subscriber.receive(completion: .finished)
        case let .failure(error):
          subscriber.receive(completion: .failure(error))
        }
      }

      return cancellableToken
    }

    // Accumulate all progress and combine them when the result comes
    return response.scan(ProgressResponse()) { last, progress in
      let progressObject = progress.progressObject ?? last.progressObject
      let response = progress.response ?? last.response
      return ProgressResponse(progress: progressObject, response: response)
    }
    .eraseToAnyPublisher()
  }
}
