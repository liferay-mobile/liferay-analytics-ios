# Analytics Client iOS‌‌‌‌ [![Codacy Badge](https://api.codacy.com/project/badge/Grade/78be964af8754b93a420fc1f3e43b592)](https://app.codacy.com/app/62756139/liferay-analytics-ios?utm_source=github.com&utm_medium=referral&utm_content=liferay-mobile/liferay-analytics-ios&utm_campaign=badger) [![Codacy Badge](https://api.codacy.com/project/badge/Coverage/79104a5e04ba4ee397d04c7aaa3dd188)](https://www.codacy.com/app/liferay-mobile/liferay-analytics-ios?utm_source=github.com&utm_medium=referral&utm_content=liferay-mobile/liferay-analytics-ios&utm_campaign=Badge_Coverage)  [![Build Status](https://travis-ci.org/liferay-mobile/liferay-analytics-ios.svg?branch=master)](https://travis-ci.org/liferay-mobile/liferay-analytics-ios) 
## Core iOS Client ![Core Version](https://img.shields.io/cocoapods/v/liferay-analytics-ios.svg?style=flat)
### Setup
#### CocoaPods
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
You should initialize the lib passing your analytics key, it is recomended to add the command on applicationDidFinishLaunching method in your AppDelegate. If you don't initialized the library, you can get an error .analyticsNotInitialized or .analyticsAlreadyInitialized if the library is already initialized. By default the flushInterval of backpressure of events to send to cloud is 60 seconds.

Parameters:
- analyticsKey: String (required)
- flushInterval: Int (optional)
```swift
try Analytics.configure(analyticsKey: "YOUR_ANALYTICS_KEY", flushInterval: 50)
```
#### How to set your identity ?
It is recomended to call when the user is logged in, necessary to bind the next events for this user. The name parameter is optional. 

Parameters:
- email: String (required)
- name: String (optional)
```swift
Analytics.setIdentity(email: "user email", name: "user name")
```
#### How to clear the identity ?
It is recomended to call when the user is logged out, necessary to unbind the next events of the previous user.
```swift
Analytics.clearSession()
```
#### How to send custom events ?
Method to send any custom event.

Parameters:
- eventId: String (required) 
- applicationId: String (required)
- properties: [String: String] (optional). For additional properties
```swift
Analytics.send(
            eventId: "PageView",
            applicationId: "MYSAMPLE",
            properties: ["custom1": "value 1",
                        "custom2": "value 2"]) 
```
## Forms plugin ![Core Version](https://img.shields.io/cocoapods/v/liferay-analytics-forms-ios.svg?style=flat)
### Setup
#### CocoaPods
1. You need CocoaPods installed.
2. Create a file called `Podfile` in your project and add the following line:

    ```ruby
    pod 'liferay-analytics-forms-ios'  
    ```

3. Run `$ pod install`.
4. This will download the latest version of the SDK and create a .xcworkspace
file, use that file to open your project in Xcode.
### How to use ?
#### Forms Attributes
It is a struct to contextualize forms events.

Parameters:
- formId: String (required)
- formTitle: String (optional)
```swift
let formAttributes = FormAttributes(formId: "10", formTitle: "People")
```
#### Form Viewed
Method to send a form viewed event.

Parameters:
- attributes: FormAttributes (required)
```swift
Forms.formViewed(attributes: formAttributes)
```
#### Form Submit
Method to send a form submit event.

Parameters:
- attributes: FormAttributes (required)
```swift
Forms.formSubmitted(attributes: formAttributes)
```
#### Field Attributes
It is a struct to contextualize field events.

Parameters:
- name: String (required)
- title: String (optional)
- formAttributes: FormAttributes (required)
```swift
let fieldNameAttributes = FieldAttributes(name: "nameField", title: "Name", formAttributes: formAttributes)
```
#### Tracking Fields
Method to track all events from the Field, like (Focus and Blur).

Parameters:
- field: (UITextField || UITextView) (required)
- fieldAttributes: FieldAttributes (required)
```swift
Forms.trackField(field: nameField, fieldAttributes: fieldNameAttributes)
```