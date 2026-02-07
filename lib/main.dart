/*
 * Project Management App
 * 
 * THEME SYSTEM:
 * This app now uses a comprehensive theme system that applies the beautiful colors
 * and styling from the home page across all pages. The theme includes:
 * 
 * - Primary colors: Blue gradient (#0158F9 to #02BCF5)
 * - Background gradients with subtle opacity variations
 * - Consistent card styling with rounded corners and shadows
 * - Unified spacing and typography
 * - Dark/light theme support
 * 
 * All pages now automatically inherit:
 * - Beautiful gradient backgrounds
 * - Consistent card decorations
 * - Unified color scheme
 * - Professional typography
 * - Consistent spacing and layout
 * 
 * To use the theme in any page, import:
 * import '../../core/theme/app_theme_helper.dart';
 * 
 * Then use helper methods like:
 * - AppThemeHelper.getBackgroundGradientDecoration(context)
 * - AppThemeHelper.getCardDecoration(context)
 * - AppThemeHelper.getStandardPadding(context)
 */

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:projectmange/presentation/blocs/vendor/vendor_bloc.dart';
import 'package:projectmange/presentation/pages/clients_page.dart';
import 'package:projectmange/presentation/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './firebase_options.dart';
import 'core/constants/app_strings.dart';
import 'core/services/cache_service.dart';
import 'core/theme_notifier.dart';
import 'data/datasources/firebase_auth_datasource.dart';
import 'data/datasources/firestore_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/client_repository_impl.dart';
import 'data/repositories/order_repository_impl.dart';
import 'data/repositories/vendor_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/client_repository.dart';
import 'domain/repositories/order_repository.dart';
import 'domain/repositories/vendor_repository.dart';
import 'domain/usecases/auth_usecases.dart';
import 'domain/usecases/client_usecases.dart';
import 'domain/usecases/order_usecases.dart';
import 'domain/usecases/vendor_usecases.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/client/client_bloc.dart';
import 'presentation/blocs/order/order_bloc.dart';
import 'presentation/pages/auth/debug_auth_page.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/test_image_upload_page.dart';
import 'presentation/themes/app_theme.dart';

