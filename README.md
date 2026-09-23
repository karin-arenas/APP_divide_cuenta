# Divide Cuenta

App Android (Flutter) para uso **100% personal y local** — no está pensada para
subir a Google Play, sólo para instalar el APK directamente en tu teléfono y
el de tus amigos.

## ¿Qué hace?

1. Creas un **Evento** (ej: "Cena Araguaney") y eliges qué **Personas** de tu
   libreta participaron (o agregas gente nueva al vuelo).
2. Tomas una **foto de la boleta** (o la eliges de la galería) y la
   **recortas** para dejar solo la boleta (sin mesa, manos ni fondo). La app
   la envía directamente desde tu teléfono a la API de **Gemini** (Google)
   para leer los ítems, cantidades y precios automáticamente, mostrando
   mensajes de progreso mientras espera la respuesta.
3. Revisas y corriges los ítems detectados en una tabla editable (siempre
   puedes agregar/borrar/editar filas, o saltarte el OCR e ingresar todo a
   mano si no tienes clave API).
4. Marcas **quién comió qué**: cada ítem se reparte en partes iguales entre
   las personas que lo compartieron.
5. Agregas **consumos adicionales** si hace falta (cover, otra ronda, etc).
6. Configuras la **propina** (10% por defecto, editable, con monto fijo o sin
   propina para personas específicas).
7. Ves el **resumen final**: una tabla con el detalle de cada ítem, el
   consumo por persona, la propina y el total final — todo redondeado a
   pesos enteros, sin perder ni ganar plata en el redondeo.
8. **Guardas** el evento (queda en tu Historial para reabrir/editar/borrar
   después — incluyendo el **nombre y la fecha**, editables en cualquier
   momento desde el resumen), lo **exportas a Excel** (.xlsx con formato) y
   lo **compartes** por WhatsApp, email, etc.

Todos los datos (personas, eventos, boletas procesadas) se guardan **sólo en
tu teléfono**, en una base de datos SQLite local. No hay servidor propio, no
hay login, no hay sincronización a la nube. La única llamada de red que hace
la app es directamente a la API de Google Gemini cuando tú decides leer una
boleta por foto.

## Obtener una clave API de Gemini (gratis)

1. Entra a **https://aistudio.google.com/apikey** con tu cuenta de Google.
2. Genera una nueva API key (el plan gratuito de Gemini alcanza de sobra para
   este uso personal).
3. Copia la clave y pégala en la app: **Ajustes → Gemini API key → Guardar**.

Si no configuras una clave, igual puedes usar la app: simplemente elige
"Ingresar manualmente" al momento de la foto y completa los ítems a mano.

## Estructura del proyecto

```
lib/
  main.dart                          Punto de entrada de la app
  models/
    person.dart                      Persona (libreta persistente)
    evento.dart                      Evento + TipOverride (anulación de propina por persona)
    receipt_item.dart                Ítem de boleta / consumo adicional
    event_draft.dart                 Estado mutable en memoria del evento mientras se arma
    split_result.dart                Lógica de reparto y redondeo exacto (sin perder pesos)
  db/
    db_helper.dart                   Apertura de la base SQLite y esquema (CREATE TABLE)
    people_repository.dart           CRUD de personas
    events_repository.dart           CRUD de eventos completos (cabecera + ítems + shares + propina)
  services/
    settings_service.dart            Guardado local de la clave API (shared_preferences)
    gemini_ocr_service.dart          Llamada a la API de Gemini y parseo del JSON de ítems
    excel_export_service.dart        Generación del .xlsx formateado
  screens/
    home_inicio_screen.dart          Panel de inicio (dashboard): acceso rápido y actividad reciente
    home_historial.dart              Historial de eventos (lista, abrir, borrar)
    event_new_screen.dart            Nombre y fecha del evento nuevo
    event_people_select_screen.dart  Elegir participantes desde la libreta
    event_ocr_capture_screen.dart    Foto de la boleta (cámara/galería) + llamada a Gemini
    event_correction_table_screen.dart  Tabla editable de ítems (paso obligatorio)
    event_item_assignment_screen.dart   Asignar personas a cada ítem (con total corriente)
    event_extra_items_screen.dart    Agregar consumos adicionales
    event_tip_screen.dart            Configurar propina (global y por persona)
    event_summary_result_screen.dart Resumen final, guardar, exportar Excel, compartir
    people_manager_screen.dart       Administrar la libreta de personas (agregar/renombrar/borrar)
    settings_screen.dart             Clave API de Gemini (+ "Probar conexión") y borrar todos los datos
  theme/
    app_theme.dart                   Tema oscuro "Precision Ledger" (colores, tipografía, formas)
  widgets/
    app_bottom_nav.dart              Barra de navegación inferior (Inicio/Nuevo/Historial/Contactos/API)
    app_header_bar.dart              Encabezado de marca (logo + título + subtítulo de sección)
    money_text.dart                  Formato de moneda CLP ($11.550) en tipografía monoespaciada
    person_chip_selector.dart        Chips seleccionables de personas (reutilizado en varias pantallas)

android/app/src/main/
  AndroidManifest.xml                 Permisos de cámara/galería, actividad UCropActivity
                                       (recorte de imagen) y su tema, ícono de la app
  kotlin/.../MainApplication.kt       Application personalizada: solo aplica el padding de
                                       las barras del sistema a actividades nativas de
                                       terceros (la pantalla de recorte), para que no queden
                                       tapadas por la barra de estado/navegación en
                                       Android 16 (ver "Notas técnicas" más abajo)
  res/mipmap-*/ic_launcher.png        Ícono de la app (todas las densidades)
```

