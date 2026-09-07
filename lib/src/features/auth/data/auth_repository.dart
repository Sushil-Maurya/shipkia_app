import '../../../core/api/api.dart';
import 'auth_session.dart';

class AuthRepository {
  const AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSession> login({required String email, required String password}) {
    return _apiClient.request<AuthSession>(
      ApiRequestConfig(
        method: HttpMethod.post,
        path: ApiEndpoints.auth.login,
        data: {'type': 'email', 'uid': email, 'password': password},
        requiresAuth: false,
        showSuccessMessage: false,
        showErrorMessage: true,
      ),
      fromJson: AuthSession.fromJson,
    );
  }

  Future<void> logout() {
    return _apiClient.request<void>(
      ApiRequestConfig(
        method: HttpMethod.post,
        path: ApiEndpoints.auth.logout,
        showSuccessMessage: true,
        successMessage: 'Logged out successfully.',
        showErrorMessage: true,
      ),
    );
  }

  Future<AuthToken> renewToken() {
    return _apiClient.request<AuthToken>(
      ApiRequestConfig(
        method: HttpMethod.post,
        path: ApiEndpoints.auth.tokenRenew,
        showSuccessMessage: false,
        showErrorMessage: false,
      ),
      fromJson: AuthToken.fromJson,
    );
  }

  Future<AuthProfile> getProfile({String? accessToken}) {
    return _apiClient.request<AuthProfile>(
      ApiRequestConfig(
        method: HttpMethod.get,
        path: ApiEndpoints.profile.current,
        headers: accessToken == null
            ? null
            : {'Authorization': 'Bearer $accessToken'},
        showSuccessMessage: false,
        showErrorMessage: false,
      ),
      fromJson: AuthProfile.fromJson,
    );
  }
}
