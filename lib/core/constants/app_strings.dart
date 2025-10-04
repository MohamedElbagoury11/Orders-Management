import 'package:flutter/material.dart';

class AppStrings {
  static const Locale english = Locale('en', 'US');
  static const Locale arabic = Locale('ar', 'SA');
  
  static const List<Locale> supportedLocales = [english, arabic];

  // App Name
  static String get appName => _getString('appName');
  
  // Authentication
  static String get login => _getString('login');
  static String get signUp => _getString('signUp');
  static String get email => _getString('email');
  static String get password => _getString('password');
  static String get confirmPassword => _getString('confirmPassword');
  static String get forgotPassword => _getString('forgotPassword');
  static String get dontHaveAccount => _getString('dontHaveAccount');
  static String get alreadyHaveAccount => _getString('alreadyHaveAccount');
  static String get signInWithGoogle => _getString('signInWithGoogle');
  
  // Home Categories
  static String get vendors => _getString('vendors');
  static String get clients => _getString('clients');
  static String get orders => _getString('orders');
  
  // Vendors
  static String get vendorName => _getString('vendorName');
  static String get phoneNumber => _getString('phoneNumber');
  static String get viewOrders => _getString('viewOrders');
  static String get addOrder => _getString('addOrder');
  static String get addVendor => _getString('addVendor');
  static String get editVendor => _getString('editVendor');
  static String get deleteVendor => _getString('deleteVendor');
  static String get searchVendors => _getString('searchVendors');
  
  // Orders
   static String get remaining => _getString('remaining');
   static String get paymentDetails=> _getString('paymentDetails');
  static String get orderDetails => _getString('orderDetails');
  static String get piecesNumber => _getString('piecesNumber');
  static String get totalPurchasePrice => _getString('totalPurchasePrice');
  static String get totalSalesPrice => _getString('totalSalesPrice');
  static String get charge => _getString('charge');
  static String get deposit => _getString('deposit');
  static String get netProfit => _getString('netProfit');
  static String get orderDate => _getString('orderDate');
  static String get orderStatus => _getString('orderStatus');
  static String get working => _getString('working');
  static String get end => _getString('end');
  static String get pending => _getString('pending');
  static String get received => _getString('received');
  static String get addNewOrder => _getString('addNewOrder');
  static String get deleteOrder => _getString('deleteOrder');
  
  // Clients
  static String get clientName => _getString('clientName');
  static String get address => _getString('address');
  static String get addClient => _getString('addClient');
  static String get editClient => _getString('editClient');
  static String get deleteClient => _getString('deleteClient');
  static String get searchClients => _getString('searchClients');
  static String get selectVendor => _getString('selectVendor');
  
  // Common
  static String get save => _getString('save');
  static String get cancel => _getString('cancel');
  static String get delete => _getString('delete');
  static String get edit => _getString('edit');
  static String get submit => _getString('submit');
  static String get total => _getString('total');
  static String get period => _getString('period');
  
  // Messages
  static String get orderDeletedSuccessfully => _getString('orderDeletedSuccessfully');
  static String get clientDeletedSuccessfully => _getString('clientDeletedSuccessfully');
  static String get vendorDeletedSuccessfully => _getString('vendorDeletedSuccessfully');
  static String get orderAddedSuccessfully => _getString('orderAddedSuccessfully');
  static String get clientAddedSuccessfully => _getString('clientAddedSuccessfully');
  static String get vendorAddedSuccessfully => _getString('vendorAddedSuccessfully');
  static String get errorOccurred => _getString('errorOccurred');
  static String get noOrdersFound => _getString('noOrdersFound');
  static String get noClientsFound => _getString('noClientsFound');
  static String get noVendorsFound => _getString('noVendorsFound');

