// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Education App';

  @override
  String get welcome => 'Welcome';

  @override
  String get toEducationSystem => 'to Education System';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get login => 'Login';

  @override
  String get enterCode => 'Enter Code';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get seconds => 'seconds';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get educationAssistant => 'Education Assistant';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get selectGrade => 'Select Grade';

  @override
  String get mathematics => 'Mathematics';

  @override
  String get physics => 'Physics';

  @override
  String get chemistry => 'Chemistry';

  @override
  String get biology => 'Biology';

  @override
  String get literature => 'Literature';

  @override
  String get english => 'English';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get email => 'Email';

  @override
  String get grade => 'Grade';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get logout => 'Logout';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterFirstName => 'Enter your first name';

  @override
  String get enterLastName => 'Enter your last name';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get fontSize => 'Font Size';

  @override
  String get language => 'Language';

  @override
  String get persian => 'Persian';

  @override
  String get englishLang => 'English';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading';

  @override
  String get guestSettings => 'Guest Settings';

  @override
  String get phone => 'Phone';

  @override
  String get otp => 'OTP';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get reset => 'Reset';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get resetDescription => 'All settings will be restored to default';

  @override
  String get confirmReset => 'Confirm Reset';

  @override
  String get resetConfirmMessage => 'Are you sure you want to reset all settings to default?';

  @override
  String get cancel => 'Cancel';

  @override
  String get resetSuccess => 'Settings reset successfully';

  @override
  String get invalidEmail => 'Invalid email format';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get invalidPhone => 'Phone number must be 11 digits starting with 09';

  @override
  String get courseTopics => 'Course Topics';

  @override
  String get loadingTopics => 'Loading topics';

  @override
  String get errorLoadingTopics => 'Error loading topics';

  @override
  String get retry => 'Retry';

  @override
  String get noTopicsAvailable => 'No topics available';

  @override
  String get viewDetailedAnswer => 'View Detailed Answer';

  @override
  String get hideDetailedAnswer => 'Hide Detailed Answer';

  @override
  String get questionYear => 'Year';

  @override
  String get questionDesigner => 'Designer';

  @override
  String get answerAuthor => 'Answer Author';

  @override
  String get noQuestions => 'No questions available';

  @override
  String get correctOption => 'Correct Option';

  @override
  String get yourSelection => 'Your Selection';

  @override
  String get back => 'Back';

  @override
  String questionNumber(int number) {
    return 'Question $number';
  }

  @override
  String get textView => 'Text';

  @override
  String get fullImage => 'Full Image';

  @override
  String fullQuestionImage(int number) {
    return 'Full Question Image $number';
  }

  @override
  String get noFullQuestionImage => 'No full image is registered for this question.';

  @override
  String get backToTextView => 'Back to Text View';

  @override
  String get text => 'Text';

  @override
  String get image => 'Image';

  @override
  String get detailedAnswer => 'Detailed Answer';

  @override
  String detailedAnswerImage(int number) {
    return 'Detailed Answer Image for Question $number';
  }

  @override
  String get imageZoomPan => 'Zoom and pan image';

  @override
  String get resetZoom => 'Reset Zoom';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get selectAnswerOption => 'Select Answer Option';

  @override
  String optionSelected(int option) {
    return 'Option $option selected';
  }

  @override
  String get option => 'Option';
}
