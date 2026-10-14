import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:habit_tracker/core/init/app_initializer.dart';
import 'package:habit_tracker/features/setting/data/datasources/settings_storage.dart';
import 'package:habit_tracker/features/setting/data/datasources/setting_local_datasource.dart';
import 'package:habit_tracker/features/setting/data/repositories/setting_repository_impl.dart';
import 'package:habit_tracker/features/setting/domain/usecases/get_custom_api_key_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/save_custom_api_key_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/clear_custom_api_key_usecase.dart';
import 'package:habit_tracker/features/setting/presentation/providers/setting_providers.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/features/setting/data/datasources/setting_remote_datasource.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_local_data_source.dart';

// Minimal mock/fake for dependencies not under test
class FakeSettingRemoteDataSource implements SettingRemoteDataSource {
  String? cloudApiKey;

  @override
  Future<void> uploadCustomApiKey(String key) async {
    cloudApiKey = key;
  }

  @override
  Future<String?> downloadCustomApiKey() async {
    return cloudApiKey;
  }

  @override
  Future<void> deleteCustomApiKey() async {
    cloudApiKey = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHabitLocalDataSource implements HabitLocalDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box settingsBox;
  late Box langBox;
  late SettingsStorage settingsStorage;
  late SettingLocalDataSource localDataSource;
  late FakeSettingRemoteDataSource remoteDataSource;
  late SettingRepositoryImpl repository;
  late GetCustomApiKeyUseCase getCustomApiKeyUseCase;
  late SaveCustomApiKeyUseCase saveCustomApiKeyUseCase;
  late ClearCustomApiKeyUseCase clearCustomApiKeyUseCase;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ai_settings_test_');
    Hive.init(tempDir.path);
    settingsBox = await Hive.openBox(SettingsStorage.boxName);
    langBox = await Hive.openBox('lang_box');

    settingsStorage = SettingsStorage();
    await settingsStorage.init();
    AppInitializer.settingsStorage = settingsStorage;

    localDataSource = SettingLocalDataSourceImpl(
      langBox: langBox,
      settingsBox: settingsBox,
    );

    remoteDataSource = FakeSettingRemoteDataSource();

    repository = SettingRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
      habitLocalDataSource: FakeHabitLocalDataSource(),
    );