  // Home Page
  static String get dashboard => _getString('dashboard');
  static String get manageBusinessEfficiently => _getString('manageBusinessEfficiently');
  static String get welcomeBack => _getString('welcomeBack');
  static String get readyToManageOrders => _getString('readyToManageOrders');
  static String get totalOrders => _getString('totalOrders');
  static String get activeClients => _getString('activeClients');
  static String get quickActions => _getString('quickActions');
  static String get collectOrder => _getString('collectOrder');
  static String get createNewOrders => _getString('createNewOrders');
  static String get viewAllOrders => _getString('viewAllOrders');
  static String get manageClients => _getString('manageClients');
  static String get manageVendors => _getString('manageVendors');
  static String get viewBills => _getString('viewBills');
  static String get analytics => _getString('analytics');
  static String get viewReports => _getString('viewReports');
  static String get analyticsComingSoon => _getString('analyticsComingSoon');
  static String get language => _getString('language');
  static String get englishLanguage => _getString('englishLanguage');
  static String get arabicLanguage => _getString('arabicLanguage');
  static String get tryAdjustingSearchTerms => _getString('tryAdjustingSearchTerms');
  static String get vendorsWillAppearHere => _getString('vendorsWillAppearHere');
  static String get resultsFound => _getString('resultsFound');
  static String get resultFound => _getString('resultFound');
  static String get errorLoadingVendors => _getString('errorLoadingVendors');
  static String get retry => _getString('retry');
  static String get ordersHistory => _getString('ordersHistory');
  static String get clientsDeletedSuccessfully => _getString('clientsDeletedSuccessfully');
  static String get addYourFirstClient => _getString('addYourFirstClient');
  static String get errorLoadingClients => _getString('errorLoadingClients');
  static String get deleteClients => _getString('deleteClients');
  static String get addNewClient => _getString('addNewClient');
  static String get name => _getString('name');
  static String get pleaseEnterName => _getString('pleaseEnterName');
  static String get pleaseEnterPhoneNumber => _getString('pleaseEnterPhoneNumber');
  static String get pleaseEnterAddress => _getString('pleaseEnterAddress');
  static String get collect => _getString('collect');
  static String get close => _getString('close');
  static String get vendorInformation => _getString('vendorInformation');
  static String get phone => _getString('phone');
  static String get financialSummary => _getString('financialSummary');
  static String get totalPurchase => _getString('totalPurchase');
  static String get totalSale => _getString('totalSale');
  static String get pieces => _getString('pieces');
  static String get purchase => _getString('purchase');
  static String get sale => _getString('sale');
  static String get signInToContinue => _getString('signInToContinue');
  static String get pleaseEnterEmail => _getString('pleaseEnterEmail');
  static String get pleaseEnterValidEmail => _getString('pleaseEnterValidEmail');
  static String get pleaseEnterPassword => _getString('pleaseEnterPassword');
  static String get or => _getString('or');
  static String get debugAuth => _getString('debugAuth');
  static String get createAccount => _getString('createAccount');
  static String get pleaseFillDetails => _getString('pleaseFillDetails');
  static String get fullName => _getString('fullName');
  static String get pleaseEnterFullName => _getString('pleaseEnterFullName');
  static String get pleaseConfirmPassword => _getString('pleaseConfirmPassword');
  static String get passwordsDoNotMatch => _getString('passwordsDoNotMatch');
  static String get signIn => _getString('signIn');

  // Bills Page
  static String get dateRangeFilter => _getString('dateRangeFilter');
  static String get selectRange => _getString('selectRange');
  static String get allCompletedOrders => _getString('allCompletedOrders');
  static String get totalCharges => _getString('totalCharges');
  static String get completedOrders => _getString('completedOrders');
  static String get noCompletedOrdersFound => _getString('noCompletedOrdersFound');
  static String get completeSomeOrders => _getString('completeSomeOrders');
  static String get orderNumber => _getString('orderNumber');
  static String get vendor => _getString('vendor');
  static String get date => _getString('date');
  static String get profit => _getString('profit');
  static String get sales => _getString('sales');

