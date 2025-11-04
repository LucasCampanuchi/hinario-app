import 'package:flutter/foundation.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hinario_flutter/pages/cifras/pages/cifras_web_page/view/cifras_web_page.dart';
import 'package:hinario_flutter/pages/cifras/pages/cifra_web_view_page/view/cifra_web_view_page.dart';

class AppModule extends Module {
  AppModule();

  @override
  void routes(r) {
    r.child(
      '/',
      child: (context) => const CifrasWebPage(),
    );

/*  */
/*  */

    // Rota com parâmetro para web

    r.child(
      '/:id',
      child: (context) => CifraWebViewPage(
        cifraId: int.parse(r.args.params['id']!),
      ),
    );
  }
}
