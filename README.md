# Analytics Client iOS

## Core iOS Client
### Setup
##### CocoaPods

1. You need CocoaPods installed.

2. Create a file called `Podfile` in your project and add the following line:

    ```ruby
    pod 'liferay-analytics-ios'  
    ```

3. Run `$ pod install`.

4. This will download the latest version of the SDK and create a .xcworkspace
file, use that file to open your project in Xcode.
### How to use ?
#### Initialize the library

You should initialize the lib passing your analytics key, it is recomended to add the command on applicationDidFinishLaunching method in your AppDelegate. If you don't initialized the library, you can get an error .analyticsNotInitialized or .analyticsAlreadyInitialized if the library is already initialized. The flushInterval parameter is optional, by default the value of backpressure of events to send to cloud is 60 seconds.

    try Analytics.configure(analyticsKey: "YOUR_ANALYTICS_KEY", flushInterval: 50)
#### How to set your identity ?
It is recomended to call when the user is logged in, necessary to bind the next events for this user. The name parameter is optional. 

    Analytics.setIdentity(email: "user email", name: "user name")
#### How to clear the identity ?
It is recomended to call when the user is logged out, necessary to unbind the next events of the previous user.

    Analytics.clearSession()
#### How to send custom events ?
You only need to call this method, passing the parameters:
- eventId: string value
- applicationId: string value
- properties: optional dictionary value to send aditional properties


```swift
Analytics.send(
            eventId: "PageView",
            applicationId: "MYSAMPLE",
            properties: ["custom1": "value 1",
                        "custom2": "value 2"]) 
```


    

