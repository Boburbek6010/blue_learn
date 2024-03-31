package com.example.shake2share

import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattDescriptor
import android.bluetooth.BluetoothGattServer
import android.bluetooth.BluetoothGattServerCallback
import android.bluetooth.BluetoothGattService
import android.bluetooth.BluetoothGattService.SERVICE_TYPE_PRIMARY
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanFilter
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.ParcelUuid
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.EventChannel
import java.util.Collections
import java.util.Random
import java.util.UUID
import io.flutter.plugin.common.MethodChannel
import java.lang.Exception


class BleManager(private val context: Context) {
    private val listDevises = Collections.synchronizedList(mutableListOf<BluetoothDevice>())
    private var CHARACTER_UUID = UUID.fromString("402aec02-cd45-4e5f-b2cc-35beb0960b2c");
    private var SERVICE_UUID = UUID.fromString("b2c10ae9-3747-4d14-abd1-0450be65fb05");

    private var bleGatt: BluetoothGatt? = null;
    private var server: BluetoothGattServer? = null
    var scanSink: EventChannel.EventSink? = null;
    var connectSink: EventChannel.EventSink? = null
    var result: MethodChannel.Result? = null;
    private var receiver: String? = null;
    var hasService = false;
    var mtuchanged = false;
    var connecting = false;

    private val bluetoothManager by lazy {
        context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    }

    private val bluetoothAdapter by lazy {
        bluetoothManager.adapter;
    }

