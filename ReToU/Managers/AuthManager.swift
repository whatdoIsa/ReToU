//
//  AuthManager.swift
//  ReToU_1
//
//  Created by Dean_SSONG on 4/21/25.
//

import Foundation
import LocalAuthentication

class AuthManager {
    static let shared = AuthManager()

    /// 생체 인증만 시도 (실패 시 앱 자체 비밀번호 폴백은 호출자가 처리)
    func authenticateWithBiometricsOnly(
        onSuccess: @escaping () -> Void,
        onFailure: @escaping () -> Void
    ) {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            DispatchQueue.main.async { onFailure() }
            return
        }

        let reason = "회고 잠금 해제를 위해 인증이 필요합니다"
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
            DispatchQueue.main.async {
                success ? onSuccess() : onFailure()
            }
        }
    }

    // 생체 인증 또는 패스코드 인증 수행
    func authenticateWithBiometricsOrPasscode(
        onSuccess: @escaping () -> Void,
        onFailure: @escaping () -> Void
    ) {
        let context = LAContext()
        var error: NSError?

        // 인증 가능 여부 확인
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Face ID 인증이 필요합니다"
            // 생체 인증 수행
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    // 인증 성공 시 다음 뷰로 전환
                    success ? onSuccess() : self.authenticateWithPasscode(context: context, onSuccess: onSuccess, onFailure: onFailure)
                }
            }
        } else {
            // 실패 시 패스코드 인증으로 대체
            authenticateWithPasscode(context: context, onSuccess: onSuccess, onFailure: onFailure)
        }
    }

    // 패스코드 인증 수행
    private func authenticateWithPasscode(
        context: LAContext,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping () -> Void
    ) {
        let reason = "앱을 사용하려면 인증이 필요합니다."
        // 패스코드 인증 수행
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                // 인증 성공 시 다음 뷰로 전환
                success ? onSuccess() : onFailure()
            }
        }
    }
}
