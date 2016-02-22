
// Author:    Jared Franzone
// File:      Service.swift
// Version:   1.0
// Purpose:   Hackillinois
// History:
//            1.0 initial version

import Foundation
import CoreBluetooth
import UIKit


// Unique Identification of my Bluetooth Board
let ServiceUUID = CBUUID(string: "025A7775-49AA-42BD-BBDB-E2AE77782966")
// For Recieving Data
let recieveUUID = CBUUID(string:"A9CD2F86-8661-4EB1-B132-367A3434BC90")
// For Sending Data
// sendUUID = CBUUID(string: "F38A2C23-BC54-40FC-BED0-60EDDA139F47")
// Changed Status ID
let ServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"


class Service: NSObject, CBPeripheralDelegate {
    
    var peripheral: CBPeripheral?
    var postureCharacteristic: CBCharacteristic?
    // var sendDataCharacteristic: CBCharacteristic?
    
    init(initWithPeripheral peripheral: CBPeripheral) {
        
        super.init()
        
        self.peripheral = peripheral
        self.peripheral?.delegate = self
        
    }
    
    func startDiscoveringServices() {
        self.peripheral?.discoverServices([ServiceUUID])
    }
    
    deinit {
        self.reset()
    }
    
    func reset() {
        if peripheral != nil {
            peripheral = nil
        }
        
        self.sendBTServiceNotificationWithIsBluetoothConnected(false)
        
    }
    
    func sendBTServiceNotificationWithIsBluetoothConnected(isBTConnected: Bool) {
        
        let connectionDetails = ["isConnected": isBTConnected]
        NSNotificationCenter.defaultCenter().postNotificationName(ServiceChangedStatusNotification, object: self, userInfo: connectionDetails)
    
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        // Add to the array the send Service
        let uuidsForService: [CBUUID] = [recieveUUID]
        
        print("Discover")
        
        if (peripheral != self.peripheral) {
            return
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(newNotification, object: self)
            message = "lost connection, attempting to reconnect"
        }
        
        if(error != nil) {
            return
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(newNotification, object: self)

            message = "lost connection, attempting to reconnect"

        }
        
        let noServices = (peripheral.services == nil) || (peripheral.services!.count == 0)
        if (noServices) {
            return
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(newNotification, object: self)

            message = "lost connection, attempting to reconnect"
        }
        
        for service in peripheral.services! {
            if service.UUID == ServiceUUID {
                peripheral.discoverCharacteristics(uuidsForService, forService: service)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(newNotification, object: self)

                message = "lost connection, attempting to reconnect"

            }
        }
        
    }
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        let wrongPeripheral = peripheral != self.peripheral
        if (wrongPeripheral) {
            return
        }
        
        if (error != nil) {
            return
        }
        
        if let characteristics = service.characteristics {
            
            for characteristic in characteristics {
                if characteristic.UUID == recieveUUID {
                    
                    self.postureCharacteristic = (characteristic)
                    
                    self.peripheral?.readValueForCharacteristic(self.postureCharacteristic!)

                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    
                    self.sendBTServiceNotificationWithIsBluetoothConnected(true)
                    
                    self.peripheral?.readValueForCharacteristic(characteristic)
                }
            } // end for
        }
        
    } // end function
    
    var good:Int32 = 0
    var prev: Int32 = 0
    var bad = false
    
    // Get data values when they are updated
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if let characteristicValue = characteristic.value {
            
            let incomingData = String(data: characteristicValue, encoding: NSUTF8StringEncoding)
            
            if let dataRecieved = incomingData {
                
                let temp1 = dataRecieved.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

                if (temp1.containsString("---")) {
                    bad = true
                } else {
                    bad = false
                    
                    if let tep = Int32(temp1) {
                        if tep != 0 {
                            prev = tep
                            good = tep
                        } else {
                            good = prev
                        }
                    } else {
                        good = prev
                    }
                    
                }
                // Notify the Main VC that we have the data!!!
                NSNotificationCenter.defaultCenter().postNotificationName(mySpecialNotificationKey, object: self)
            }
        }
    }
    
    func readPosture() -> (String, Int32) {
        
        if (bad) {
            return ("BAD_DATA", -1)
        } else {
            return (format(good), good)
        }
    }
    
    
    
    
    func format(seconds: Int32) ->String {
        
        let (h, m, s) = getHourMinSec(seconds)
        var hour = ""; var min = ""; var sec = ""
        if h < 10 {
            hour = "0" + String(h)
        } else {
            hour = String(h)
        }
        
        if m < 10 {
            min = "0" + String(m)
        } else {
            min = String(m)
        }
        
        if s < 10 {
            sec = "0" + String(s)
        } else {
            sec = String(s)
        }
        
        let returnVal = hour + ":" + min + ":" + sec
        
        return returnVal
    }
    
    func getHourMinSec(sec: Int32) ->(Int32, Int32, Int32) {
        return (sec / Int32(3600), (sec % 3600) / 60, (sec % 3600) % 60)
    }
    
    
    
    
   /*
    func sendData(mesg: UInt8) {
        if let dataToSendCharacteristic = self.sendDataCharacteristic {
            var dataToSend = mesg
            let data = NSData(bytes: &dataToSend, length: sizeof(UInt8))
            self.peripheral?.writeValue(data, forCharacteristic: dataToSendCharacteristic, type: CBCharacteristicWriteType.WithResponse)
        }
    }
    */
}
