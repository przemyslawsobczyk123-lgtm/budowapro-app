package pl.budowapro

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.provider.ContactsContract
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class ContactPickerHandler(
    private val activity: Activity,
    binaryMessenger: BinaryMessenger,
) {
    private var pendingResult: MethodChannel.Result? = null

    init {
        MethodChannel(binaryMessenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
            if (call.method != PICK_PHONE_CONTACT_METHOD) {
                result.notImplemented()
                return@setMethodCallHandler
            }
            if (pendingResult != null) {
                result.error(
                    "contact_picker_busy",
                    "A contact selection is already active",
                    null,
                )
                return@setMethodCallHandler
            }
            pendingResult = result
            try {
                activity.startActivityForResult(
                    Intent(
                        Intent.ACTION_PICK,
                        ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                    ),
                    PICK_PHONE_CONTACT_REQUEST,
                )
            } catch (_: ActivityNotFoundException) {
                pendingResult = null
                result.error(
                    "contact_picker_unavailable",
                    "No contact picker is available",
                    null,
                )
            } catch (_: SecurityException) {
                pendingResult = null
                result.error(
                    "contact_picker_unavailable",
                    "The contact picker could not be opened",
                    null,
                )
            } catch (_: RuntimeException) {
                pendingResult = null
                result.error(
                    "contact_picker_unavailable",
                    "The contact picker could not be opened",
                    null,
                )
            }
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != PICK_PHONE_CONTACT_REQUEST) return false
        val result = pendingResult ?: return true
        pendingResult = null
        val selectedUri = data?.data
        if (resultCode != Activity.RESULT_OK || selectedUri == null) {
            result.success(null)
            return true
        }

        try {
            val selection = activity.contentResolver.query(
                selectedUri,
                arrayOf(
                    ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                    ContactsContract.CommonDataKinds.Phone.NUMBER,
                ),
                null,
                null,
                null,
            )?.use { cursor ->
                if (!cursor.moveToFirst()) return@use null
                val nameIndex = cursor.getColumnIndex(
                    ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                )
                val phoneIndex = cursor.getColumnIndex(
                    ContactsContract.CommonDataKinds.Phone.NUMBER,
                )
                if (nameIndex < 0 || phoneIndex < 0) return@use null
                val displayName = cursor.getString(nameIndex)?.trim()
                val phone = cursor.getString(phoneIndex)?.trim()
                if (displayName.isNullOrEmpty() || phone.isNullOrEmpty()) {
                    return@use null
                }
                mapOf(
                    "displayName" to displayName,
                    "phone" to phone,
                )
            }
            if (selection == null) {
                result.error(
                    "contact_read_failed",
                    "The selected contact could not be read",
                    null,
                )
            } else {
                result.success(selection)
            }
        } catch (_: SecurityException) {
            result.error(
                "contact_read_failed",
                "The selected contact could not be read",
                null,
            )
        } catch (_: RuntimeException) {
            result.error(
                "contact_read_failed",
                "The selected contact could not be read",
                null,
            )
        }
        return true
    }

    private companion object {
        const val CHANNEL_NAME = "pl.budowapro/device_contacts"
        const val PICK_PHONE_CONTACT_METHOD = "pickPhoneContact"
        const val PICK_PHONE_CONTACT_REQUEST = 7041
    }
}
