
class ledger.api.UnspentOutputsRestClient extends ledger.api.RestClient

  getUnspentOutputsFromAddresses: (addresses, callback) ->
    addresses = (address for address in addresses when Bitcoin.Address.validate(address) is true)
    query = _(addresses).join(',')
    @http().get "blockchain/addresses/#{query}/unspents", null,
      (response, request) =>
        l response
        callback?(response)
      ,
      (xhr, status, message) =>
        callback(null, {xhr, status, message})

  getUnspentOutputsFromPaths: (addressesPaths, callback) ->
    ledger.wallet.pathsToAddresses addressesPaths, (addresses, notFound) =>
      l addressesPaths, addresses
      if notFound.length == addressesPaths.length
        callback? null, {title: 'Missing addresses', missings: notFound}
      else
        @getUnspentOutputsFromAddresses _.values(addresses), (outputs, error) =>
          return callback?(null, error) if error?
          paths = _.invert(addresses)
          for output in outputs
            output.paths = []
            output.paths.push paths[address] for address in output.addresses when paths[address]?
          callback?(outputs)


ledger.api.UnspentOutputsRestClient.instance = new ledger.api.UnspentOutputsRestClient()