import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/core/init/app_initializer.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/core/storage/key_value_storage.dart';
import 'package:habit_tracker/features/home/data/datasources/i_habit_local_data_source.dart';
import 'package:habit_tracker/features/setting/data/datasources/lang_storage.dart';
import 'package:habit_tracker/features/setting/data/datasources/setting_local_datasource.dart';
import 'package:habit_tracker/features/setting/data/datasources/setting_remote_datasource.dart';
import 'package:habit_tracker/features/setting/data/datasources/settings_storage.dart';
import 'package:habit_tracker/features/setting/data/repositories/setting_repository_impl.dart';
import 'package:habit_tracker/features/setting/domain/usecases/get_custom_model_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/save_custom_model_usecase.dart';
import 'package:habit_tracker/features/setting/presentation/providers/setting_providers.dart';
import 'package:habit_tracker/features/setting/presentation/widget/ai_model_selection_dialog.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_storage.dart';
import 'package:habit_tracker/generated/l10n.dart';

class FakeSettingRemoteDataSource implements SettingRemoteDataSource {
  @override
  Future<String?> downloadCustomApiKey() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHabitLocalDataSource implements IHabitLocalDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late KeyValueStorage storage;
  late SettingsStorage settingsStorage;
  late LangStorage langStorage;
  late ThemeStorageService themeStorage;
  late SettingLocalDataSource localDataSource;
  late FakeSettingRemoteDataSource remoteDataSource;
  late SettingRepositoryImpl repository;
  late GetCustomModelUseCase getCustomModelUseCase;
  late SaveCustomModelUseCase saveCustomModelUseCase;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    storage = KeyValueStorage(db);
    await storage.init();

    settingsStorage = SettingsStorage(storage);
    langStorage = LangStorage(storage);
    themeStorage = ThemeStorageService(storage);
    AppInitializer.settingsStorage = settingsStorage;

    localDataSource = SettingLocalDataSourceImpl(
      langStorage: langStorage,
      settingsStorage: settingsStorage,
      themeStorage: themeStorage,
    );

    remoteDataSource = FakeSettingRemoteDataSource();

    repository = SettingRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
      habitLocalDataSource: FakeHabitLocalDataSource(),
    );

    getCustomModelUseCase = GetCustomModelUseCase(repository);
    saveCustomModelUseCase = SaveCustomModelUseCase(repository);

    GeminiService.clearCustomModel();
  });

  tearDown(() async {
    GeminiService.clearCustomModel();
    await db.close();
  });

  group('AI Model Selection - Clean Architecture Tests', () {
    test('SettingLocalDataSource saves and retrieves custom model', () async {
      expect(localDataSource.getCustomGeminiModel(), isNull);

      await localDataSource.saveCustomGeminiModel('gemini-3.8-flash');
      expect(localDataSource.getCustomGeminiModel(), 'gemini-3.8-flash');

      await localDataSource.saveCustomGeminiModel(null);
      expect(localDataSource.getCustomGeminiModel(), isNull);
    });

    test('SettingRepository and UseCases get and save custom model', () async {
      final saveResult = await saveCustomModelUseCase('gemini-3.7-flash');
      expect(saveResult.isRight(), isTrue);

      final getResult = await getCustomModelUseCase();
      expect(getResult.isRight(), isTrue);
      getResult.fold(
        (_) => fail('Expected model'),
        (model) => expect(model, 'gemini-3.7-flash'),
      );
    });

    test('GeminiService.setCustomModel updates effectiveModelName', () {
      expect(GeminiService.effectiveModelName, GeminiService.defaultModelName);

      GeminiService.setCustomModel('gemini-3.5-flash');
      expect(GeminiService.effectiveModelName, 'gemini-3.5-flash');

      GeminiService.clearCustomModel();
      expect(GeminiService.effectiveModelName, GeminiService.defaultModelName);
    });

    test('AiSettingsNotifier loads and saves model via ProviderContainer', () async {
      final container = ProviderContainer(
        overrides: [
          settingRepositoryProvider.overrideWithValue(repository),
          getCustomModelUseCaseProvider.overrideWithValue(getCustomModelUseCase),
          saveCustomModelUseCaseProvider.overrideWithValue(saveCustomModelUseCase),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(aiSettingsNotifierProvider.notifier);

      expect(
        container.read(aiSettingsNotifierProvider).selectedModel,
        GeminiService.defaultModelName,
      );

      final success = await notifier.saveModel('gemini-3.8-flash');
      expect(success, isTrue);
      expect(
        container.read(aiSettingsNotifierProvider).selectedModel,
        'gemini-3.8-flash',
      );

      final resetSuccess = await notifier.resetModelToDefault();
      expect(resetSuccess, isTrue);
      expect(
        container.read(aiSettingsNotifierProvider).selectedModel,
        GeminiService.defaultModelName,
      );
    });
  });

  group('AI Model Selection - Widget Tests', () {
    testWidgets('AiModelSelectionDialog renders preset models and handles selection', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          settingRepositoryProvider.overrideWithValue(repository),
          getCustomModelUseCaseProvider.overrideWithValue(getCustomModelUseCase),
          saveCustomModelUseCaseProvider.overrideWithValue(saveCustomModelUseCase),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: const Scaffold(body: AiModelSelectionDialog()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header and options render
      expect(find.text('Gemini 3.5 Flash Lite'), findsOneWidget);
      expect(find.text('Gemini 3.5 Flash'), findsOneWidget);
      expect(find.text('Gemini 3.8 Flash'), findsOneWidget);

      // Tap on Gemini 3.8 Flash
      await tester.tap(find.text('Gemini 3.8 Flash'));
      await tester.pumpAndSettle();

      // Tap Save button
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(
        container.read(aiSettingsNotifierProvider).selectedModel,
        'gemini-3.8-flash',
      );
    });
  });
}