## Diseño visual

La app usa el sistema de diseño **"Precision Ledger"** (tema oscuro, azul/cian
hielo, tipografía Space Grotesk + Hanken Grotesk + JetBrains Mono) definido en
`design_reference/`. Los mockups HTML de esa carpeta son sólo referencia
visual (no se compilan); el tema real vive en `lib/theme/app_theme.dart` y se
aplica a toda la app desde `main.dart`.

## Cómo compilar el APK

### Opción recomendada: dejar que GitHub lo compile gratis (no instalas nada)

Este proyecto ya incluye un workflow (`.github/workflows/build-apk.yml`) que
compila el APK automáticamente en los servidores de GitHub:

1. Crea una cuenta gratis en https://github.com si no tienes una.
2. Crea un repositorio nuevo (puede ser **privado**): botón verde
   "New" en https://github.com/new.
3. Sube el contenido de esta carpeta al repositorio. La forma más fácil sin
   usar la terminal: en la página del repo vacío, click en
   "uploading an existing file" y arrastra todos los archivos y carpetas
   (incluida la carpeta oculta `.github`).
4. Ve a la pestaña **Actions** del repositorio. Debería aparecer un run
   "Build APK" corriendo solo (tarda unos 5-8 minutos).
5. Cuando termine (círculo verde ✓), entra a ese run, baja hasta
   **Artifacts** y descarga `divide-cuenta-apk` (es un .zip que trae el
   `.apk` adentro).
6. Pasa ese `.apk` a tu teléfono e instálalo (ver sección más abajo).

Si subes cambios más adelante (por ejemplo si pides ajustes al código), basta
con volver a subir los archivos modificados y el workflow se ejecuta de
nuevo solo.

### Opción alternativa: compilar en tu propio computador

Requisitos en tu máquina (no en este sandbox — ver más abajo):

- Flutter SDK (canal stable) instalado y en el `PATH`.
- Android SDK con `platform-tools` y la plataforma/build-tools que pida el
  `compileSdk` de turno (el proyecto usa `flutter.compileSdkVersion`, así
  que sigue automáticamente la versión que recomiende tu Flutter SDK
  instalado). Android Studio los descarga solo al abrir el proyecto o al
  primer intento de build.
- JDK 17 (el que trae Android Studio sirve).

Pasos:

```bash
cd divide_cuenta
flutter pub get
flutter build apk --debug
```

El APK queda en `build/app/outputs/flutter-apk/app-debug.apk`. Un build
`--debug` no necesita firma de release y es perfecto para instalar en tu
propio teléfono.

Si prefieres un APK algo más liviano y optimizado (igual instalable sin Play
Store, sin necesidad de una keystore propia porque este proyecto ya deja el
`release` firmado con la clave de debug):

```bash
flutter build apk --release
```

### Nota sobre `android/gradle/wrapper/gradle-wrapper.jar`

Este proyecto fue armado en un entorno sin acceso a internet a los
servidores de Google/Gradle, así que el binario `gradle-wrapper.jar` (un
`.jar` pequeño, no un archivo de texto) no pudo descargarse ni incluirse
aquí. Si al ejecutar `./gradlew` o `flutter build apk` ves un error de tipo
"gradle-wrapper.jar not found" o similar, arréglalo con **cualquiera** de
estas opciones (una sola vez, con internet):

