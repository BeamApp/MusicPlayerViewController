MusicPlayerViewController
=========================

![SCreenshot](https://github.com/BeamApp/MusicPlayerViewController/raw/master/Documentation/images/screen.png)

MusicPlayerViewController aimes to be a drop-in component that serves as an UI for a Music Player on iPhone and is replicating the Music.app's user interface.

MusicPlayerViewController has the following features
* Music.app like UI
* Support for variable-speed scrobbling
* Support for resolution/device-dependent cover art
* Controllable using a data source and an optional delegate
* Three Repeat Modes and Shuffle mode

Installation
------------
To use MusicPlayerViewController in your Project, just 

1. Clone this repository or add it as submodule to your repository
1. Add all files from **Source/** to your project's target
2. Add the frameworks **MessageUI** and **MediaPlayer** to your target

Alternatively, you can use the fabulous [CocoaPods](http://cocoapods.org/):

1. add the dependency `pod 'BeamMusicPlayerViewController'` in your podfile
2. run `pod install`

and you are done.

Usage
-------
Using the component itself is simple. Because it is derived from a standard UIViewController, you can just instantiate it, set a delegate and datasource and are good to go.

    BeamMusicPlayerViewController* controller = [BeamMusicPlayerViewController new];
    controller.delegate = self;
    controller.dataSource = self;
    // Push the controller or something else

The Project contains an example that uses the MediaLibrary to provide data for the UI. You can use this as an starting point.

License
-------
The Project is licensed under the new BSD License (see file LICENSE).

© 2012 Beam App UG ( haftungsbeschränkt )