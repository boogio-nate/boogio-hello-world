# Boogio Hello World Example App
An iOS example app project which connects to Boogio.

Data are displayed as labels and can be exported as CSV file email attachments.

A SettingsViewController class is also included, demonstrating how to scan for and save device UUIDs and Names.

This project uses a BoogioPeripheralNetworkManager framework which is still in development but significantly reduces the complexity of this project. As it nears completion, the framework source will be made freely available. 

The BoogioPeripheralNetworkManager framework included in the project filters is not built for the x86_64 architecture. Since the iOS simulator does not support Bluetooth Smart, it's recommended that an physical iOS device be used for testing. If you would like to test in the simulator anyway, simply replace the BoogioPeripheralNetworkManager.framework file with the one located inside the iOSSimulatorCompatibleFramework directory.

# Additional Resources
[Boogio GATT Profile](https://docs.google.com/spreadsheets/d/18u-qWGmsG79L1HoE3lomMrKSECGabgpAPc04W_Xv1y0/edit?usp=sharing)

[CoreBluetooth Documentation](https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/AboutCoreBluetooth/Introduction.html)
