Blash = {}
Blash.Config = BlashConfig
Blash.Shared = BlashShared
Blash.ClientCallbacks = {}
Blash.ServerCallbacks = {}

exports('GetObject', function() return Blash end)
Blash.Functions.ConductVersionCheck('blashframework', 'blash-core')