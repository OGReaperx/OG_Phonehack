Config = {}

Config.Phone = 'lb' -- 'lb' for 'lb-phone' | 'yphone' for ' yseries phone'

Config.RequiredPhoneItem = {  -- item rewquired to unlock the phone add more
    'phone',
}

Config.PhoneMetadataKey = 'phoneNumber' -- 'phoneNumber' lb-phone | 'imei' yseries | metadata key to store the phone number

Config.Computers = {
    {coords = vec3(68.85, -387.95, 53.2), radius = 0.4}, -- Example coordinates where the computer is placed
}