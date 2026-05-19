// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionsListHash() => r'34c886910e5a0becc1c1aca505611794b315ac59';

/// See also [sessionsList].
@ProviderFor(sessionsList)
final sessionsListProvider =
    AutoDisposeFutureProvider<List<RecordingSession>>.internal(
  sessionsList,
  name: r'sessionsListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sessionsListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SessionsListRef = AutoDisposeFutureProviderRef<List<RecordingSession>>;
String _$sessionReadingCountHash() =>
    r'44b1434b371c6ec03506e291d1e06abd8595358b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [sessionReadingCount].
@ProviderFor(sessionReadingCount)
const sessionReadingCountProvider = SessionReadingCountFamily();

/// See also [sessionReadingCount].
class SessionReadingCountFamily extends Family<AsyncValue<int>> {
  /// See also [sessionReadingCount].
  const SessionReadingCountFamily();

  /// See also [sessionReadingCount].
  SessionReadingCountProvider call(
    int sessionId,
  ) {
    return SessionReadingCountProvider(
      sessionId,
    );
  }

  @override
  SessionReadingCountProvider getProviderOverride(
    covariant SessionReadingCountProvider provider,
  ) {
    return call(
      provider.sessionId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sessionReadingCountProvider';
}

/// See also [sessionReadingCount].
class SessionReadingCountProvider extends AutoDisposeFutureProvider<int> {
  /// See also [sessionReadingCount].
  SessionReadingCountProvider(
    int sessionId,
  ) : this._internal(
          (ref) => sessionReadingCount(
            ref as SessionReadingCountRef,
            sessionId,
          ),
          from: sessionReadingCountProvider,
          name: r'sessionReadingCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionReadingCountHash,
          dependencies: SessionReadingCountFamily._dependencies,
          allTransitiveDependencies:
              SessionReadingCountFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionReadingCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sessionId,
  }) : super.internal();

  final int sessionId;

  @override
  Override overrideWith(
    FutureOr<int> Function(SessionReadingCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionReadingCountProvider._internal(
        (ref) => create(ref as SessionReadingCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sessionId: sessionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<int> createElement() {
    return _SessionReadingCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionReadingCountProvider && other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sessionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SessionReadingCountRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `sessionId` of this provider.
  int get sessionId;
}

class _SessionReadingCountProviderElement
    extends AutoDisposeFutureProviderElement<int> with SessionReadingCountRef {
  _SessionReadingCountProviderElement(super.provider);

  @override
  int get sessionId => (origin as SessionReadingCountProvider).sessionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
