Config = {}

Config.Phone = 'lb' -- 'lb' for 'lb-phone' | 'yphone' for ' yseries phone'

Config.RequiredPhoneItem = {  -- item required to unlock the phone add more
    'phone',
}

Config.Webhook = '' -- webhook to send logs to
Config.WebhookColor = "#00ff99" -- webhook color (hex format) - default is #00ff99
Config.WebhookColor_Corrupt = "#ff0000" -- webhook color (hex format) - default is #ff0000
Config.WebhookImage = "https://cdn-icons-png.flaticon.com/128/597/597177.png" -- webhook image using flaticon.com

Config.PhoneMetadataKey = 'phoneNumber' -- 'phoneNumber' for 'lb-phone' | 'imei' for 'yseries' | metadata key to store the phone number

Config.PoliceJobs = { -- police jobs to check for unlocking phone
    'police',
    'sheriff',
    'statepolice',
    'fbi',
}

Config.Computers = {
    {
        coords = vec3(440.99, -980.16, 31.0), -- coords of the computer
        radius = 0.3 -- This will trigger spherezone
    },
    -- {
        -- coords = vec3(200.0, -300.0, 54.0),
        -- size = vec3(2.0, 2.0, 2.0) -- will trigger box zone
    --}
}