import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show kBackMouseButton;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Fonctions qui demandent la caméra (scanner de code-barres, photo de
/// couverture lue par OCR) : téléphones seulement, ces plugins n'existant pas
/// sur ordinateur.
bool get hasCameraFeatures =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Ordinateur (souris et clavier) : Linux, Windows, macOS.
bool get isDesktop =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS);

/// À partir de cette largeur (Material 3 « medium »), la navigation passe de la
/// barre du bas à un rail latéral : fenêtre d'ordinateur, tablette, paysage.
const double kNavigationRailBreakpoint = 600;

/// Largeur maximale d'une liste ou d'un texte : au-delà, les lignes deviennent
/// trop longues à lire sur un grand écran.
const double kMaxContentWidth = 900;

/// Marges horizontales qui centrent un contenu d'au plus [maxWidth] dans une
/// zone de largeur [width] (et au moins [minimum] de chaque côté). À utiliser
/// comme padding d'une liste : la zone de défilement garde toute la largeur,
/// donc la molette fonctionne partout et la barre de défilement reste au bord.
EdgeInsets centeredPadding(
  double width, {
  double maxWidth = kMaxContentWidth,
  double minimum = 16,
  double top = 0,
  double bottom = 0,
}) {
  final side = math.max(minimum, (width - maxWidth) / 2);
  return EdgeInsets.fromLTRB(side, top, side, bottom);
}

/// Permet de faire défiler à la souris (en glissant) une rangée horizontale :
/// sur ordinateur, la molette ne fait défiler que verticalement.
class MouseDragScroll extends StatelessWidget {
  const MouseDragScroll({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          ...ScrollConfiguration.of(context).dragDevices,
          PointerDeviceKind.mouse,
        },
      ),
      child: child,
    );
  }
}

/// Échap : écran précédent. Placé au-dessus de l'app, ce gestionnaire ne
/// reçoit que les Échap que rien d'autre n'a traités : dialogues, menus et
/// suggestions de saisie gardent leur propre fermeture (on ne perd pas un
/// formulaire en voulant juste masquer des suggestions).
Widget escapeGoesBack(GlobalKey<NavigatorState> navigatorKey, Widget child) =>
    Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          navigatorKey.currentState?.maybePop();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );

/// Bouton « précédent » de la souris : écran précédent.
Widget mouseBackButton(GlobalKey<NavigatorState> navigatorKey, Widget? child) =>
    Listener(
      onPointerDown: (event) {
        if (event.buttons & kBackMouseButton != 0) {
          navigatorKey.currentState?.maybePop();
        }
      },
      child: child,
    );