  // Orders Page
  static String get filterByStatus => _getString('filterByStatus');
  static String get complete => _getString('complete');
  static String get collectDone => _getString('collectDone');
  static String get areYouSureCollect => _getString('areYouSureCollect');
  static String get orderUpdatedSuccessfully => _getString('orderUpdatedSuccessfully');
  static String get errorLoadingOrders => _getString('errorLoadingOrders');
  static String get refresh => _getString('refresh');
  static String get orderStatusChip => _getString('orderStatusChip');
  static String get netProfitHighlight => _getString('netProfitHighlight');
  static String get clientsSection => _getString('clientsSection');
  static String get clientInformation => _getString('clientInformation');
  static String get orderInformation => _getString('orderInformation');
  static String get vendorPhone => _getString('vendorPhone');
  static String get receivedStatus => _getString('receivedStatus');
  static String get yes => _getString('yes');
  static String get no => _getString('no');
  static String get purchasePrice => _getString('purchasePrice');
  static String get salePrice => _getString('salePrice');
  static String get clientProfit => _getString('clientProfit');

  // Order Collection Page
  static String get editOrder => _getString('editOrder');
  static String get collectOrderTitle => _getString('collectOrderTitle');
  static String get vendorPhoneNumber => _getString('vendorPhoneNumber');
  static String get pleaseEnterVendorName => _getString('pleaseEnterVendorName');
  static String get pleaseEnterVendorPhone => _getString('pleaseEnterVendorPhone');
  static String get pleaseEnterChargeAmount => _getString('pleaseEnterChargeAmount');
  static String get pleaseEnterValidNumber => _getString('pleaseEnterValidNumber');
  static String get clientsSectionTitle => _getString('clientsSectionTitle');
  static String get noClientsAddedYet => _getString('noClientsAddedYet');
  static String get orderSummary => _getString('orderSummary');
  static String get saveChanges => _getString('saveChanges');
  static String get createOrder => _getString('createOrder');
  static String get pleaseAddAtLeastOneClient => _getString('pleaseAddAtLeastOneClient');
  static String get great => _getString('great');
  static String get yourChangesUpdated => _getString('yourChangesUpdated');
  static String get orderCreatedSuccessfully => _getString('orderCreatedSuccessfully');
  static String get addClientDialog => _getString('addClientDialog');
  static String get editClientDialog => _getString('editClientDialog');
  static String get pleaseEnterPhone => _getString('pleaseEnterPhone');
  static String get pleaseEnterPiecesNumber => _getString('pleaseEnterPiecesNumber');
  static String get pleaseEnterPurchasePrice => _getString('pleaseEnterPurchasePrice');
  static String get pleaseEnterSalePrice => _getString('pleaseEnterSalePrice');

  // Client Orders Page
  static String get clientOrders => _getString('clientOrders');
  static String get loadingOrders => _getString('loadingOrders');
  static String get clientHasntPlacedOrders => _getString('clientHasntPlacedOrders');
  static String get errorLoadingOrdersTitle => _getString('errorLoadingOrdersTitle');
  static String get status => _getString('status');
  static String get notReceived => _getString('notReceived');

  // Language context
  static Locale? _currentLocale;
  
  static void setLocale(Locale locale) {
    _currentLocale = locale;
  }
  
  static String _getString(String key) {
    final locale = _currentLocale ?? const Locale('en', 'US');
    final isArabic = locale.languageCode == 'ar';
    
    return _translations[isArabic ? 'ar' : 'en']?[key] ?? key;
  }