    private val bluetoothLeAdvertiser by lazy {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            bluetoothManager.adapter.bluetoothLeAdvertiser
        } else {
            TODO("VERSION.SDK_INT < LOLLIPOP")
        }
    }

    private val bluetoothLeScanner by lazy {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            bluetoothManager.adapter.bluetoothLeScanner
        } else {
            TODO("VERSION.SDK_INT < LOLLIPOP")
        }
    }


    @SuppressLint("HardwareIds")
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun startAdvertiser(
        uuid: String?,
        timeOut: Int?,
        localName: String?,
        receiver: String?
    ) {
        stopScans();
        disconnect();
        listDevises.clear()
        this.receiver = receiver;
        if (uuid != null) {
            SERVICE_UUID = UUID.fromString(uuid);
        }

        val settings = AdvertiseSettings.Builder()
            .setConnectable(true)
            .setTimeout(timeOut ?: 180000) // 18000
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM)
            .build()


        val data = AdvertiseData.Builder()
            .setIncludeDeviceName(false)
            .addServiceUuid(ParcelUuid(SERVICE_UUID))
            .build()


        val scanResponse = AdvertiseData.Builder()
            .setIncludeDeviceName(true)
            .build()



        bluetoothAdapter.name = "${bluetoothAdapter.address}+${Random().nextInt(100)}";
        println(" ---> adapter name ${bluetoothAdapter.name}")
        println(" ---> adapter name ${bluetoothAdapter.address}")

        bluetoothLeAdvertiser
            .startAdvertising(settings, data, scanResponse, advertiseCallback)

    }


    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun startBluetoothScan() {

        val filter = ScanFilter.Builder()
            .setServiceUuid(ParcelUuid(SERVICE_UUID))
            .build()


        val settings: ScanSettings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .build()


        if (bluetoothIsEnabled()) {
            bluetoothLeScanner?.startScan(
                listOf(filter),
                settings,
                scanCallback
            )
        }
    }


    fun turnOn(activity: Activity, enableBluetoothRequestCode: Int) {
        val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
        activity.startActivityForResult(enableBtIntent, enableBluetoothRequestCode)
    }


    fun bluetoothIsEnabled(): Boolean {
        return bluetoothAdapter.isEnabled;
    }

    private fun openGattServer() {
        if (server == null) {
            server = bluetoothManager.openGattServer(context, serverCallback)
        }
        println("--->openGattServer $server")
        writeChar(receiver, false);
    }

    fun turnOnResult() {
        try {
            result?.success(bluetoothIsEnabled())

        } catch (e: Exception) {
        }
    }

    @TargetApi(Build.VERSION_CODES.M)
    fun connectToDevice(address: String?) {
        disconnect();
        bluetoothLeScanner.stopScan(scanCallback);
        Handler().postDelayed({
            println("---> connecting adress $address")
            connecting = true;
            val device = listDevises.find { it.address == address };
            println("---> connecting to $device")
            mtuchanged = false;
            device?.connectGatt(context, false, gattCallBack, BluetoothDevice.TRANSPORT_LE);
        }, 1000)
    }

    fun readChar() {
        val service = bleGatt?.getService(SERVICE_UUID)
        if (service != null) {
            val characteristic = service.getCharacteristic(CHARACTER_UUID)
            println("characteristic $characteristic")
            val read = bleGatt?.readCharacteristic(characteristic)
            println("isRead $read")
        } else {
            println("-->server null, $bleGatt")
        }
    }


    fun writeChar(data: String?, forCancel: Boolean) {
        if (server?.getService(SERVICE_UUID) == null) {
            val gattService = BluetoothGattService(SERVICE_UUID, SERVICE_TYPE_PRIMARY)
            val characteristic = BluetoothGattCharacteristic(
                CHARACTER_UUID,
                BluetoothGattCharacteristic.PROPERTY_READ,
                BluetoothGattCharacteristic.PERMISSION_READ or BluetoothGattCharacteristic.PERMISSION_WRITE
            )
            characteristic.addDescriptor(
                BluetoothGattDescriptor(
                    UUID.fromString("00002902-0000-1000-8000-00805f9b34fb"),
                    BluetoothGattDescriptor.PERMISSION_WRITE
                )
            )
            characteristic.setValue(data)
            println("---> setter ${characteristic.value.decodeToString()}")
            gattService.addCharacteristic(characteristic)
            server?.addService(gattService)
        } else {
            val characteristic =
                server?.getService(SERVICE_UUID)?.getCharacteristic(CHARACTER_UUID)
            val update = characteristic?.setValue(data)
            println("---> update $update");
        }
        if (!forCancel) {
            try {
                result?.success(true);
            } catch (e: Exception) {

            }
        }

    }


    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun stopScans() {
        bluetoothLeScanner.stopScan(scanCallback)
        bluetoothLeAdvertiser.stopAdvertising(advertiseCallback)
    }


    fun disconnect() {
        val refreshMethod = bleGatt?.javaClass?.getMethod("refresh")
        val success = refreshMethod?.invoke(bleGatt) as Boolean?
        if (success == true) {
            println("---> gatt cashe cleaned")
        } else {
            println("---> gatt cashe error $bleGatt")
        }
        bleGatt?.disconnect()
        bleGatt?.close()
        bleGatt = null;
    }

    @SuppressLint("HardwareIds")
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun onCancel() {
        stopScans();
        val settings = AdvertiseSettings.Builder()
            .setConnectable(true)
            .setTimeout(2000) // 18000
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM)
            .build()

        val data = AdvertiseData.Builder()
            .setIncludeDeviceName(false)
            .addServiceUuid(ParcelUuid(SERVICE_UUID))
            .build()

        val scanResponse = AdvertiseData.Builder()
            .setIncludeDeviceName(true)
            .build()

        bluetoothAdapter.name = "${bluetoothAdapter.address}+${Random().nextInt(100)}";

        bluetoothLeAdvertiser
            .startAdvertising(settings, data, scanResponse, advertiseForRemoveCallback)
    }

    private val advertiseCallback = @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
            println("->>>>onStartSuccess: $settingsInEffect ")
            startBluetoothScan();
            openGattServer();
            super.onStartSuccess(settingsInEffect)
        }

        override fun onStartFailure(errorCode: Int) {
            println("->>>>onStartFailure: $errorCode ")
            result?.success(false);
            super.onStartFailure(errorCode)
        }
    }

    private val advertiseForRemoveCallback = @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
            println("->>>>onStartSuccess: $settingsInEffect ")
            writeChar("null", true)
            Handler().postDelayed({
                stopScans();
                listDevises.clear();
            }, 1000)
            super.onStartSuccess(settingsInEffect)
        }

        override fun onStartFailure(errorCode: Int) {
            println("->>>>onStartFailure: $errorCode ")
            Handler().postDelayed({
                stopScans();
                listDevises.clear();
            }, 1000)
            super.onStartFailure(errorCode)
        }
    }


    private val serverCallback = object : BluetoothGattServerCallback() {
        override fun onConnectionStateChange(device: BluetoothDevice?, status: Int, newState: Int) {
            super.onConnectionStateChange(device, status, newState)
        }

        @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
        override fun onCharacteristicReadRequest(
            device: BluetoothDevice?,
            requestId: Int,
            offset: Int,
            characteristic: BluetoothGattCharacteristic?
        ) {
            super.onCharacteristicReadRequest(device, requestId, offset, characteristic)
            println("---> server response ${characteristic?.value?.decodeToString()}")

            val originalValue = characteristic?.value?.decodeToString();
            val responseBytes = originalValue?.toByteArray()

            server?.sendResponse(
                device, requestId,
                BluetoothGatt.GATT_SUCCESS,
                offset,
                responseBytes
            )
        }

        override fun onMtuChanged(device: BluetoothDevice?, mtu: Int) {
            super.onMtuChanged(device, mtu)
            println("-->mtu $mtu")
        }
    }

    private val scanCallback = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        object : ScanCallback() {
            @RequiresApi(Build.VERSION_CODES.N)
            @SuppressLint("HardwareIds")
            override fun onScanResult(callbackType: Int, result: ScanResult) {
                val isContain =
                    listDevises.find { it.name == result.device.name && it.address == result.device.address } != null

                if (!isContain) {
                    listDevises.add(result.device);
                }

                if (result.device.name.contains("Optional")) {
                    val hashMap: HashMap<String, Any?> = HashMap();
                    hashMap["id"] = result.device?.address;
                    hashMap["name"] = result.device?.name;
                    hashMap["isConnected"] = isConnected(result.device);
                    hashMap["uuid"] = result.device?.name;
                    invokeResult(hashMap);
                } else {
                    val hashMap: HashMap<String, Any?> = HashMap();
                    hashMap["id"] = result.device?.address;
                    hashMap["name"] = result.device?.name;
                    hashMap["isConnected"] = isConnected(result.device);
                    hashMap["uuid"] = result.device?.name?.split("+")?.get(0);
                    invokeResult(hashMap);
                }

                super.onScanResult(callbackType, result)
            }

            fun isConnected(device: BluetoothDevice): Boolean {
                val connectedDevice = bluetoothManager.getConnectedDevices(BluetoothProfile.GATT);
                return connectedDevice.find { it.address == device.address } != null;
            }

            override fun onScanFailed(errorCode: Int) {
                super.onScanFailed(errorCode)
                println("->>>>error: ${errorCode} ")
            }

            override fun onBatchScanResults(results: MutableList<ScanResult>?) {
                super.onBatchScanResults(results)
                println("->>>>succesBatch: ${results} ")
            }
        }
    } else {
        TODO("VERSION.SDK_INT < LOLLIPOP")
    }

    private val gattCallBack =
        object : BluetoothGattCallback() {
            @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
            override fun onServicesDiscovered(gatt: BluetoothGatt?, status: Int) {
                bleGatt = gatt;
                if (!mtuchanged) {
                    mtuchanged = gatt?.requestMtu(512) ?: false;
                }
                if (BluetoothGatt.GATT_SUCCESS == status) {
                    val service = gatt?.getService(SERVICE_UUID)
                    val characteristic = service?.getCharacteristic(CHARACTER_UUID)
                    if (characteristic != null) {
                        Handler(Looper.getMainLooper()).postDelayed({
                            val read = gatt.readCharacteristic(characteristic)
                            println("---> characteristic, $characteristic")
                            hasService = read
                            println("---> reeeeed, $read")
                            if (!hasService) {
                                invokeConnectionResult(null)
                            }
                        }, 500)
                    } else {
                        invokeConnectionResult(null)
                    }
                }
                super.onServicesDiscovered(gatt, status)
            }

            @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
            override fun onConnectionStateChange(gatt: BluetoothGatt?, status: Int, newState: Int) {
                println("--->gatt state INCOME, $status")
                println("--->gatt state INCOME, $newState")
                startBluetoothScan();
                when (newState) {
                    BluetoothProfile.STATE_CONNECTED -> {
                        gatt?.discoverServices()
                        connecting = false;
                        println("--->gatt state STATE_CONNECTED")
                    }

                    BluetoothProfile.STATE_DISCONNECTED -> {
                        if (connecting) {
                            invokeConnectionResult(null)
                            connecting = false;
                        }
                        println("gatt state STATE_DISCONNECTED")
                    }

                    BluetoothProfile.STATE_CONNECTING -> {
                        println("gatt state STATE_CONNECTING")
                    }

                    BluetoothProfile.STATE_DISCONNECTING -> {
                        println("gatt state STATE_DISCONNECTING")
                    }
                }
                super.onConnectionStateChange(gatt, status, newState)
            }


            @Deprecated("Deprecated in Java")
            override fun onCharacteristicRead(
                gatt: BluetoothGatt?,
                characteristic: BluetoothGattCharacteristic?,
                status: Int
            ) {
                super.onCharacteristicRead(gatt, characteristic, status)
                println("---> read actoin")
                Handler(Looper.getMainLooper()).post {
                    val characteristicValue: ByteArray? = characteristic?.value
                    val decodedString: String = characteristicValue?.decodeToString() ?: ""
                    println("---> decodedString $decodedString")
                    invokeConnectionResult(decodedString)
                }
            }
        }


    private fun invokeResult(data: Any?) {
        Handler(Looper.getMainLooper()).post {
            synchronized(Any()) {
                scanSink?.success(data)
                    ?: println("invokeMethodUIThread: tried to call method on closed channel: $data")
            }
        }
    }


    private fun invokeConnectionResult(data: Any?) {
        Handler(Looper.getMainLooper()).post {
            synchronized(Any()) {
                connectSink?.success(data)
                    ?: println("invokeMethodUIThread: tried to call method on closed channel: $data")
            }
        }
    }


}

