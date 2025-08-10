import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn

class LoginService {
    func login(completion: @escaping (Result<User, Error>) -> Void) {
        guard let rootVC = UIApplication.rootViewController else {
            completion(.failure(LoginError.noRootViewController))
            return
        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(LoginError.missingClientID))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(LoginError.missingUserData))
                return
            }
            let accessToken = user.accessToken.tokenString

            print("User signed in:")
            print("Name: \(user.profile?.name ?? "No name")")
            print("Email: \(user.profile?.email ?? "No email")")
            print("UserID: \(user.userID ?? "No userID")")
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let firebaseUser = authResult?.user else {
                    completion(.failure(LoginError.missingFirebaseUser))
                    return
                }
                
                print("Firebase sign-in succeeded with user ID: \(firebaseUser.uid)")
                completion(.success(firebaseUser))
            }
        }
    }
}

enum LoginError: LocalizedError {
    case noRootViewController
    case missingClientID
    case missingUserData
    case missingFirebaseUser
    
    var errorDescription: String? {
        switch self {
        case .noRootViewController: return "No root view controller found."
        case .missingClientID: return "Missing Firebase client ID."
        case .missingUserData: return "Missing user or token data after Google sign-in."
        case .missingFirebaseUser: return "Firebase sign-in succeeded but no user returned."
        }
    }
}