- Opción rápida: `flutter create --platforms android .` dentro de la carpeta
  del proyecto. Esto sólo regenera archivos de plantilla faltantes (como el
  wrapper), no toca tu código en `lib/`.
- Opción alternativa: si tienes Gradle instalado en tu sistema, entra a
  `android/` y ejecuta `gradle wrapper --gradle-version 8.6`.
- Abrir el proyecto en Android Studio también regenera el wrapper
  automáticamente al sincronizar.

## Instalar el APK en tu teléfono (sin Play Store)

1. Copia el archivo `app-debug.apk` (o `app-release.apk`) a tu teléfono
   Android (por cable USB, WhatsApp, Google Drive, lo que te acomode).
2. En el teléfono, ve a **Ajustes → Seguridad** (o Ajustes → Apps →
   Acceso especial) y activa **"Instalar apps desconocidas"** para la app
   que uses para abrir el archivo (ej: tu explorador de archivos o Chrome).
3. Abre el archivo `.apk` desde el teléfono y toca **Instalar**.
4. Listo — abre "Divide Cuenta" desde el cajón de aplicaciones.

No hace falta cuenta, ni Play Store, ni conexión permanente a internet
(salvo el momento puntual en que se lee una boleta con Gemini).

## Notas técnicas (para quien retome el código)

- **Modelo de Gemini**: la app usa `gemini-3.6-flash` (constante `_model` en
  `lib/services/gemini_ocr_service.dart`). Si Google vuelve a dar de baja un
  modelo, el propio error que devuelve la API dice cuál es el reemplazo
  sugerido.
- **Localización**: el proyecto depende de `flutter_localizations` (paquete
  del SDK de Flutter, no de pub.dev) y declara sus delegates en
  `lib/main.dart`. Es necesario para que `MaterialLocalizations` resuelva
  correctamente el locale `es_CL`; sin esto la app crashea con
  "No MaterialLocalizations found" al abrir cualquier pantalla con `AppBar`
  o `NavigationBar`.
- **Recorte de imagen (`image_cropper`)**: requiere declarar
  `com.yalantis.ucrop.UCropActivity` a mano en `AndroidManifest.xml` (no
  se agrega solo al hacer `flutter pub get`); sin eso la app crashea al
  abrir la pantalla de recorte.
- **Edge-to-edge en Android 16 (API 36)**: a partir de esa versión, Android
  fuerza que todas las actividades dibujen su contenido "debajo" de la
  barra de estado/navegación, y ya no hay forma de optar por fuera de esto
  a nivel de tema (el atributo `windowOptOutEdgeToEdgeEnforcement` sólo
  funciona hasta Android 15). Como `UCropActivity` es una librería de
  terceros no actualizada para manejar esto, su barra superior e inferior
  quedaban tapadas. Se resolvió con `MainApplication.kt`: aplica
  manualmente el padding de las barras del sistema a cualquier actividad
  que no sea de Flutter (las pantallas de Flutter ya manejan sus propios
  insets con `SafeArea` en Dart, así que no se tocan).
- **Permisos de cámara/galería**: `image_picker` con `ImageSource.camera`
  necesita declarar `android.permission.CAMERA` a mano en el manifest
  (desde `image_picker` 0.8+ ya no se agrega solo). El acceso a galería usa
  `READ_MEDIA_IMAGES` (Android 13+) y `READ_EXTERNAL_STORAGE` con
  `maxSdkVersion="32"` (Android 12 y anteriores).
- **`SafeArea`**: todas las pantallas con botones fijos pegados al borde
  inferior (o contenido que llega hasta ahí) están envueltas en `SafeArea`
  para no quedar detrás de la barra de gestos/navegación del sistema.

## Limitaciones conocidas

- El "Excel en Descargas" intenta guardar directamente en
  `/storage/emulated/0/Download`. En algunos Android recientes con
  almacenamiento con alcance más estricto, si esa ruta no es escribible la
  app cae de vuelta a la carpeta de documentos propia de la app (aún así
  puedes compartirlo o moverlo con cualquier explorador de archivos).
- El OCR depende de la calidad de la foto y de que Gemini interprete bien el
  formato de tu boleta; por eso el paso de corrección manual es obligatorio
  antes de continuar.