final themeNotifier = ThemeNotifier();
final languageNotifier = LanguageNotifier();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize cache service FIRST
  await CacheService.init();
  print('✅ Cache service initialized');

  // Initialize SharedPreferences
  await SharedPreferences.getInstance();

  // await Supabase.initialize(
  //  url: 'https://kfimwgwogtzosvitugqn.supabase.co',
  // anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtmaW13Z3dvZ3R6b3N2aXR1Z3FuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM3NzkyMDUsImV4cCI6MjA2OTM1NTIwNX0.plrYINp8TwApBb3jHtZGlytgn7XDdRsdpJRRQsc7S0k',
  //  );
  // Check if Firebase is already initialized to prevent duplicate app error
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: 'Order Management',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Wait for theme and language to be loaded
  await Future.wait([
    themeNotifier.loadTheme(),
    languageNotifier.loadLanguage(),
  ]);

  runApp(
    ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: languageNotifier,
          builder: (context, locale, _) {
            return MyApp(themeMode: mode, locale: locale);
          },
        );
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;
  final Locale locale;

  const MyApp({super.key, required this.themeMode, required this.locale});

  @override
  Widget build(BuildContext context) {
    // Update the app strings locale
    AppStrings.setLocale(locale);

    return MultiBlocProvider(
      providers: [
        // Data sources
        Provider<FirebaseAuthDataSource>(
          create: (context) => FirebaseAuthDataSourceImpl(),
        ),
        Provider<FirestoreDataSource>(
          create: (context) => FirestoreDataSourceImpl(),
        ),

        // Repositories
        Provider<AuthRepository>(
          create:
              (context) => AuthRepositoryImpl(
                authDataSource: context.read<FirebaseAuthDataSource>(),
                firestoreDataSource: context.read<FirestoreDataSource>(),
              ),
        ),
        Provider<OrderRepository>(
          create:
              (context) => OrderRepositoryImpl(
                firestoreDataSource: context.read<FirestoreDataSource>(),
              ),
        ),
        Provider<VendorRepository>(
          create:
              (context) => VendorRepositoryImpl(
                firestoreDataSource: context.read<FirestoreDataSource>(),
              ),
        ),
        Provider<ClientRepository>(
          create:
              (context) => ClientRepositoryImpl(
                firestoreDataSource: context.read<FirestoreDataSource>(),
              ),
        ),

        // Use cases
        Provider<SignInWithEmailAndPasswordUseCase>(
          create:
              (context) => SignInWithEmailAndPasswordUseCase(
                context.read<AuthRepository>(),
              ),
        ),
        Provider<SignUpWithEmailAndPasswordUseCase>(
          create:
              (context) => SignUpWithEmailAndPasswordUseCase(
                context.read<AuthRepository>(),
              ),
        ),
        Provider<SignInWithGoogleUseCase>(
          create:
              (context) =>
                  SignInWithGoogleUseCase(context.read<AuthRepository>()),
        ),
        Provider<SignOutUseCase>(
          create: (context) => SignOutUseCase(context.read<AuthRepository>()),
        ),
        Provider<GetCurrentUserUseCase>(
          create:
              (context) =>
                  GetCurrentUserUseCase(context.read<AuthRepository>()),
        ),
        Provider<GetAuthStateChangesUseCase>(
          create:
              (context) =>
                  GetAuthStateChangesUseCase(context.read<AuthRepository>()),
        ),
        Provider<SaveUserToFirestoreUseCase>(
          create:
              (context) =>
                  SaveUserToFirestoreUseCase(context.read<AuthRepository>()),
        ),
        Provider<IncrementUserOrderCountUseCase>(
          create:
              (context) => IncrementUserOrderCountUseCase(
                context.read<AuthRepository>(),
              ),
        ), // Order use cases
        Provider<GetOrdersUseCase>(
          create:
              (context) => GetOrdersUseCase(context.read<OrderRepository>()),
        ),
        Provider<GetOrdersByStatusUseCase>(
          create:
              (context) =>
                  GetOrdersByStatusUseCase(context.read<OrderRepository>()),
        ),
        Provider<GetOrderUseCase>(
          create: (context) => GetOrderUseCase(context.read<OrderRepository>()),
        ),
        Provider<CreateOrderUseCase>(
          create:
              (context) => CreateOrderUseCase(context.read<OrderRepository>()),
        ),
        Provider<UpdateOrderUseCase>(
          create:
              (context) => UpdateOrderUseCase(context.read<OrderRepository>()),
        ),
        Provider<UpdateClientReceivedUseCase>(
          create:
              (context) =>
                  UpdateClientReceivedUseCase(context.read<OrderRepository>()),
        ),
        Provider<DeleteOrderUseCase>(
          create:
              (context) => DeleteOrderUseCase(context.read<OrderRepository>()),
        ),
        Provider<DeleteCompletedOrdersUseCase>(
          create:
              (context) =>
                  DeleteCompletedOrdersUseCase(context.read<OrderRepository>()),
        ),
        Provider<UploadImagesForClientUseCase>(
          create:
              (context) =>
                  UploadImagesForClientUseCase(context.read<OrderRepository>()),
        ),
        Provider<DeleteOrderImagesUseCase>(
          create:
              (context) =>
                  DeleteOrderImagesUseCase(context.read<OrderRepository>()),
        ),

        // Vendor use cases
        Provider<GetVendorsUseCase>(
          create:
              (context) => GetVendorsUseCase(context.read<VendorRepository>()),
        ),
        Provider<GetVendorUseCase>(
          create:
              (context) => GetVendorUseCase(context.read<VendorRepository>()),
        ),
        Provider<CreateVendorUseCase>(
          create:
              (context) =>
                  CreateVendorUseCase(context.read<VendorRepository>()),
        ),
        Provider<UpdateVendorUseCase>(
          create:
              (context) =>
                  UpdateVendorUseCase(context.read<VendorRepository>()),
        ),
        Provider<DeleteVendorUseCase>(
          create:
              (context) =>
                  DeleteVendorUseCase(context.read<VendorRepository>()),
        ),

        // Client use cases
        Provider<GetClientsUseCase>(
          create:
              (context) => GetClientsUseCase(context.read<ClientRepository>()),
        ),
        Provider<GetClientUseCase>(
          create:
              (context) => GetClientUseCase(context.read<ClientRepository>()),
        ),
        Provider<GetClientByNameAndPhoneUseCase>(
          create:
              (context) => GetClientByNameAndPhoneUseCase(
                context.read<ClientRepository>(),
              ),
        ),
        Provider<CreateClientUseCase>(
          create:
              (context) =>
                  CreateClientUseCase(context.read<ClientRepository>()),
        ),
        Provider<UpdateClientUseCase>(
          create:
              (context) =>
                  UpdateClientUseCase(context.read<ClientRepository>()),
        ),
        Provider<DeleteClientUseCase>(
          create:
              (context) =>
                  DeleteClientUseCase(context.read<ClientRepository>()),
        ),
        Provider<DeleteClientsByNameAndPhoneUseCase>(
          create:
              (context) => DeleteClientsByNameAndPhoneUseCase(
                context.read<ClientRepository>(),
              ),
        ),

        // Blocs
        BlocProvider<AuthBloc>(
          create:
              (context) => AuthBloc(
                signInWithEmailAndPassword:
                    context.read<SignInWithEmailAndPasswordUseCase>(),
                signUpWithEmailAndPassword:
                    context.read<SignUpWithEmailAndPasswordUseCase>(),
                signInWithGoogle: context.read<SignInWithGoogleUseCase>(),
                signOut: context.read<SignOutUseCase>(),
                getCurrentUser: context.read<GetCurrentUserUseCase>(),
                getAuthStateChanges: context.read<GetAuthStateChangesUseCase>(),
                saveUserToFirestore: context.read<SaveUserToFirestoreUseCase>(),
              ),
        ),
        BlocProvider<OrderBloc>(
          create:
              (context) => OrderBloc(
                getOrders: context.read<GetOrdersUseCase>(),
                getOrdersByStatus: context.read<GetOrdersByStatusUseCase>(),
                getOrder: context.read<GetOrderUseCase>(),
                createOrder: context.read<CreateOrderUseCase>(),
                updateOrder: context.read<UpdateOrderUseCase>(),
                updateClientReceived:
                    context.read<UpdateClientReceivedUseCase>(),
                uploadImagesForClient:
                    context.read<UploadImagesForClientUseCase>(),
                deleteOrder: context.read<DeleteOrderUseCase>(),
                deleteCompletedOrders:
                    context.read<DeleteCompletedOrdersUseCase>(),
                deleteClientsByNameAndPhone:
                    context.read<DeleteClientsByNameAndPhoneUseCase>(),
                getCurrentUser: context.read<GetCurrentUserUseCase>(),
                incrementUserOrderCount:
                    context.read<IncrementUserOrderCountUseCase>(),
              ),
        ),
        BlocProvider<ClientBloc>(
          create:
              (context) => ClientBloc(
                getClients: context.read<GetClientsUseCase>(),
                getClient: context.read<GetClientUseCase>(),
                createClient: context.read<CreateClientUseCase>(),
                updateClient: context.read<UpdateClientUseCase>(),
                deleteClient: context.read<DeleteClientUseCase>(),
                deleteClientsByNameAndPhone:
                    context.read<DeleteClientsByNameAndPhoneUseCase>(),
              ),
        ),
        BlocProvider<VendorBloc>(
          create:
              (context) => VendorBloc(
                getVendors: context.read<GetVendorsUseCase>(),
                getVendor: context.read<GetVendorUseCase>(),
                createVendor: context.read<CreateVendorUseCase>(),
                updateVendor: context.read<UpdateVendorUseCase>(),
                deleteVendor: context.read<DeleteVendorUseCase>(),
              ),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        locale: locale,
        supportedLocales: AppStrings.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashPage(),
        routes: {
          '/home': (context) => const HomePage(),
          '/clients': (context) => ClientsPage(),
          '/debug-auth': (context) => const DebugAuthPage(),
          '/test-image-upload': (context) => const TestImageUploadPage(),
          // add other routes here
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
