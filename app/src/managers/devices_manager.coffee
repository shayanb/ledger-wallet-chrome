# A device manager for keeping the devices registry and observing device state.
# It emits events when a wallet is plugged in and when it is unplugged
# @event plug Emitted when the ledger wallet is plugged in
# @event unplug Emitted when the ledger wallet is unplugged
class @DevicesManager extends EventEmitter

  _running: no
  _devicesList: []
  _devices: {}

  constructor: ->

  # Start observing if devices are plugged in or unnplugged
  start: () ->
    return if @_running

    checkIfWalletIsPluggedIn = () ->
      chrome.usb.getDevices {productId: 0x1b7c, vendorId: 0x2581}, (devicesUSB) =>
        chrome.hid.getDevices {productId: 0x2b7c, vendorId: 0x2581}, (devicesHID) =>
          devices = devicesUSB.concat(devicesHID)
          oldDevices = @_devices
          @_devices = {}
          for device in devices
            if device.device
              device_id = device.device
            else
              device_id = device.deviceId
            if oldDevices[device_id]?
              @_devices[device_id] = oldDevices[device_id]
            else
              @_devices[device_id] = {id: device_id}
          oldDevicesList = _.values(oldDevices)
          devicesList = _.values(@_devices)
          oldDifferences = (item for item in devicesList when _.indexOf(oldDevicesList, item) == -1)
          newDifferences = (item for item in oldDevicesList when _.indexOf(devicesList, item) == -1)
          differences = newDifferences.concat(oldDifferences)
          for difference in differences
            if _.where(oldDevices, {id: difference.id}).length > 0
              @emit 'unplug', difference
            else
              @emit 'plug', difference


    @_interval = setInterval checkIfWalletIsPluggedIn.bind(this), 200

  # Stop observing devices state
  stop: () ->
    clearInterval @_interval

  # Get the list of devices
  # @return [Array] the list of devices
  devices: () ->
    devices = []
    for key, device of @_devices
      devices.push device
    devices