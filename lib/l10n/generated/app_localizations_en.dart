// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dawar';

  @override
  String get appTagline => 'Turn Waste Into Value';

  @override
  String get appSystemTitle => 'Smart Waste Recycling Management System';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get saveEdits => 'Save Edits';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get or => 'or';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get logoutExit => 'Exit';

  @override
  String get alert => 'Alert';

  @override
  String get available => 'Available';

  @override
  String get unavailable => 'Unavailable';

  @override
  String greeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navMarket => 'Market';

  @override
  String get navMyOrders => 'My Orders';

  @override
  String get navProfile => 'Profile';

  @override
  String get navOrders => 'Orders';

  @override
  String get navAccount => 'My Account';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePickerTitle => 'Language';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeAutoFull => 'Auto (Phone System)';

  @override
  String get themeAutoShort => 'Auto';

  @override
  String get loginMethodEmail => 'Email';

  @override
  String get loginMethodPhone => 'Phone Number';

  @override
  String get loginPhoneLabel => 'Phone Number';

  @override
  String get loginEmailLabel => 'Email Address';

  @override
  String get loginEmailHint => 'example@domain.com';

  @override
  String get loginButton => 'Login';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginSignUpNow => 'Register Now';

  @override
  String get loginCountrySearch => 'Search';

  @override
  String get loginCountrySearchHint => 'Search for country';

  @override
  String get roleSelectTitle => 'Choose Account Type';

  @override
  String get roleDriver => 'Driver';

  @override
  String get roleSupplier => 'Supplier';

  @override
  String get roleRecyclingCo => 'Recycling Company';

  @override
  String get supplierTypeLabel => 'Supplier Type';

  @override
  String get supplierTypeIndividual => 'Individual';

  @override
  String get supplierTypeStore => 'Store / Restaurant';

  @override
  String get footerTerms => 'Terms of Service';

  @override
  String get footerPrivacy => 'Privacy Policy';

  @override
  String get footerInfra => 'DIGITAL INFRASTRUCTURE BY GOVERNMENT';

  @override
  String get footerIdea => 'An Idea from Jordanian Youth Minds';

  @override
  String get footerPolicyOk => 'OK, I Understand';

  @override
  String get footerPolicyBody =>
      'This text is a placeholder describing the Terms & Conditions and Privacy Policy of the application. It will be updated later to reflect the actual legal policies.\n\n• The user agrees to comply with all applicable laws and regulations.\n• The app may retain certain basic data to improve the provided service.\n• We reserve the right to modify these terms at any time with user notification.\n• Your data privacy matters to us; we will not share it with third parties without your explicit consent.\n• By using this application, you agree to all Terms & Conditions stated herein.';

  @override
  String get signupTitle => 'Create Account';

  @override
  String get signupCreateButton => 'Create Account';

  @override
  String get signupSubtitle => 'Complete your data to join the Dawar platform';

  @override
  String get signupSectionBusiness => 'Organization Info';

  @override
  String get signupCompanyName => 'Company Name';

  @override
  String get signupStoreName => 'Store / Restaurant Name';

  @override
  String get signupCompanyNameHint => 'Green Environment Company';

  @override
  String get signupStoreNameHint => 'Al-Aseel Restaurant';

  @override
  String get signupManagerName => 'Manager Name';

  @override
  String get signupStoreOwnerName => 'Store Owner Name';

  @override
  String get signupExampleName => 'Mohammad Ahmad Al-Abdallah';

  @override
  String get signupCoverageArea => 'Service Area';

  @override
  String get signupCoverageHint => 'Amman, Zarqa, Irbid...';

  @override
  String get signupSectionPersonal => 'Personal Information';

  @override
  String get signupFullName => 'Full Name';

  @override
  String get signupFullNameHint => 'Ahmad Mohammad Al-Abdallah';

  @override
  String get signupNationality => 'Nationality';

  @override
  String get signupJordanian => 'Jordanian';

  @override
  String get signupOther => 'Other';

  @override
  String get signupSectionDocuments => 'Official Documents';

  @override
  String get signupNationalIdDocument => 'National ID Image';

  @override
  String get signupCommercialRegisterDocument => 'Commercial Register Image';

  @override
  String get signupBusinessLicenseDocument => 'Business License Image';

  @override
  String get signupUploadDocumentPrompt => 'Tap to upload document image';

  @override
  String get signupUploadDocumentSources => 'Camera or photo gallery';

  @override
  String get signupDocumentUploaded => 'Uploaded';

  @override
  String get signupSectionContact => 'Contact Information';

  @override
  String get signupContactRequired => 'At least one is required';

  @override
  String get signupPhone => 'Phone Number';

  @override
  String get signupPhoneHint => '7X XXX XXXX';

  @override
  String get signupEmailLabel => 'Email Address';

  @override
  String get signupEmailHint => 'example@domain.com';

  @override
  String get signupPasswordLabel => 'Password';

  @override
  String get signupPasswordHint => 'At least 8 characters, letter + digit';

  @override
  String get signupPasswordConfirmLabel => 'Confirm Password';

  @override
  String get signupPasswordConfirmHint => 'Re-enter your password';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get signupRoleDriver => 'Driver Registration';

  @override
  String get signupRoleStoreBusiness => 'Store / Restaurant Registration';

  @override
  String get signupRoleIndividualSupplier => 'Individual Supplier Registration';

  @override
  String get signupRoleRecyclingCo => 'Recycling Company Registration';

  @override
  String get signupPhotoPersonal => 'Profile Photo';

  @override
  String get signupPhotoOrganization => 'Organization Logo';

  @override
  String get signupErrorManagerName =>
      'Please enter the responsible person\'s name';

  @override
  String get signupErrorDocumentRequired =>
      'Please upload the required document';

  @override
  String get signupErrorEmailRequired => 'Email address is required';

  @override
  String get signupErrorPasswordRequired => 'Password is required';

  @override
  String get signupErrorPasswordMismatch => 'Passwords do not match';

  @override
  String get signupErrorSubmitFailed =>
      'Failed to create account, please try again';

  @override
  String get signupLocationTitle => 'Location';

  @override
  String get signupLocationSubtitle =>
      'Optional — helps determine service areas';

  @override
  String get signupLocationChange => 'Change';

  @override
  String get signupLocationSelect => 'Select';

  @override
  String get signupLocationSelectPrompt => 'Tap to select your location';

  @override
  String get signupLocationOpenMap => 'Tap to open location map';

  @override
  String get signupLocationPreciseLabel => 'Precise Address';

  @override
  String get signupLocationPreciseHint => 'Street, building, apartment, etc.';

  @override
  String onboardingCategoriesSelected(int count) {
    return '$count selected';
  }

  @override
  String get onboardingCategoriesSuggested =>
      'Suggested Categories — Choose what applies';

  @override
  String get onboardingCategoriesNote =>
      'You can edit your choices at any time from profile settings';

  @override
  String get onboardingHighlightsTitle => 'What distinguishes you in the app';

  @override
  String get onboardingHighlightsSubtitle =>
      'Benefits you will get once you create an account';

  @override
  String get onboardingAiPanelTitle => 'AI Suggestions';

  @override
  String get onboardingAiPanelSubtitle =>
      'Recommended categories and what distinguishes you';

  @override
  String get onboardingAiPanelContext =>
      'AI will analyze your information and suggest the most appropriate categories for you, and clarify what distinguishes you to your customers in the app.';

  @override
  String get onboardingTaglineLabel => 'Your tagline or vision';

  @override
  String get onboardingTaglineHint => 'e.g., Best service at lowest cost';

  @override
  String get onboardingAiGenerateButton => 'Get AI Suggestions';

  @override
  String get onboardingAiGenerating => 'Generating...';

  @override
  String get individualSupplierSignupTitle =>
      'Individual Supplier Registration';

  @override
  String get recyclingCoSignupTitle => 'Recycling Company Registration';

  @override
  String get storeSignupTitle => 'Store / Company Registration';

  @override
  String get onboardingHeaderSubtitleAi =>
      'Complete the form and AI will help you choose categories';

  @override
  String get onboardingSectionProfile => 'Profile';

  @override
  String get onboardingSectionProfileCompany => 'Company Profile';

  @override
  String get onboardingSectionProfileStore => 'Store / Company Profile';

  @override
  String get onboardingLabelCompanyLogo => 'Company Logo';

  @override
  String get driverTitle => 'Dawar Driver';

  @override
  String get driverActiveOrdersLabel => 'Active Order';

  @override
  String get driverCompletedOrdersLabel => 'Completed Orders';

  @override
  String get driverEarningsLabel => 'Earnings (JD)';

  @override
  String get driverUnavailableTitle => 'You are currently unavailable';

  @override
  String get driverUnavailableSubtitle =>
      'Change your status to available above to receive new orders';

  @override
  String get driverAvailableOrders => 'Available Orders';

  @override
  String get driverNoAvailableOrders => 'No available orders currently';

  @override
  String get driverMyListings => 'My Market Listings';

  @override
  String get driverCurrentTrip => 'Your Current Trip';

  @override
  String get driverViewDetails => 'View Details';

  @override
  String get driverPublishToMarket => 'Publish to Market';

  @override
  String get driverOrdersHistory => 'Orders History';

  @override
  String get driverNoOrders => 'No Orders';

  @override
  String get driverNoOrdersYet => 'You haven\'t accepted any orders yet';

  @override
  String get driverCollectionCommitments => 'Collection Commitments';

  @override
  String get withdrawListing => 'Withdraw Listing';

  @override
  String get withdrawListingConfirm =>
      'Do you want to withdraw this listing from the market?';

  @override
  String get yesWithdraw => 'Yes, Withdraw';

  @override
  String get profilePersonalAndVehicle => 'Personal & Vehicle Info';

  @override
  String get profilePhone => 'Phone Number';

  @override
  String get profileVehicle => 'Vehicle';

  @override
  String get profileLicensePlate => 'License Plate';

  @override
  String get profileAddLicensePlate => 'Add License Plate';

  @override
  String get profileAddVehicleInfo => 'Add Vehicle Info';

  @override
  String get profileAppSettings => 'App Settings';

  @override
  String get profileLanguage => 'App Language';

  @override
  String get profileTheme => 'Theme';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileNotificationsEnabled => 'Enabled';

  @override
  String get profileHelpSupport => 'Help & Support';

  @override
  String get profileContactSupport => 'Contact Technical Support';

  @override
  String get profileEditProfile => 'Edit Profile';

  @override
  String get profileDeleteAccount => 'Delete Account';

  @override
  String get profileTotalTrips => 'Total Trips';

  @override
  String get profileTotalEarnings => 'Total Earnings';

  @override
  String get profileTapToAddPhoto => 'Tap to add a photo';

  @override
  String get profileEditVehicle => 'Edit Vehicle Info';

  @override
  String get profileVehicleTypeModel => 'Vehicle Type and Model';

  @override
  String get profileVehicleTypeModelHint => 'Example: Toyota Prius';

  @override
  String get profileVehicleColor => 'Vehicle Color';

  @override
  String get profileVehicleColorHint => 'Example: White';

  @override
  String get profileVehiclePhoto => 'Vehicle Photo';

  @override
  String get supplierStoreType => 'Store Supplier';

  @override
  String get supplierIndividualType => 'Individual Supplier';

  @override
  String get supplierActiveOrders => 'My Active Orders';

  @override
  String get supplierMyListings => 'My Market Listings';

  @override
  String get supplierNoOrdersYet => 'No active orders';

  @override
  String get supplierCreateFromHome =>
      'Tap the + button at the bottom to create a new order';

  @override
  String supplierGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get supplierDriverOnWay => 'Driver is on the way';

  @override
  String get supplierPoints => 'Points';

  @override
  String get supplierRecyclingPoints => 'Recycling Points';

  @override
  String get supplierTotalOrders => 'Total Orders';

  @override
  String get supplierAddress => 'Address';

  @override
  String get supplierAddAddress => 'Add Address';

  @override
  String get supplierIdentity => 'Identity';

  @override
  String get supplierVerified => 'Verified';

  @override
  String get supplierNotVerified => 'Not Verified';

  @override
  String get supplierPersonalInfo => 'Personal Information';

  @override
  String get supplierMyRewards => 'My Rewards';

  @override
  String get supplierNameLabel => 'Name';

  @override
  String get supplierNameHint => 'Enter your name';

  @override
  String get supplierPhoneHint => '+962 7X XXX XXXX';

  @override
  String get supplierAddressLabel => 'Address';

  @override
  String get supplierAddressHint => 'Enter your address';

  @override
  String get ordersTabTitle => 'My Orders';

  @override
  String get ordersNoOrdersYet => 'No orders yet';

  @override
  String get ordersCreateFromHome =>
      'Create a new pickup order from the home page';

  @override
  String get ordersActiveSection => 'Active Orders';

  @override
  String get ordersCompletedSection => 'Completed Orders';

  @override
  String get ordersCancelledSection => 'Cancelled Orders';

  @override
  String get ordersCollectionSection => 'Collection Commitments';

  @override
  String get orderDeliveryConfirmTitle => 'Confirm Delivery';

  @override
  String get orderDeliveryConfirmMsg =>
      'Did you reach the facility and deliver the materials?';

  @override
  String get orderActualWeight => 'Actual Weight (kg) — Optional';

  @override
  String get orderScheduledAt => 'Scheduled';

  @override
  String get cancelOrderTitle => 'Cancel Order';

  @override
  String get cancelOrderConfirm =>
      'Are you sure you want to cancel this order?';

  @override
  String get yesCancelOrder => 'Yes, Cancel';

  @override
  String get recyclingCompanyLabel => 'Recycling Company';

  @override
  String get recyclingOpenForReceipt => 'Open for Receipt';

  @override
  String get recyclingClosedTemp => 'Temporarily Closed';

  @override
  String get recyclingTodayShipments => 'Today\'s Shipments';

  @override
  String get recyclingTotalWeight => 'Total Weight';

  @override
  String get recyclingActiveJobsLabel => 'Active Jobs';

  @override
  String get recyclingDriversInProgress => 'Drivers in Progress';

  @override
  String get recyclingPostJob => 'Post Collection Job';

  @override
  String get recyclingPostJobSubtitle =>
      'Request a driver to collect waste from a specific area';

  @override
  String get recyclingIncomingShipments => 'Incoming Shipments';

  @override
  String get recyclingActiveCollectionJobs => 'Active Collection Jobs';

  @override
  String get recyclingMyListings => 'My Market Listings';

  @override
  String get recyclingCommitted => 'Committed:';

  @override
  String get recyclingCompanyInfo => 'Company Info';

  @override
  String get recyclingCompanyPhone => 'Contact Number';

  @override
  String get recyclingCompanyEmail => 'Email Address';

  @override
  String get recyclingServiceArea => 'Service Area';

  @override
  String get recyclingWorkingHours => 'Working Hours';

  @override
  String get recyclingLicense => 'Business License';

  @override
  String get recyclingReceivedShipments => 'Received Shipments';

  @override
  String get recyclingProcessedWeight => 'Processed Weight (kg)';

  @override
  String get recyclingEditCompany => 'Edit Company Data';

  @override
  String get recyclingCompanyNameLabel => 'Company Name';

  @override
  String get recyclingCompanyNameHint => 'Enter company name';

  @override
  String get recyclingPhoneLabel => 'Contact Number';

  @override
  String get recyclingPhoneHint => '+962 6X XXX XXXX';

  @override
  String get recyclingEmailLabel => 'Email Address';

  @override
  String get recyclingEmailHint => 'info@company.jo';

  @override
  String get recyclingAreaLabel => 'Service Area';

  @override
  String get recyclingAreaHint => 'Amman, Zarqa...';

  @override
  String get recyclingHoursLabel => 'Working Hours';

  @override
  String get recyclingHoursHint => '7:00 AM - 5:00 PM';

  @override
  String get recyclingLicenseVerified => 'Verified';

  @override
  String get recyclingLicenseNotVerified => 'Not Verified';

  @override
  String get marketDriverRole => 'Receive and Sell';

  @override
  String get marketSupplierRole => 'Buy and Deliver';

  @override
  String get marketRecyclingRole => 'Receive at your Facility';

  @override
  String get marketTitle => 'Market';

  @override
  String get marketBrowse => 'Browse Materials for Sale';

  @override
  String get marketCollectionJobsSubtitle =>
      'Collection Jobs from Recycling Companies';

  @override
  String get marketSearch => 'Search for materials, seller, or area...';

  @override
  String get marketAvailableOffers => 'Available Offers';

  @override
  String get marketNoOffers => 'No offers currently';

  @override
  String get collectionSaleNew => 'New';

  @override
  String collectionSaleJobNumber(String id) {
    return 'Job No: $id';
  }

  @override
  String get collectionSaleDeliveryLocation => 'Delivery Location:';

  @override
  String get collectionSaleAgreedPrice => 'Agreed Price:';

  @override
  String get collectionSaleCancelCommitment => 'Cancel Commitment';

  @override
  String get collectionSaleStartCollection => 'Start Collection';

  @override
  String get collectionSaleConfirmDelivery => 'Confirm Delivery';

  @override
  String get collectionSaleCancelTitle => 'Cancel Commitment';

  @override
  String get collectionSaleCancelConfirm =>
      'Are you sure you want to cancel your commitment to this job?';

  @override
  String get postMarketTitle => 'Post to Market';

  @override
  String get postMarketSubtitle =>
      'Add details of the materials you want to sell';

  @override
  String get postMarketWasteTypeLabel => 'Material Type *';

  @override
  String get postMarketWasteFormLabel => 'Material Condition';

  @override
  String get postMarketPriceLabel => 'Asking Price (JD) — Optional';

  @override
  String get postMarketImagesLabel => 'Material Photos — Optional';

  @override
  String get postMarketSubmitButton => 'Publish Listing';

  @override
  String get postMarketAiAnalyzing => 'AI is analyzing the image...';

  @override
  String get postMarketAiFilled => 'Fields auto-filled by AI';

  @override
  String get postMarketAiFailed => 'AI analysis failed, please fill manually';

  @override
  String get postMarketNeedImageFirst =>
      'Please add an image first for AI analysis';

  @override
  String get postMarketLocationPermissionDenied =>
      'Location permission denied, using default location';

  @override
  String get postMarketUseCurrentLocation => 'Use Current Location';

  @override
  String get postMarketAdjustLocation => 'Adjust Location on Map';

  @override
  String get postMarketMinPriceErrorIndividual =>
      'Minimum price for individuals is 5 JOD';

  @override
  String get postMarketMinPriceErrorBusiness =>
      'Minimum price for businesses is 20 JOD';

  @override
  String get collectionJobTitle => 'Collection Job Details';

  @override
  String get collectionJobCollectionArea => 'Collection Area: ';

  @override
  String get collectionJobDeleteTitle => 'Delete Job';

  @override
  String get collectionJobDeleteConfirm =>
      'Are you sure? This action cannot be undone.';

  @override
  String get collectionJobAccepted => 'Job accepted — check your orders';

  @override
  String get collectionJobAcceptButton => 'Accept Job';

  @override
  String get collectionJobAcceptSellButton => 'Accept and Sell Waste';

  @override
  String get collectionJobRequiredMaterials => 'Required Material Types';

  @override
  String get collectionJobPricingTitle => 'Pricing and Payment';

  @override
  String get collectionJobDescTitle => 'Job Description';

  @override
  String get collectionJobRecyclingCoLabel => 'Recycling Co';

  @override
  String get marketItemSellerLabel => 'Seller';

  @override
  String get marketItemPickupAddressLabel => 'Pickup Address';

  @override
  String get marketItemDistanceLabel => 'Estimated Distance';

  @override
  String marketItemDistanceValue(String distance) {
    return '$distance km from your location';
  }

  @override
  String get marketItemConditionLabel => 'Condition';

  @override
  String get marketItemWeightLabel => 'Weight';

  @override
  String get marketItemPublishDateLabel => 'Publish Date';

  @override
  String get marketItemUnknown => 'Unspecified';

  @override
  String get marketItemUnknownSeller => 'Unknown Seller';

  @override
  String get marketItemDriverReceive => 'Receive Item';

  @override
  String get marketItemBuyNow => 'Buy Now';

  @override
  String get marketItemCompanyReceive => 'Receive at Facility';

  @override
  String get marketItemPurchasedPickup =>
      'Purchased! You can pick up from the market.';

  @override
  String get marketItemReceived => 'Item received successfully!';

  @override
  String get marketItemPurchasedDriver =>
      'Purchased! A driver will be sent for pickup.';

  @override
  String get marketItemFacilityReceived => 'Receipt registered at facility!';

  @override
  String get marketRiderChoiceTitle => 'Select Action';

  @override
  String get marketRiderChoiceSubtitle =>
      'Do you want to buy this item or deliver it?';

  @override
  String get marketRiderOptionBuy => 'Buy for Myself';

  @override
  String get marketRiderOptionBuySubtitle =>
      'Pay and take the item from its location';

  @override
  String get marketRiderOptionDeliver => 'Deliver Item';

  @override
  String get marketRiderOptionDeliverSubtitle =>
      'Transport the item from place to place';

  @override
  String get marketInvoiceTitle => 'Order Invoice';

  @override
  String get marketInvoiceTotal => 'Total Amount';

  @override
  String get marketInvoiceConfirm => 'Confirm and Buy';

  @override
  String get marketInvoicePickupLocation => 'Pickup Location';

  @override
  String get marketInvoicePickupSuccess =>
      'Purchase confirmed! Go to the location to collect your item.';

  @override
  String get rateDriverTitle => 'Rate Driver';

  @override
  String get rateDriverSubmit => 'Submit Rating';

  @override
  String get rateDriverSkip => 'Skip';

  @override
  String get rewardsTitle => 'My Rewards';

  @override
  String get rewardsHistoryTitle => 'Rewards History';

  @override
  String get rewardsNoHistory => 'No rewards history yet';

  @override
  String get rewardsPointsLabel => 'Points';

  @override
  String get rewardsRedeem => 'Redeem Your Points';

  @override
  String get rewardsComingSoon => 'This feature is coming soon!';

  @override
  String rewardsProgressText(int points, int threshold) {
    return '$points / $threshold points to next level';
  }

  @override
  String get rewardsDiscountOrders => 'Order Discount';

  @override
  String get rewardsGiftCard => 'Gift Card';

  @override
  String get rewardsFreeDelivery => 'Free Delivery';

  @override
  String get rewards50Points => '50 Points';

  @override
  String get rewards100Points => '100 Points';

  @override
  String get rewards30Points => '30 Points';

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Silver';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierPlatinum => 'Platinum';

  @override
  String get mapsComingSoon => 'Google Maps will be connected soon';

  @override
  String get marketSegmentJobs => 'Collection Jobs';

  @override
  String get marketJobsFromCompanies => 'From Recycling Companies';

  @override
  String get marketNoJobs => 'No collection jobs currently';

  @override
  String get collectionJobBadge => 'Collection Job';

  @override
  String get collectionJobEdited => 'Edited';

  @override
  String collectionJobEditedAt(String time) {
    return 'This job was edited $time';
  }

  @override
  String collectionJobMinQtyChip(String n) {
    return 'Minimum: $n kg';
  }

  @override
  String recyclingAndOthers(int count) {
    return '+$count others';
  }

  @override
  String collectionJobMinQtyFrom(String min) {
    return 'From $min kg';
  }

  @override
  String timeAgoDays(int n) {
    return '${n}d ago';
  }

  @override
  String timeAgoHours(int n) {
    return '${n}h ago';
  }

  @override
  String timeAgoMinutes(int n) {
    return '${n}m ago';
  }

  @override
  String get marketListingStatusPending => 'Awaiting Buyer';

  @override
  String get marketListingStatusAccepted => 'Purchased';

  @override
  String get marketListingStatusInTransit => 'In Delivery';

  @override
  String get marketListingStatusCompleted => 'Completed';

  @override
  String get marketListingStatusCancelled => 'Cancelled';

  @override
  String get orderStatusPending => 'Awaiting';

  @override
  String get orderStatusAccepted => 'Accepted';

  @override
  String get orderStatusArrivedAtPickup => 'At Pickup';

  @override
  String get orderStatusArrivedAtDropoff => 'At Dropoff';

  @override
  String get orderStatusInTransit => 'In Transit';

  @override
  String get orderStatusCompleted => 'Completed';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderWaitingTime => 'Waiting Time';

  @override
  String get orderArrivalTime => 'Arrival Time';

  @override
  String get orderEarningsLabel => 'Earnings';

  @override
  String get orderCurrencyJD => 'JD';

  @override
  String get orderAcceptButton => 'Accept Order';

  @override
  String get orderViewRoute => 'View Route';

  @override
  String get orderDriverOnWay => 'Driver is on the way to you';

  @override
  String get orderChatButton => 'Chat';

  @override
  String get orderWhatsAppButton => 'WhatsApp';

  @override
  String get orderChatComingSoon => 'Chat with driver coming soon';

  @override
  String get orderWhatsAppFailed => 'Could not open WhatsApp';

  @override
  String get orderStatusTitle => 'Order Status';

  @override
  String get orderStatusStepPending => 'Awaiting';

  @override
  String get orderStatusStepAccepted => 'Accepted';

  @override
  String get orderStatusStepArrivedAtPickup => 'Arrived';

  @override
  String get orderStatusStepInTransit => 'In Transit';

  @override
  String get orderStatusStepArrivedAtDropoff => 'At Dropoff';

  @override
  String get orderStatusStepCompleted => 'Completed';

  @override
  String get orderDetailsTitle => 'Order Details';

  @override
  String get orderFromLabel => 'From';

  @override
  String get orderToLabel => 'To';

  @override
  String orderDistKm(String d) {
    return '$d km';
  }

  @override
  String orderWeightKgLabel(String w) {
    return '$w kg';
  }

  @override
  String orderRewardJD(String r) {
    return '$r JD';
  }

  @override
  String get orderDriverSection => 'Driver';

  @override
  String orderDriverArrives(String eta) {
    return 'Arrives in $eta';
  }

  @override
  String get orderCompletionTitle => 'Complete Trip';

  @override
  String get orderPhotoCamera => 'Take Photo';

  @override
  String get orderPhotoGallery => 'Choose from Gallery';

  @override
  String get orderCompleteDialogTitle => 'Complete Order';

  @override
  String get orderCompleteDialogMsg =>
      'Are you sure you have delivered the order and received the payment?\nUpon completion, you will be able to receive new orders.';

  @override
  String get orderConfirmComplete => 'Confirm Completion';

  @override
  String get orderProofPhotoHint => 'Take proof of receipt photo (optional)';

  @override
  String get orderAmountLabel => 'Amount to collect:';

  @override
  String get orderFinishButton => 'Finish Order';

  @override
  String get orderProofTitle => 'Proof of Receipt & Delivery';

  @override
  String get orderProofLinkBroken =>
      'Link points to a temporarily unavailable file';

  @override
  String get orderRateDriver => 'Rate Driver';

  @override
  String get orderWhatsAppWaiting => 'Hello, I am waiting to be picked up.';

  @override
  String get marketItemPriceLabel => 'Material Price';

  @override
  String get marketItemNegotiable => 'Negotiable';

  @override
  String get marketItemDescriptionLabel => 'Product Description';

  @override
  String marketListingPrice(String price) {
    return '$price JD';
  }

  @override
  String get collectionSaleDetailTitle => 'Commitment Details';

  @override
  String get collectionSaleDeliveryLocationNoColon => 'Delivery Location';

  @override
  String get collectionSaleAgreedPriceNoColon => 'Agreed Price';

  @override
  String get collectionSaleAgreementTitle => 'Agreement Details';

  @override
  String get collectionSaleDeliveryMethodLabel => 'Delivery Method';

  @override
  String get collectionSaleTransactionTypeLabel => 'Transaction Type';

  @override
  String get collectionSaleWasteTypesLabel => 'Waste Types';

  @override
  String collectionSaleCompanyNote(String note) {
    return 'Company: $note';
  }

  @override
  String get collectionSaleCommitmentNumber => 'Commitment No.';

  @override
  String get collectionSaleJobNumberLabel => 'Job No.';

  @override
  String get collectionSaleAcceptedAt => 'Accepted';

  @override
  String get orderTrackButton => 'Track';

  @override
  String get rateDriverExperience => 'How was your experience with the driver?';

  @override
  String get rateDriverPickLabel => 'Choose your rating';

  @override
  String get rateDriverPoor => 'Poor';

  @override
  String get rateDriverFair => 'Fair';

  @override
  String get rateDriverGood => 'Good';

  @override
  String get rateDriverExcellent => 'Excellent';

  @override
  String get imagePickerCamera => 'Camera';

  @override
  String get imagePickerGallery => 'Gallery';

  @override
  String get imagePickerSourceTitle => 'Choose Image Source';

  @override
  String get imagePickerAddPhoto => 'Add Photo';

  @override
  String get imagePickerRemoveImage => 'Remove Image';

  @override
  String get newOrderSelectButton => 'Select';

  @override
  String get newOrderTapToSelectLocation => 'Tap to select location on the map';

  @override
  String get newOrderCurrentAddress => 'My Current Address';

  @override
  String get newOrderTitle => 'New Pickup Request';

  @override
  String get newOrderSubtitle =>
      'Add details of the waste you want to dispose of';

  @override
  String get newOrderWasteTypeLabel => 'Waste Type *';

  @override
  String get newOrderWasteFormLabel => 'Waste Condition';

  @override
  String get newOrderWeightCategoryLabel => 'Quantity Size *';

  @override
  String get newOrderPickupAddressLabel => 'Pickup Address';

  @override
  String get newOrderImagesLabel => 'Waste Photos — Optional';

  @override
  String get newOrderPickupTargetLabel => 'Waste Destination *';

  @override
  String get newOrderPriceLabel => 'Material Price (JD) — Optional';

  @override
  String get newOrderPriceHintDriver =>
      'The price you want for selling materials to the driver';

  @override
  String get newOrderPriceHintCompany =>
      'The price you want for selling materials to the company';

  @override
  String get newOrderNotesLabel => 'Notes — Optional';

  @override
  String get newOrderNotesHint => 'Example: Approx. 20 plastic bags...';

  @override
  String get newOrderDeliveryFeeLabel => 'Delivery Fee';

  @override
  String get newOrderDeliveryFeeSubtitle =>
      'Calculated automatically by distance and size';

  @override
  String get newOrderSubmitButton => 'Submit Request';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatDevBanner => 'Dev Mode: Messages are local only';

  @override
  String get chatEmpty => 'No messages yet';

  @override
  String get chatInputHint => 'Type a message...';

  @override
  String get openInGoogleMaps => 'Open in Google Maps';

  @override
  String get mapsNotInstalledTitle => 'Google Maps not installed';

  @override
  String get mapsNotInstalledBody =>
      'No maps app found. Open the store to install it?';

  @override
  String get openStore => 'Open Store';

  @override
  String get mapLabelPickup => 'Pickup';

  @override
  String get mapLabelDropoff => 'Drop-off';

  @override
  String get mapUnavailable => 'Map unavailable';

  @override
  String get routeTitle => 'Route';

  @override
  String get pickLocationTitle => 'Set location';

  @override
  String get confirmLocation => 'Confirm location';

  @override
  String get useCurrentLocation => 'Use my current location';

  @override
  String get pickOnGoogleMaps => 'Pick on Google Maps';

  @override
  String get locationNotSet => 'Not set yet';

  @override
  String get pasteCoordinates => 'Paste coordinates';

  @override
  String get pasteCoordinatesHint =>
      'Paste from Google Maps, e.g. 31.9539, 35.9106';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get save => 'Save';

  @override
  String get gpsPermissionDenied => 'Location permission denied';

  @override
  String get gpsUnavailable => 'Could not get current location';

  @override
  String get invalidCoordinates => 'Invalid coordinates';

  @override
  String get orderTotalCost => 'Total Cost';

  @override
  String get orderPotentialEarnings => 'Potential Earnings';

  @override
  String get orderEarningsBreakdown => 'Earnings Breakdown';

  @override
  String get orderBaseFee => 'Base Fee';

  @override
  String get orderDistanceFee => 'Distance Fee';

  @override
  String get orderMaterialFee => 'Material Fee';

  @override
  String get orderUrgencyFee => 'Urgency Fee';

  @override
  String get orderPayout => 'Payout';

  @override
  String get orderInvoices => 'Invoices';

  @override
  String get rateDriver => 'Rate Driver';

  @override
  String get pickupRequestCreated => 'Pickup request sent successfully';

  @override
  String get forgotPasswordLink => 'Forgot Password?';

  @override
  String get forgotPasswordOtpTitle => 'Verification Code';

  @override
  String forgotPasswordOtpSubtitle(String email) {
    return 'A code was sent to $email';
  }

  @override
  String get forgotPasswordOtpLabel => 'Enter the 6-digit code';

  @override
  String get forgotPasswordVerifyButton => 'Verify Code';

  @override
  String get forgotPasswordResend => 'Resend Code';

  @override
  String forgotPasswordResendIn(int s) {
    return 'Resend in $s seconds';
  }

  @override
  String get forgotPasswordCodeSentAgain => 'A new code was sent';

  @override
  String get resetPasswordTitle => 'Set New Password';

  @override
  String get resetPasswordNewLabel => 'New Password';

  @override
  String get resetPasswordConfirmLabel => 'Confirm Password';

  @override
  String get resetPasswordButton => 'Set Password';

  @override
  String get resetPasswordSuccess =>
      'Password changed successfully. You can now log in.';

  @override
  String get forgotPasswordErrorEmptyEmail =>
      'Please enter your email address first';

  @override
  String get forgotPasswordErrorCodeLength => 'Please enter a 6-digit code';

  @override
  String get resetPasswordErrorMinLength =>
      'Password must be at least 8 characters';

  @override
  String get resetPasswordErrorMismatch => 'Passwords do not match';

  @override
  String get restaurantSignupStep1Title => 'Basic Profile';

  @override
  String get restaurantSignupStep1Subtitle =>
      'Let\'s start with your company details. This information helps us verify your business and build trust with customers.';

  @override
  String get restaurantSignupCompanyNameLabel => 'Restaurant / Company Name';

  @override
  String get restaurantSignupCompanyNameHint => 'e.g., The Golden Spoon';

  @override
  String get restaurantSignupOwnerNameLabel => 'Owner Name';

  @override
  String get restaurantSignupOwnerNameHint => 'e.g., John Doe';

  @override
  String get restaurantSignupStep2Title => 'Brand Identity & AI';

  @override
  String get restaurantSignupStep2Subtitle =>
      'Describe your restaurant in one line. Our AI will help craft a compelling story and recommend search categories.';

  @override
  String get restaurantSignupTaglineLabel =>
      'Describe your restaurant in one line';

  @override
  String get restaurantSignupTaglineHint =>
      'e.g., Authentic Italian pasta made from scratch';

  @override
  String get restaurantSignupGenerateButton => 'Generate Profile & Categories';

  @override
  String get restaurantSignupAiStoryLabel => 'AI-Generated Story (Editable)';

  @override
  String get restaurantSignupCategoriesLabel => 'Recommended Categories';

  @override
  String get restaurantSignupStep3Title => 'Location & Verification';

  @override
  String get restaurantSignupStep3Subtitle =>
      'Provide your physical address and upload verification documents. Our AI will automatically verify your details.';

  @override
  String get restaurantSignupAddressLabel => 'Restaurant Address';

  @override
  String get restaurantSignupAddressHint => 'Enter full street address';

  @override
  String get restaurantSignupUploadVerifyButton => 'Upload License & Verify';

  @override
  String get restaurantSignupAiVerificationNote =>
      'This photo will be checked by AI to verify your document.';

  @override
  String get restaurantSignupStatusVerified => 'Status: Verified';

  @override
  String get restaurantSignupStatusInvalid => 'Status: Invalid';

  @override
  String get restaurantSignupVerificationSuccess =>
      'Your documents and address have been automatically verified.';

  @override
  String get restaurantSignupStep4Title => 'Review & Submit';

  @override
  String get restaurantSignupStep4Subtitle =>
      'Please review your generated profile and details before final submission.';

  @override
  String get restaurantSignupSectionBasic => 'Basic Information';

  @override
  String get restaurantSignupSectionAi => 'AI Generated Identity';

  @override
  String get restaurantSignupSectionLocation => 'Location & Verification';

  @override
  String get restaurantSignupGeneratedStoryLabel => 'Generated Story:';

  @override
  String get restaurantSignupNotVerified => 'Not Verified';

  @override
  String get restaurantSignupAppBarTitle => 'Restaurant Registration';

  @override
  String get restaurantSignupBackButton => 'Back';

  @override
  String get restaurantSignupNextButton => 'Next';

  @override
  String get restaurantSignupSubmitButton => 'Submit';

  @override
  String get restaurantSignupSuccess => 'Registration completed successfully!';

  @override
  String get restaurantSignupErrorCompanyNameRequired =>
      'Company name is required';

  @override
  String get restaurantSignupErrorOwnerNameRequired => 'Owner name is required';

  @override
  String get restaurantSignupErrorTaglineRequired =>
      'Please provide a tagline to generate your profile';

  @override
  String get restaurantSignupErrorAiProfileRequired =>
      'Please generate and review your AI profile';

  @override
  String get restaurantSignupErrorCategoryRequired =>
      'Please select at least one category';

  @override
  String get restaurantSignupErrorAddressRequired => 'Address is required';

  @override
  String get restaurantSignupErrorVerificationRequired =>
      'You must verify your documents and address';

  @override
  String get restaurantSignupErrorAiGenerationFailed =>
      'Failed to generate profile. Please try again.';

  @override
  String get restaurantSignupErrorVerificationFailed =>
      'Verification failed. Please try again.';

  @override
  String get restaurantSignupErrorTaglineFirst =>
      'Please provide a tagline first';

  @override
  String get restaurantSignupErrorAddressFirst =>
      'Please provide an address first';

  @override
  String get orderItemPrice => 'Item Price';

  @override
  String get aiValidationUploadPrompt => 'Tap to capture or upload photo';

  @override
  String get aiValidationAnalyzingStep1 => 'AI is analyzing your photo...';

  @override
  String get aiValidationAnalyzingStep2 => 'Checking document clarity...';

  @override
  String get aiValidationAnalyzingStep3 => 'Verifying authenticity...';

  @override
  String get aiValidationSuccessTitle => 'Photo Verified!';

  @override
  String get aiValidationSuccessSubtitle =>
      'Your photo meets all requirements.';

  @override
  String get aiValidationRetryButton => 'Try Again';

  @override
  String get aiValidationErrorTitle => 'Validation Failed';

  @override
  String get aiValidationErrorUnknown => 'An unexpected error occurred.';

  @override
  String get aiValidationStatusSuccess => 'Verified Successfully';

  @override
  String get aiValidationStatusInvalid => 'Photo does not meet criteria.';

  @override
  String get aiValidationStatusErrorUnknown => 'Unknown validation error.';

  @override
  String get aiValidationScanning => 'Scanning Document...';

  @override
  String get aiValidationVerifyingStamps => 'Verifying Official Stamps...';

  @override
  String get aiValidationMatchingData => 'Matching with Gov Database...';

  @override
  String get aiValidationExtractedData => 'AI Extracted Data';

  @override
  String get aiValidationDocId => 'Document ID';

  @override
  String get aiValidationOrg => 'Organization';

  @override
  String get aiValidationAuthenticity => 'Authenticity Score';

  @override
  String get aiValidationFutureVision =>
      'Future Vision: Production version will integrate with Jordan\'s Digital Identity (Sanad) for 100% verification.';

  @override
  String get aiPulseStampOk => 'STAMP_DETECTED';

  @override
  String get aiPulseIdMatch => 'ID_CONFIRMED';

  @override
  String get aiPulseExpiryValid => 'VALID_EXPIRY';

  @override
  String get aiPulseSecurePaper => 'SECURITY_PAPER_OK';

  @override
  String get aiLivenessCheck => 'AI Liveness & Identity Secured';

  @override
  String get signupCuisineType => 'Cuisine / Business Type';

  @override
  String get signupCuisineTypeHint => 'e.g., Italian, Fast Food, Bakery';

  @override
  String get signupPrimaryCategory => 'Primary Product / Category';

  @override
  String get signupPrimaryCategoryHint => 'e.g., Fresh Produce, Dairy';

  @override
  String get signupSectionVehicle => 'Vehicle Information';

  @override
  String get signupVehiclePlate => 'License Plate Number';

  @override
  String get signupVehiclePlateHint => 'e.g., 12-34567';

  @override
  String get signupVehicleModel => 'Vehicle Make and Model';

  @override
  String get signupVehicleModelHint => 'e.g., Toyota Prius 2020';

  @override
  String get signupVehicleColor => 'Vehicle Color';

  @override
  String get signupVehicleColorHint => 'e.g., White';
}
