package pl.budowapro

import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "pl.budowapro/storage",
        ).setMethodCallHandler { call, result ->
            if (call.method != "availableBytes") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val path = call.argument<String>("path")
            if (path == null) {
                result.error("invalid_path", "Storage path is required", null)
                return@setMethodCallHandler
            }

            try {
                result.success(StatFs(path).availableBytes)
            } catch (_: IllegalArgumentException) {
                result.error(
                    "storage_unavailable",
                    "Available storage could not be read",
                    null,
                )
            }
        }
    }
}
