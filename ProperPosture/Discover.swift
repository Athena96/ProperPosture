
// Author:    Jared Franzone
// File:      Discovery.swift
// Version:   1.0
// Purpose:   Hackillinois
// History:
//            1.0 initial version

import Foundation
import CoreBluetooth

// Create instance of myself... Probably what calls the init
let DiscoverInstance = Discover();
var message: String?


class Discover: NSObject, CBCentralManagerDelegate {
    
    private var myCentralManager: CBCentralManager?
    private var myPeripheral: CBPeripheral?
    
    var bluetoothService: Service? {
        didSet {
            if let service = self.bluetoothService {
                service.startDiscoveringServices()
            }
        }
    }
    
    // 1.
    override init() {
        
        super.init()
        
        //let centralQueue = dispatch_queue_create("com.jaredFranzone.ProperPosture", DISPATCH_QUEUE_SERIAL)
        myCentralManager = CBCentralManager(delegate: self, queue: nil)
        
        print("myCentralManager is initialized")
    }
    
    // 2. 
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        print("Finding the state of the central")

        
        switch ( central.state ) {
            
        case CBCentralManagerState.PoweredOff:
            clearServiceAndPeriph()
        
        case CBCentralManagerState.Unauthorized:
            // "Not Supported message"
            break
        
        case CBCentralManagerState.Unknown:
            // wait...
            break
        
        case CBCentralManagerState.PoweredOn:
            scan()
        
        case CBCentralManagerState.Resetting:
            clearServiceAndPeriph()
        
        case CBCentralManagerState.Unsupported:
            break
        
        }
    
    }
    
    // 3. 
    func scan() {
        
        print("Scanning")
        NSNotificationCenter.defaultCenter().postNotificationName(newNotification, object: self)
        
        if let central = myCentralManager { // declare ServiceUUID in the service class
            central.scanForPeripheralsWithServices([ServiceUUID], options: nil)
        }
        
    }
    
    // 4.
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        print("Discovered peripheral")
        
        // SIMPLIFY TO isEmpty
        let invalidPeripheral = (peripheral.name == nil) || (peripheral.name == "")
        if (invalidPeripheral) {
            NSNotificationCenter.defaultCenter().postNotificationName(newNotification, object: self)

            message = "lost connection, attempting to reconnect"
            return
        }
        
        let notYetConnected = (myPeripheral == nil) || (myPeripheral?.state == CBPeripheralState.Disconnected)
        if (notYetConnected) {

            myPeripheral = peripheral
            
            bluetoothService = nil
            
            central.connectPeripheral(peripheral, options: nil)
            
            print("Discoverd Peripheral: ", peripheral.name)
            print("Connecting")
            
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(newNotification, object: self)

            message = "lost connection, attempting to reconnect"
        }
        
    }
    
    
    // 5. 
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        // Succesfull Connection... send the var to the Service class
        if (peripheral == myPeripheral) {
            bluetoothService = Service(initWithPeripheral: peripheral)
            print("Succesful Connection to: ", peripheral.name)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(newNotification, object: self)

            message = "lost connection, attempting to reconnect"
        }
        
        central.stopScan()
        
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        if (peripheral == myPeripheral) {
            clearServiceAndPeriph()
        }
        scan()
    }
    
    
    // MARK: - Helper
    
    func clearServiceAndPeriph() {
        bluetoothService = nil
        myPeripheral = nil
    }
    
}

