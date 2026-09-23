package com.dividecuenta.divide_cuenta

import android.app.Activity
import android.app.Application
import android.os.Bundle
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import io.flutter.embedding.android.FlutterActivity

/**
 * Application personalizada solo para arreglar un problema de Android 16
 * (API 36): a partir de esa version, "windowOptOutEdgeToEdgeEnforcement"
 * (el flag que se usaba para que actividades nativas antiguas no dibujaran
 * su contenido detras de la barra de estado/navegacion) deja de
 * funcionar y Android fuerza edge-to-edge en TODAS las actividades,
 * incluida la pantalla de recorte de image_cropper (UCropActivity), que
 * es una libreria de terceros que no la actualizaron para manejar los
 * "insets" del sistema. Como no podemos modificar esa libreria, aplicamos
 * manualmente el padding de las barras del sistema a cualquier actividad
 * que NO sea de Flutter (Flutter ya maneja sus propios insets via
 * SafeArea en Dart, asi que la dejamos intacta para no duplicar el
 * padding ahi).
 */
class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        registerActivityLifecycleCallbacks(object : ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
                if (activity is FlutterActivity) return
                val decorView = activity.window.decorView
                ViewCompat.setOnApplyWindowInsetsListener(decorView) { v, insets ->
                    val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
                    v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
                    insets
                }
                ViewCompat.requestApplyInsets(decorView)
            }

            override fun onActivityStarted(activity: Activity) {}
            override fun onActivityResumed(activity: Activity) {}
            override fun onActivityPaused(activity: Activity) {}
            override fun onActivityStopped(activity: Activity) {}
            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
            override fun onActivityDestroyed(activity: Activity) {}
        })
    }
}