 // static const String paymentDetails = 'Payment Details';

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'appName': 'All She Needs',
      'login': 'Login',
      'signUp': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'forgotPassword': 'Forgot Password?',
      'dontHaveAccount': "Don't have an account?",
      'alreadyHaveAccount': 'Already have an account?',
      'signInWithGoogle': 'Sign in with Google',
      'vendors': 'Vendors',
      'clients': 'Clients',
      'orders': 'Orders',
      'vendorName': 'Vendor Name',
      'phoneNumber': 'Phone Number',
      'viewOrders': 'View Orders',
      'addOrder': 'Add Order',
      'addVendor': 'Add Vendor',
      'editVendor': 'Edit Vendor',
      'deleteVendor': 'Delete Vendor',
      'searchVendors': 'Search vendors...',
      'orderDetails': 'Order Details',
      'piecesNumber': 'Pieces Number',
      'totalPurchasePrice': 'Total Purchase Price',
      'totalSalesPrice': 'Total Sales Price',
      'charge': 'Charge',
      'deposit': 'Deposit',
      'netProfit': 'Net Profit',
      'orderDate': 'Order Date',
      'orderStatus': 'Order Status',
      'working': 'Working',
      'end': 'End',
      'pending': 'Pending',
      'received': 'Received',
      'addNewOrder': 'Add New Order',
      'deleteOrder': 'Delete Order',
      'clientName': 'Client Name',
      'address': 'Address',
      'addClient': 'Add Client',
      'editClient': 'Edit Client',
      'deleteClient': 'Delete Client',
      'searchClients': 'Search clients...',
      'selectVendor': 'Select Vendor',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'submit': 'Submit',
      'total': 'Total',
      'period': 'Period',
      'orderDeletedSuccessfully': 'Order deleted successfully',
      'clientDeletedSuccessfully': 'Client deleted successfully',
      'vendorDeletedSuccessfully': 'Vendor deleted successfully',
      'orderAddedSuccessfully': 'Order added successfully',
      'clientAddedSuccessfully': 'Client added successfully',
      'vendorAddedSuccessfully': 'Vendor added successfully',
      'errorOccurred': 'An error occurred',
      'noOrdersFound': 'No orders found',
      'noClientsFound': 'No clients found',
      'noVendorsFound': 'No vendors found',
      'dashboard': 'Dashboard',
      'manageBusinessEfficiently': 'Manage your business efficiently',
      'welcomeBack': 'Welcome back!',
      'readyToManageOrders': 'Ready to manage your orders and grow your business?',
             'totalOrders': 'Total Orders',
       'activeClients': 'Active Clients',
       'quickActions': 'Quick Actions',
      'collectOrder': 'Collect Order',
      'createNewOrders': 'Create new orders',
      'viewAllOrders': 'View all orders',
      'manageClients': 'Manage clients',
      'manageVendors': 'Manage vendors',
      'viewBills': 'View bills',
      'analytics': 'Analytics',
      'viewReports': 'View reports',
      'analyticsComingSoon': 'Analytics feature coming soon!',
             'language': 'Language',
       'englishLanguage': 'English',
       'arabicLanguage': 'العربية',
       'tryAdjustingSearchTerms': 'Try adjusting your search terms',
       'vendorsWillAppearHere': 'Vendors will appear here once orders are added',
       'resultsFound': 'results found',
       'resultFound': 'result found',
       'errorLoadingVendors': 'Error Loading Vendors',
       'retry': 'Retry',
       'ordersHistory': 'Orders History',
       'clientsDeletedSuccessfully': 'Clients deleted successfully',
       'addYourFirstClient': 'Add your first client to get started',
       'errorLoadingClients': 'Error Loading Clients',
       'deleteClients': 'Delete Clients',
       'addNewClient': 'Add New Client',
       'name': 'Name',
       'pleaseEnterName': 'Please enter a name',
       'pleaseEnterPhoneNumber': 'Please enter a phone number',
       'pleaseEnterAddress': 'Please enter an address',
       'collect': 'Collect',
       'close': 'Close',
       'vendorInformation': 'Vendor Information',
       'phone': 'Phone',
       'financialSummary': 'Financial Summary',
       'totalPurchase': 'Total Purchase',
       'totalSale': 'Total Sale',
       'pieces': 'Pieces',
       'purchase': 'Purchase',
       'sale': 'Sale',
       'signInToContinue': 'Sign in to continue to your account',
       'pleaseEnterEmail': 'Please enter your email',
       'pleaseEnterValidEmail': 'Please enter a valid email',
       'pleaseEnterPassword': 'Please enter your password',
       'or': 'OR',
       'debugAuth': 'Debug Auth',
       'createAccount': 'Create Account',
       'pleaseFillDetails': 'Please fill in the details below to create your account',
       'fullName': 'Full Name',
       'pleaseEnterFullName': 'Please enter your full name',
       'pleaseConfirmPassword': 'Please confirm your password',
             'passwordsDoNotMatch': 'Passwords do not match',
      'signIn': 'Sign In',
      'dateRangeFilter': 'Date Range Filter',
      'selectRange': 'Select Range',
      'allCompletedOrders': 'All completed orders',
      'totalCharges': 'Total Charges',
      'completedOrders': 'Completed Orders',
      'noCompletedOrdersFound': 'No completed orders found',
      'completeSomeOrders': 'Complete some orders to see financial data',
      'orderNumber': 'Order #',
      'vendor': 'Vendor',
      'date': 'Date',
      'profit': 'Profit',
      'sales': 'Sales',
      'filterByStatus': 'Filter by status:',
      'complete': 'Complete',
      'collectDone': 'Collect/Done',
      'areYouSureCollect': 'Are you sure you want to mark order for',
      'orderUpdatedSuccessfully': 'Order updated successfully',
      'errorLoadingOrders': 'Error Loading Orders',
      'refresh': 'Refresh',
      'orderStatusChip': 'Order Status',
      'netProfitHighlight': 'Net Profit',
      'clientsSection': 'Clients',
      'clientInformation': 'Client Information',
      'orderInformation': 'Order Information',
      'vendorPhone': 'Vendor Phone',
      'receivedStatus': 'Received',
      'yes': 'Yes',
      'no': 'No',
      'purchasePrice': 'Purchase Price',
      'salePrice': 'Sale Price',
      'clientProfit': 'Profit',
      'editOrder': 'Edit Order',
      'collectOrderTitle': 'Collect Order',
      'vendorPhoneNumber': 'Vendor Phone',
      'pleaseEnterVendorName': 'Please enter vendor name',
      'pleaseEnterVendorPhone': 'Please enter vendor phone',
      'pleaseEnterChargeAmount': 'Please enter charge amount',
      'pleaseEnterValidNumber': 'Please enter a valid number',
      'clientsSectionTitle': 'Clients',
      'noClientsAddedYet': 'No clients added yet',
      'orderSummary': 'Order Summary',
      'saveChanges': 'Save Changes',
      'createOrder': 'Create Order',
      'pleaseAddAtLeastOneClient': 'Please add at least one client',
      'great': 'Great',
      'yourChangesUpdated': 'Your changes updated',
      'orderCreatedSuccessfully': 'Order created successfully!',
      'addClientDialog': 'Add Client',
      'editClientDialog': 'Edit Client',
      'pleaseEnterPhone': 'Please enter phone',
      'pleaseEnterPiecesNumber': 'Please enter pieces number',
      'pleaseEnterPurchasePrice': 'Please enter purchase price',
      'pleaseEnterSalePrice': 'Please enter sale price',
      'clientOrders': 'Orders',
      'loadingOrders': 'Loading orders...',
      'clientHasntPlacedOrders': 'hasn\'t placed any orders yet',
      'errorLoadingOrdersTitle': 'Error Loading Orders',
      'status': 'Status',
      'notReceived': 'Not Received',
      'paymentDetails':'Payment Details',
      'remaining':'Remaining'
    },
    'ar': {
      'paymentDetails':'نفاصيل الدفع',
      'remaining':'اللي باقي',
      'appName': 'كل ما تحتاجه',
      'login': 'تسجيل الدخول',
      'signUp': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirmPassword': 'تأكيد كلمة المرور',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'dontHaveAccount': 'ليس لديك حساب؟',
      'alreadyHaveAccount': 'لديك حساب بالفعل؟',
      'signInWithGoogle': 'تسجيل الدخول بجوجل',
      'vendors': 'الموردين',
      'clients': 'العملاء',
      'orders': 'الطلبات',
      'vendorName': 'اسم المورد',
      'phoneNumber': 'رقم الهاتف',
      'viewOrders': 'عرض الطلبات',
      'addOrder': 'إضافة طلب',
      'addVendor': 'إضافة مورد',
      'editVendor': 'تعديل المورد',
      'deleteVendor': 'حذف المورد',
      'searchVendors': 'البحث في الموردين...',
      'orderDetails': 'تفاصيل الطلب',
      'piecesNumber': 'عدد القطع',
      'totalPurchasePrice': 'إجمالي سعر الشراء',
      'totalSalesPrice': 'إجمالي سعر البيع',
      'charge': 'العمولة',
      'deposit': 'مقدم',
      'netProfit': 'صافي الربح',
      'orderDate': 'تاريخ الطلب',
      'orderStatus': 'حالة الطلب',
      'working': 'قيد العمل',
      'end': 'منتهي',
      'pending': 'في الانتظار',
      'received': 'مستلم',
      'addNewOrder': 'إضافة طلب جديد',
      'deleteOrder': 'حذف الطلب',
      'clientName': 'اسم العميل',
      'address': 'العنوان',
      'addClient': 'إضافة عميل',
      'editClient': 'تعديل العميل',
      'deleteClient': 'حذف العميل',
      'searchClients': 'البحث في العملاء...',
      'selectVendor': 'اختر المورد',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'edit': 'تعديل',
      'submit': 'إرسال',
      'total': 'الإجمالي',
      'period': 'الفترة',
      'orderDeletedSuccessfully': 'تم حذف الطلب بنجاح',
      'clientDeletedSuccessfully': 'تم حذف العميل بنجاح',
      'vendorDeletedSuccessfully': 'تم حذف المورد بنجاح',
      'orderAddedSuccessfully': 'تم إضافة الطلب بنجاح',
      'clientAddedSuccessfully': 'تم إضافة العميل بنجاح',
      'vendorAddedSuccessfully': 'تم إضافة المورد بنجاح',
      'errorOccurred': 'حدث خطأ',
      'noOrdersFound': 'لم يتم العثور على طلبات',
      'noClientsFound': 'لم يتم العثور على عملاء',
      'noVendorsFound': 'لم يتم العثور على موردين',
      'dashboard': 'لوحة التحكم',
      'manageBusinessEfficiently': 'إدارة عملك بكفاءة',
      'welcomeBack': 'مرحباً بعودتك!',
      'readyToManageOrders': 'مستعد لإدارة طلباتك وتنمية عملك؟',
             'totalOrders': 'إجمالي الطلبات',
       'activeClients': 'العملاء النشطين',
       'quickActions': 'الإجراءات السريعة',
      'collectOrder': 'جمع الطلب',
      'createNewOrders': 'إنشاء طلبات جديدة',
      'viewAllOrders': 'عرض جميع الطلبات',
      'manageClients': 'إدارة العملاء',
      'manageVendors': 'إدارة الموردين',
      'viewBills': 'عرض الفواتير',
      'analytics': 'التحليلات',
      'viewReports': 'عرض التقارير',
      'analyticsComingSoon': 'ميزة التحليلات قادمة قريباً!',
             'language': 'اللغة',
       'englishLanguage': 'English',
       'arabicLanguage': 'العربية',
       'tryAdjustingSearchTerms': 'حاول تعديل مصطلحات البحث',
       'vendorsWillAppearHere': 'سيظهر الموردون هنا بمجرد إضافة الطلبات',
       'resultsFound': 'نتيجة وجدت',
       'resultFound': 'نتيجة وجدت',
       'errorLoadingVendors': 'خطأ في تحميل الموردين',
       'retry': 'إعادة المحاولة',
       'ordersHistory': 'تاريخ الطلبات',
       'clientsDeletedSuccessfully': 'تم حذف العملاء بنجاح',
       'addYourFirstClient': 'أضف عميلك الأول للبدء',
       'errorLoadingClients': 'خطأ في تحميل العملاء',
       'deleteClients': 'حذف العملاء',
       'addNewClient': 'إضافة عميل جديد',
       'name': 'الاسم',
       'pleaseEnterName': 'يرجى إدخال اسم',
       'pleaseEnterPhoneNumber': 'يرجى إدخال رقم هاتف',
       'pleaseEnterAddress': 'يرجى إدخال عنوان',
       'collect': 'جمع',
       'close': 'إغلاق',
       'vendorInformation': 'معلومات المورد',
       'phone': 'الهاتف',
       'financialSummary': 'الملخص المالي',
       'totalPurchase': 'إجمالي الشراء',
       'totalSale': 'إجمالي البيع',
       'pieces': 'القطع',
       'purchase': 'الشراء',
       'sale': 'البيع',
       'signInToContinue': 'تسجيل الدخول للاستمرار في حسابك',
       'pleaseEnterEmail': 'يرجى إدخال بريدك الإلكتروني',
       'pleaseEnterValidEmail': 'يرجى إدخال بريد إلكتروني صحيح',
       'pleaseEnterPassword': 'يرجى إدخال كلمة المرور',
       'or': 'أو',
       'debugAuth': 'تصحيح المصادقة',
       'createAccount': 'إنشاء حساب',
       'pleaseFillDetails': 'يرجى ملء التفاصيل أدناه لإنشاء حسابك',
       'fullName': 'الاسم الكامل',
       'pleaseEnterFullName': 'يرجى إدخال اسمك الكامل',
       'pleaseConfirmPassword': 'يرجى تأكيد كلمة المرور',
             'passwordsDoNotMatch': 'كلمات المرور غير متطابقة',
      'signIn': 'تسجيل الدخول',
      'dateRangeFilter': 'فلتر نطاق التاريخ',
      'selectRange': 'اختر النطاق',
      'allCompletedOrders': 'جميع الطلبات المكتملة',
      'totalCharges': 'إجمالي العمولات',
      'completedOrders': 'الطلبات المكتملة',
      'noCompletedOrdersFound': 'لم يتم العثور على طلبات مكتملة',
      'completeSomeOrders': 'أكمل بعض الطلبات لرؤية البيانات المالية',
      'orderNumber': 'طلب رقم',
      'vendor': 'المورد',
      'date': 'التاريخ',
      'profit': 'الربح',
      'sales': 'المبيعات',
      'filterByStatus': 'فلتر حسب الحالة:',
      'complete': 'مكتمل',
      'collectDone': 'جمع/تم',
      'areYouSureCollect': 'هل أنت متأكد من أنك تريد تحديد طلب',
      'orderUpdatedSuccessfully': 'تم تحديث الطلب بنجاح',
      'errorLoadingOrders': 'خطأ في تحميل الطلبات',
      'refresh': 'تحديث',
      'orderStatusChip': 'حالة الطلب',
      'netProfitHighlight': 'صافي الربح',
      'clientsSection': 'العملاء',
      'clientInformation': 'معلومات العميل',
      'orderInformation': 'معلومات الطلب',
      'vendorPhone': 'هاتف المورد',
      'receivedStatus': 'مستلم',
      'yes': 'نعم',
      'no': 'لا',
      'purchasePrice': 'سعر الشراء',
      'salePrice': 'سعر البيع',
      'clientProfit': 'الربح',
      'editOrder': 'تعديل الطلب',
      'collectOrderTitle': 'جمع الطلب',
      'vendorPhoneNumber': 'هاتف المورد',
      'pleaseEnterVendorName': 'يرجى إدخال اسم المورد',
      'pleaseEnterVendorPhone': 'يرجى إدخال هاتف المورد',
      'pleaseEnterChargeAmount': 'يرجى إدخال مبلغ العمولة',
      'pleaseEnterValidNumber': 'يرجى إدخال رقم صحيح',
      'clientsSectionTitle': 'العملاء',
      'noClientsAddedYet': 'لم يتم إضافة عملاء بعد',
      'orderSummary': 'ملخص الطلب',
      'saveChanges': 'حفظ التغييرات',
      'createOrder': 'إنشاء طلب',
      'pleaseAddAtLeastOneClient': 'يرجى إضافة عميل واحد على الأقل',
      'great': 'ممتاز',
      'yourChangesUpdated': 'تم تحديث تغييراتك',
      'orderCreatedSuccessfully': 'تم إنشاء الطلب بنجاح!',
      'addClientDialog': 'إضافة عميل',
      'editClientDialog': 'تعديل العميل',
      'pleaseEnterPhone': 'يرجى إدخال الهاتف',
      'pleaseEnterPiecesNumber': 'يرجى إدخال عدد القطع',
      'pleaseEnterPurchasePrice': 'يرجى إدخال سعر الشراء',
      'pleaseEnterSalePrice': 'يرجى إدخال سعر البيع',
      'clientOrders': 'الطلبات',
      'loadingOrders': 'جاري تحميل الطلبات...',
      'clientHasntPlacedOrders': 'لم يضع أي طلبات بعد',
      'errorLoadingOrdersTitle': 'خطأ في تحميل الطلبات',
      'status': 'الحالة',
      'notReceived': 'غير مستلم',
    },
  };
} 