# 🎨 Theme Presets & Customization

The checkout sheet is fully themeable. You can use one of the four built-in presets or craft your own `NotchPayThemeData` from scratch.

---

## 1. Built-in Presets

All presets are factory constructors on `NotchPayThemeData`:

```dart
// Light (default — white background, NotchPay green)
theme: NotchPayThemeData.light()

// Dark mode
theme: NotchPayThemeData.darkMode()

// Emerald green
theme: NotchPayThemeData.emerald()

// Deep purple
theme: NotchPayThemeData.purple()

// Ocean blue
theme: NotchPayThemeData.ocean()
```

Pass the preset to `checkout()`:

```dart
await NotchPay.instance.checkout(
  context,
  request: request,
  theme: NotchPayThemeData.darkMode(),
);
```

---

## 2. Customizing a Preset with `copyWith`

You can start from any preset and tweak individual properties:

```dart
theme: NotchPayThemeData.emerald().copyWith(
  borderRadius: 32,
  primaryColor: const Color(0xFF059669),
),
```

---

## 3. Full Custom Theme

Build your own design from scratch:

```dart
theme: const NotchPayThemeData(
  primaryColor: Color(0xFF0EA5E9),       // Sky blue — button & accents
  backgroundColor: Color(0xFF1E293B),    // Dark card background
  textColor: Color(0xFFF1F5F9),          // Light text
  secondaryTextColor: Color(0xFF94A3B8), // Muted labels
  borderColor: Color(0xFF334155),        // Input borders
  errorColor: Color(0xFFF43F5E),         // Error state
  successColor: Color(0xFF22C55E),       // Success state
  borderRadius: 24,                       // Rounded corners (px)
),
```

---

## 4. Available Theme Properties

| Property             | Type    | Description                                   |
|----------------------|---------|-----------------------------------------------|
| `primaryColor`       | `Color` | Main brand color — buttons, active states     |
| `backgroundColor`    | `Color` | Card / sheet background                       |
| `textColor`          | `Color` | Primary text                                  |
| `secondaryTextColor` | `Color` | Muted / label text                            |
| `borderColor`        | `Color` | Input field & divider borders                 |
| `errorColor`         | `Color` | Validation errors, failure state              |
| `successColor`       | `Color` | Success state, completion checkmark           |
| `borderRadius`       | `double`| Corner radius applied to all rounded elements |

---

## 5. Preset Color Reference

| Preset      | Primary         | Background | Style       |
|-------------|-----------------|------------|-------------|
| `light()`   | `#10B981`       | `#FFFFFF`  | Clean/Minimal |
| `darkMode()`| `#10B981`       | `#111827`  | Dark OLED    |
| `emerald()` | `#059669`       | `#F0FDF4`  | Nature/Fresh |
| `purple()`  | `#7C3AED`       | `#FAF5FF`  | Bold/Premium |
| `ocean()`   | `#0284C7`       | `#F0F9FF`  | Tech/Trust   |

---

## 6. Equality & Immutability

`NotchPayThemeData` is fully immutable and supports `==` / `hashCode` comparison, which makes it safe to use in `const` contexts and `Widget` rebuild guards:

```dart
final a = NotchPayThemeData.emerald();
final b = NotchPayThemeData.emerald();
print(a == b); // true ✅
```

---

## Next Steps

- 🧪 [Testing & Sandbox Guide](Testing-&-Sandbox-Guide)
- ⚡ [API Reference & Backend Services](API-Reference-&-Backend-Services)
