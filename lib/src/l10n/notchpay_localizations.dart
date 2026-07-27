import 'package:flutter/widgets.dart';

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
    required this.redirectInstructions,
    required this.choosePaymentMethod,
    required this.paymentSuccessTitle,
    required this.paymentSuccessMessage,
    required this.paymentFailedTitle,
    required this.paymentCancelledTitle,
    required this.paymentExpiredTitle,
    required this.genericErrorMessage,
    required this.done,
    required this.close,
    required this.retry,
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
        'Dial the USSD prompt or approve the request on your phone to confirm this payment.',
    redirectInstructions:
        'Complete your payment in the secure window, then come back here.',
    choosePaymentMethod: 'Choose a payment method',
    paymentSuccessTitle: 'Payment successful',
    paymentSuccessMessage: 'Your payment was received. Thank you!',
    paymentFailedTitle: 'Payment failed',
    paymentCancelledTitle: 'Payment cancelled',
    paymentExpiredTitle: 'Payment expired',
    genericErrorMessage: 'Something went wrong. Please try again.',
    done: 'Done',
    close: 'Close',
    retry: 'Try again',
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
        'Composez le code USSD ou validez la demande sur votre téléphone pour confirmer ce paiement.',
    redirectInstructions:
        'Terminez votre paiement dans la fenêtre sécurisée, puis revenez ici.',
    choosePaymentMethod: 'Choisissez un moyen de paiement',
    paymentSuccessTitle: 'Paiement réussi',
    paymentSuccessMessage: 'Votre paiement a bien été reçu. Merci !',
    paymentFailedTitle: 'Échec du paiement',
    paymentCancelledTitle: 'Paiement annulé',
    paymentExpiredTitle: 'Paiement expiré',
    genericErrorMessage: 'Une erreur est survenue. Veuillez réessayer.',
    done: 'Terminé',
    close: 'Fermer',
    retry: 'Réessayer',
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

  /// Instructions shown under [confirmOnYourPhone] for channels completed
  /// through a hosted redirect (e.g. Card).
  final String redirectInstructions;

  /// Label shown above the list of payment channels.
  final String choosePaymentMethod;

  /// Headline shown when the payment succeeds.
  final String paymentSuccessTitle;

  /// Message shown under [paymentSuccessTitle].
  final String paymentSuccessMessage;

  /// Headline shown when the payment fails.
  final String paymentFailedTitle;

  /// Headline shown when the customer cancels the payment.
  final String paymentCancelledTitle;

  /// Headline shown when the payment expires before completion.
  final String paymentExpiredTitle;

  /// A generic fallback error message.
  final String genericErrorMessage;

  /// Label of the button that closes the result screen.
  final String done;

  /// Tooltip of the sheet's close (X) button.
  final String close;

  /// Label offered to retry a failed action.
  final String retry;

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
