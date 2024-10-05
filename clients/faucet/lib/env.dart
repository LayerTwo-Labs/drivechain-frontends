class Environment {
  static const apiHost = String.fromEnvironment('FAUCET_API_HOST', defaultValue: 'api.drivechain.live');
  static const apiPort = int.fromEnvironment('FAUCET_API_PORT', defaultValue: 443);
  static const bool grpcSSL = bool.fromEnvironment('FAUCET_GRPC_SSL', defaultValue: true);
}
