import 'package:flutter/widgets.dart';

import '../models/notchpay_environment.dart';

/// User-facing strings shown by the checkout sheet.
///
/// This package ships built-in English and French translations and picks
/// one automatically from the ambient [Locale] (via
/// `Localizations.localeOf(context)`), so most apps get a localized
/// checkout for free without adding any `localizationsDelegates` /
/// `supportedLocales` setup of their own.
///
/// To support another language, or to override any string, pass a custom
/// instance through `NotchPay.checkout(localizations: ...)`.
class NotchPayLocalizations {
  /// Creates a full set of checkout strings. Every field is required so
  /// that a custom translation can never leave a string blank.
  const NotchPayLocalizations({
    required this.payNow,
    required this.mobileMoneyNumber,
    required this.phoneHint,
    required this.enterPhoneNumber,
    required this.enterValidPhoneNumber,
    required this.confirmOnYourPhone,
    required this.mobileMoneyInstructions,
    required this.mtnInstructions,
    required this.orangeInstructions,
    required this.yoomeeInstructions,
    required this.redirectInstructions,
    required this.choosePaymentMethod,
    required this.changePaymentMethod,
    required this.paymentSuccessTitle,
    required this.paymentSuccessMessage,
    required this.paymentFailedTitle,
    required this.paymentCancelledTitle,
    required this.paymentCancelledMessage,
    required this.paymentExpiredTitle,
    required this.paymentExpiredMessage,
    required this.genericErrorMessage,
    required this.done,
    required this.close,
    required this.retry,
    required this.sandboxModeBanner,
  });

  /// English strings (default / fallback).
  static const NotchPayLocalizations en = NotchPayLocalizations(
    payNow: 'Pay now',
    mobileMoneyNumber: 'Mobile money number',
    phoneHint: '6XX XXX XXX',
    enterPhoneNumber: 'Enter your phone number',
    enterValidPhoneNumber: 'Enter a valid mobile number',
    confirmOnYourPhone: 'Confirm on your phone',
    mobileMoneyInstructions:
        'Approve the USSD prompt on your phone to confirm this payment.',
    mtnInstructions:
        'Approve the prompt on your phone or dial *126# to confirm the MTN Mobile Money payment.',
    orangeInstructions:
        'Approve the prompt on your phone or dial #150*50# to confirm the Orange Money payment.',
    yoomeeInstructions:
        'Approve the prompt on your phone or dial *855# to confirm the YooMee Money payment.',
    redirectInstructions:
        'Complete your payment in the secure window, then come back here.',
    choosePaymentMethod: 'Choose a payment method',
    changePaymentMethod: 'Change payment method',
    paymentSuccessTitle: 'Payment successful',
    paymentSuccessMessage: 'Your payment was received. Thank you!',
    paymentFailedTitle: 'Payment failed',
    paymentCancelledTitle: 'Payment cancelled',
    paymentCancelledMessage: 'The payment was cancelled.',
    paymentExpiredTitle: 'Payment expired',
    paymentExpiredMessage: 'The payment request has expired. Please try again.',
    genericErrorMessage: 'Something went wrong. Please try again.',
    done: 'Done',
    close: 'Close',
    retry: 'Try again',
    sandboxModeBanner: 'Sandbox mode no real money will move',
  );

  /// French strings.
  static const NotchPayLocalizations fr = NotchPayLocalizations(
    payNow: 'Payer maintenant',
    mobileMoneyNumber: 'Numéro mobile money',
    phoneHint: '6XX XXX XXX',
    enterPhoneNumber: 'Entrez votre numéro de téléphone',
    enterValidPhoneNumber: 'Entrez un numéro mobile valide',
    confirmOnYourPhone: 'Confirmez sur votre téléphone',
    mobileMoneyInstructions:
        'Validez la demande USSD sur votre téléphone pour confirmer ce paiement.',
    mtnInstructions:
        'Validez la notification sur votre téléphone ou composez le *126# pour confirmer le paiement MTN Mobile Money.',
    orangeInstructions:
        'Validez la notification sur votre téléphone ou composez le #150*50# pour confirmer le paiement Orange Money.',
    yoomeeInstructions:
        'Validez la notification sur votre téléphone ou composez le *855# pour confirmer le paiement YooMee Money.',
    redirectInstructions:
        'Terminez votre paiement dans la fenêtre sécurisée, puis revenez ici.',
    choosePaymentMethod: 'Choisissez un moyen de paiement',
    changePaymentMethod: 'Changer de moyen de paiement',
    paymentSuccessTitle: 'Paiement réussi',
    paymentSuccessMessage: 'Votre paiement a bien été reçu. Merci !',
    paymentFailedTitle: 'Échec du paiement',
    paymentCancelledTitle: 'Paiement annulé',
    paymentCancelledMessage: 'Le paiement a été annulé.',
    paymentExpiredTitle: 'Paiement expiré',
    paymentExpiredMessage: 'La demande de paiement a expiré. Veuillez réessayer.',
    genericErrorMessage: 'Une erreur est survenue. Veuillez réessayer.',
    done: 'Terminé',
    close: 'Fermer',
    retry: 'Réessayer',
    sandboxModeBanner: 'Mode Test aucun argent réel ne sera déplacé',
  );

