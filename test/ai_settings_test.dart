import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:habit_tracker/features/setting/data/datasources/settings_storage.dart';
import 'package:habit_tracker/features/setting/data/datasources/setting_local_datasource.dart';
import 'package:habit_tracker/features/setting/data/repositories/setting_repository_impl.dart';
import 'package:habit_tracker/features/setting/domain/usecases/get_custom_api_key_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/save_custom_api_key_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/clear_custom_api_key_usecase.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/ai_settings_controller.dart';
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
    Get.reset();
    tempDir = await Directory.systemTemp.createTemp('ai_settings_test_');
    Hive.init(tempDir.path);
    settingsBox = await Hive.openBox(SettingsStorage.boxName);
    langBox = await Hive.openBox('lang_box');

    settingsStorage = SettingsStorage();
    await settingsStorage.init();
    Get.put<SettingsStorage>(settingsStorage);

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
    Get.reset();
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

    test('SettingRepository syncs custom API key with remote data source', () async {
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
    });

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
      'AiSettingsController manages state, maskedKey, and reactions correctly',
      () async {
        final controller = AiSettingsController(
          getCustomApiKeyUseCase: getCustomApiKeyUseCase,
          saveCustomApiKeyUseCase: saveCustomApiKeyUseCase,
          clearCustomApiKeyUseCase: clearCustomApiKeyUseCase,
        );

        expect(controller.isCustom.value, isFalse);
        expect(controller.maskedKey, '');

        // Save valid custom key
        final saved = await controller.saveApiKey('AIzaSyCustomKeyToMask1234');
        expect(saved, isTrue);
        expect(controller.isCustom.value, isTrue);
        expect(controller.customApiKey.value, 'AIzaSyCustomKeyToMask1234');
        expect(controller.maskedKey, 'AIzaSy...1234');

        // Clear key
        await controller.clearApiKey();
        expect(controller.isCustom.value, isFalse);
        expect(controller.customApiKey.value, '');
        expect(controller.maskedKey, '');
      },
    );
  });
}
