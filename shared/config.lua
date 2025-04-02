Config = {}

Config.Phone = 'lb' -- 'lb' for 'lb-phone' | 'yphone' for ' yseries phone'

Config.RequiredPhoneItem = {  -- item required to unlock the phone add more
    'phone',
}

Config.PhoneMetadataKey = 'phoneNumber' -- 'phoneNumber' for 'lb-phone' | 'imei' for 'yseries' | metadata key to store the phone number

Config.Computers = {
    {
        coords = vec3(68.85, -387.95, 53.2), 
        radius = 0.4
    }, -- This will trigger spherezone
    {
        -- coords = vec3(200.0, -300.0, 54.0),
        -- size = vec3(2.0, 2.0, 2.0) -- will trigger box zone
    }
}