  static const Map<String, NotchPayLocalizations> _supported = {
    'en': en,
    'fr': fr,
  };

  /// Label of the main call-to-action button, e.g. `Pay now`.
  final String payNow;

  /// Label above the Mobile Money phone field.
  final String mobileMoneyNumber;

  /// Placeholder text shown inside the empty phone field.
  final String phoneHint;

  /// Validation error shown when the phone field is left empty.
  final String enterPhoneNumber;

  /// Validation error shown when the phone number is not a valid mobile
  /// number.
  final String enterValidPhoneNumber;

  /// Headline shown while polling for the payment's final status.
  final String confirmOnYourPhone;

  /// Instructions shown under [confirmOnYourPhone] for Mobile Money
  /// payments.
  final String mobileMoneyInstructions;

  /// Operator-specific USSD instructions.
  final String mtnInstructions;
  final String orangeInstructions;
  final String yoomeeInstructions;

  /// Instructions shown under [confirmOnYourPhone] for channels completed
  /// through a hosted redirect (e.g. Card).
  final String redirectInstructions;

  /// Label shown above the list of payment channels.
  final String choosePaymentMethod;

  /// Label for going back to channel selection.
  final String changePaymentMethod;

  /// Headline shown when the payment succeeds.
  final String paymentSuccessTitle;

  /// Message shown under [paymentSuccessTitle].
  final String paymentSuccessMessage;

  /// Headline shown when the payment fails.
  final String paymentFailedTitle;

  /// Headline shown when the customer cancels the payment.
  final String paymentCancelledTitle;

  /// Message shown when the customer cancels the payment.
  final String paymentCancelledMessage;

  /// Headline shown when the payment expires before completion.
  final String paymentExpiredTitle;

  /// Message shown when the payment expires before completion.
  final String paymentExpiredMessage;

  /// A generic fallback error message.
  final String genericErrorMessage;

  /// Label of the button that closes the result screen.
  final String done;

  /// Tooltip of the sheet's close (X) button.
  final String close;

  /// Label offered to retry a failed action.
  final String retry;

  /// Shown in a small banner at the top of the sheet when
  /// [NotchPayEnvironment.sandbox] is detected.
  final String sandboxModeBanner;

  /// Resolves the applicable translation for [context]:
  ///
  /// 1. An explicit override passed via `NotchPay.checkout(localizations:
  ///    ...)`, if any.
  /// 2. Otherwise, the ambient [Locale] (via
  ///    `Localizations.localeOf(context)`), falling back to [en] when
  ///    unsupported or when no [Localizations] ancestor is available.
  static NotchPayLocalizations of(BuildContext context) {
    final override = NotchPayLocalizationsProvider.maybeOf(context);
    if (override != null) return override;
    final locale = Localizations.maybeLocaleOf(context);
    if (locale == null) return en;
    return _supported[locale.languageCode] ?? en;
  }
}

/// Makes an explicit [NotchPayLocalizations] override available to the
/// checkout sheet, taking priority over the ambient [Locale].
class NotchPayLocalizationsProvider extends InheritedWidget {
  /// Creates a scope providing [data] to descendant widgets.
  const NotchPayLocalizationsProvider(
      {super.key, required this.data, required super.child});

  /// The translation override made available to descendants via [maybeOf].
  final NotchPayLocalizations data;

  /// Returns the nearest enclosing override, or null if none was provided.
  static NotchPayLocalizations? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<NotchPayLocalizationsProvider>()
        ?.data;
  }

  @override
  bool updateShouldNotify(NotchPayLocalizationsProvider oldWidget) =>
      data != oldWidget.data;
}