    getCustomApiKeyUseCase = GetCustomApiKeyUseCase(repository);
    saveCustomApiKeyUseCase = SaveCustomApiKeyUseCase(repository);
    clearCustomApiKeyUseCase = ClearCustomApiKeyUseCase(repository);
  });

  tearDown(() async {
    dotenv.clean();
    await settingsBox.close();
    await langBox.close();
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('AI Settings - Clean Architecture & Custom API Key Tests', () {
    test(
      'SettingsStorage correctly saves, gets, and clears custom API key',
      () async {
        expect(settingsStorage.customGeminiApiKey, isNull);

        await settingsStorage.setCustomGeminiApiKey('AIzaSyCustomKey123456');
        expect(settingsStorage.customGeminiApiKey, 'AIzaSyCustomKey123456');

        await settingsStorage.clearCustomGeminiApiKey();
        expect(settingsStorage.customGeminiApiKey, isNull);
      },
    );

    test('SettingLocalDataSource saves and retrieves custom API key', () async {
      await localDataSource.saveCustomGeminiApiKey('AIzaSyTestFromLocalDS');
      expect(localDataSource.getCustomGeminiApiKey(), 'AIzaSyTestFromLocalDS');

      await localDataSource.clearCustomGeminiApiKey();
      expect(localDataSource.getCustomGeminiApiKey(), isNull);
    });

    test('SettingRepository and UseCases interact properly', () async {
      final saveResult = await saveCustomApiKeyUseCase(
        'AIzaSyRepositoryKey999',
      );
      expect(saveResult.isRight(), isTrue);

      final getResult = await getCustomApiKeyUseCase();
      expect(getResult.isRight(), isTrue);
      getResult.fold(
        (_) => fail('Expected key'),
        (key) => expect(key, 'AIzaSyRepositoryKey999'),
      );

      final clearResult = await clearCustomApiKeyUseCase();
      expect(clearResult.isRight(), isTrue);

      final getAfterClear = await getCustomApiKeyUseCase();
      getAfterClear.fold(
        (_) => fail('Expected null'),
        (key) => expect(key, isNull),
      );
    });

    test(
      'SettingRepository syncs custom API key with remote data source',
      () async {
        // 1. Saving key uploads to remote
        final saveResult = await saveCustomApiKeyUseCase('AIzaSyCloudKey123');
        expect(saveResult.isRight(), isTrue);
        expect(remoteDataSource.cloudApiKey, 'AIzaSyCloudKey123');

        // 2. Clear local storage, getting key restores from remote
        await localDataSource.clearCustomGeminiApiKey();
        expect(localDataSource.getCustomGeminiApiKey(), isNull);

        final getResult = await getCustomApiKeyUseCase();
        expect(getResult.isRight(), isTrue);
        getResult.fold(
          (_) => fail('Expected key from remote'),
          (key) => expect(key, 'AIzaSyCloudKey123'),
        );
        // It should also cache it back to local
        expect(localDataSource.getCustomGeminiApiKey(), 'AIzaSyCloudKey123');

        // 3. Clearing key removes from remote as well
        final clearResult = await clearCustomApiKeyUseCase();
        expect(clearResult.isRight(), isTrue);
        expect(remoteDataSource.cloudApiKey, isNull);
      },
    );

    test(
      'GeminiService prioritizes custom API key over dotenv default',
      () async {
        dotenv.loadFromString(
          envString: 'GEMINI_API_KEY=AIzaSyDefaultFromDotenv',
        );
        expect(GeminiService.currentApiKey, 'AIzaSyDefaultFromDotenv');
        expect(GeminiService.hasCustomApiKey, isFalse);

        // Now set a custom key
        await settingsStorage.setCustomGeminiApiKey('AIzaSyUserCustomKey');
        expect(GeminiService.currentApiKey, 'AIzaSyUserCustomKey');
        expect(GeminiService.hasCustomApiKey, isTrue);

        // Chat session starts with custom key
        final service = GeminiService();
        final session = service.startChat();
        expect(session, isNotNull);

        // Clear custom key -> reverts to dotenv
        await settingsStorage.clearCustomGeminiApiKey();
        expect(GeminiService.currentApiKey, 'AIzaSyDefaultFromDotenv');
        expect(GeminiService.hasCustomApiKey, isFalse);
      },
    );

    test(
      'AiSettingsState manages maskedKey correctly',
      () {
        const emptyState = AiSettingsState();
        expect(emptyState.isCustom, isFalse);
        expect(emptyState.maskedKey, '');

        const shortState = AiSettingsState(customApiKey: '12345');
        expect(shortState.maskedKey, '••••••••');

        const filledState = AiSettingsState(
          customApiKey: 'AIzaSyCustomKeyToMask1234',
          isCustom: true,
        );
        expect(filledState.isCustom, isTrue);
        expect(filledState.customApiKey, 'AIzaSyCustomKeyToMask1234');
        expect(filledState.maskedKey, 'AIzaSy...1234');
      },
    );

    test(
      'AiSettingsNotifier loads, saves, and clears API key via ProviderContainer',
      () async {
        final container = ProviderContainer(
          overrides: [
            settingRepositoryProvider.overrideWithValue(repository),
            getCustomApiKeyUseCaseProvider.overrideWithValue(getCustomApiKeyUseCase),
            saveCustomApiKeyUseCaseProvider.overrideWithValue(saveCustomApiKeyUseCase),
            clearCustomApiKeyUseCaseProvider.overrideWithValue(clearCustomApiKeyUseCase),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(aiSettingsNotifierProvider.notifier);
        expect(container.read(aiSettingsNotifierProvider).isCustom, isFalse);

        // Save valid custom key directly to repository
        await saveCustomApiKeyUseCase('AIzaSyCustomKeyToMask1234');
        await notifier.loadApiKey();

        var state = container.read(aiSettingsNotifierProvider);
        expect(state.isCustom, isTrue);
        expect(state.customApiKey, 'AIzaSyCustomKeyToMask1234');
        expect(state.maskedKey, 'AIzaSy...1234');

        // Clear key
        await notifier.clearApiKey();
        state = container.read(aiSettingsNotifierProvider);
        expect(state.isCustom, isFalse);
        expect(state.customApiKey, '');
        expect(state.maskedKey, '');
      },
    );

    test('GeminiService.sanitizeApiKey cleans quotes, prefixes, and whitespaces', () {
      expect(GeminiService.sanitizeApiKey('  AIzaSyCleanKey  '), 'AIzaSyCleanKey');
      expect(GeminiService.sanitizeApiKey('"AIzaSyQuotedKey"'), 'AIzaSyQuotedKey');
      expect(GeminiService.sanitizeApiKey("'AIzaSySingleQuote'"), 'AIzaSySingleQuote');
      expect(GeminiService.sanitizeApiKey('GEMINI_API_KEY=AIzaSyAssigned'), 'AIzaSyAssigned');
      expect(GeminiService.sanitizeApiKey('api_key="AIzaSyAssignedQuoted"'), 'AIzaSyAssignedQuoted');
    });

    test('SettingsStorage correctly saves, retrieves, and clears custom Gemini model', () async {
      expect(settingsStorage.customGeminiModel, isNull);
      await settingsStorage.setCustomGeminiModel('gemini-3.8-flash');
      expect(settingsStorage.customGeminiModel, 'gemini-3.8-flash');
      expect(GeminiService.effectiveModelName, 'gemini-3.8-flash');

      // Clearing custom API key also clears model
      await settingsStorage.clearCustomGeminiApiKey();
      expect(settingsStorage.customGeminiModel, isNull);
      GeminiService.resetModelInstance();
      expect(GeminiService.effectiveModelName, GeminiService.defaultModelName);
    });
  });
}
