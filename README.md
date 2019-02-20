# Virtual Tourist
## Description:
This iOS app enable users to choose a location on the map and  it will displays photos for that location from **Flicker**.
## Screenshots
![](https://i.ibb.co/429Fn3f/Screen-Shot-2019-02-21-at-12-11-57-AM.png)
![](https://i.ibb.co/wW41M6F/Screen-Shot-2019-02-21-at-12-13-33-AM.png)
![](https://i.ibb.co/jD3MC0r/Screen-Shot-2019-02-21-at-12-15-09-AM.png)
![](https://i.ibb.co/V20JWrc/Screen-Shot-2019-02-21-at-12-15-45-AM.png)
## User Experience

Once you lunch the app, you will be presented with a map. You can zoom the map in or out as well as move the map around. Whenever a spot of the map is longed pressed, a red bubble will appear on that spot representing a location. When you click that bubble, the app will navigates to another view. This view will display a 12 random photos that have been downloaded from Flicker for that particular location in a collection view. These photos will be stored on your device. If you tap a photo, it will be deleted from the device and disappear from the view. You can choose as many location as you like. When you navigate back to the map you and re-click the red bubble, the photos view will be shown displaying the photos that were stored on your device for that location. In this view, there is a button on the upper right called “new collection” taping on it will delete all photos from the device and remove them from the view then another 12 random photos will be downloaded and stored on your device and displayed in the view. There is no limit for number of times that you click the “new collection” button. However, that button will be disabled when the photos are downloading. It will be enable after all photos finish downloading. Moreover, when the photos start downloading, a placeholder and an activity indicator will be shown for each photo. If there are any issues, an alert message will be shown to the user. In addition, you will be notified if you choose a location on the map that doesn’t have photos on Flicker.

## Requirements

macOS 10.14 or later
xCode 10 or later
Swift 4 or later
iOS 12 or later

## Dependencies
This app uses [**Kingfisher**](https://github.com/onevcat/Kingfisher) library to download photos and displays them.

## Possible issues
* The app may crash when the number of photos returned by Flicker API is lower than 12
* You may encounter an issue that says "_No such module Kingfisher_" to solve this problem please do the following steps:
	1. Open the terminal and navigate to the project directory using cd /path/to/project/folder
	2. Type this command and press enter ``` pod install ```
