#Cloud Anchor & iOS

Google released [Cloud Anchor](https://www.youtube.com/watch?v=MeZcQguH124) during the last Google I/O in May 2018, and it's great. Cloud Anchor is a new AR technology that allows sharing a live AR session between multiple AR-enabled smartphones. This means that multiple users will interact with the same AR content and that they will see it at the same location, finally bringing the so wanted shared AR experience!

Cloud Anchor SDK is available for Android and iOS, and here is my experience with it on iOS.

###RTFM
Basically, everything you need can be found [here](https://developers.google.com/ar/develop/ios/cloud-anchors-quickstart-ios), but if you are like me, excited, and running through it too fast, you will end up with unnecessary debugging time. So, carefully follow the step by step procedure.

1. Clone [the project](https://github.com/google-ar/arcore-ios-sdk), this one I didn't miss.

2. You will have to create a Firebase Real-time database and modify its permission, get the ```GoogleService-Info.plist``` file (otherwise your Xcode project won't compile anyway) and add it to the previously downloaded sample project. What I missed here is that you need to modify the permissions of the Real-time database to **test mode**.

3. The API keys. Don't forget that. You can find it in the ```GoogleService-Info.plist``` file. Put it in the code instead of the ```@"Replace me with your API key."``` placeholder in ```ExampleViewController.m```

4. A point I missed as well: [Enable ARCore Cloud Anchor API](https://console.cloud.google.com/apis/library/arcorecloudanchor.googleapis.com/) for your project. It will just not work otherwise.

5. This one you won't miss because it cannot compile without it: run ```pod update``` to get ```ARCore 1.2``` (and then ```pod install```)

6. All good, launch the ```.xcworkspace``` file and test the app.


###First thought
It's great. Really. Here is how it works:

![](/Users/cedric/Downloads/IMG_C0061982D097-1.jpeg)

You can tap on HOST if you will be the session's host, or you can resolve a room number if you want to join an existing session.

Let's tap HOST: you will be asked to "tap on a plane to create anchor and host." Let's do it:

![](/Users/cedric/Downloads/IMG_2522.PNG)

As you can see on the image above, the app is "Hosting anchor...". If another user has resolved the room number and is in the same AR session, the "Resolving anchor..." message will be displayed. You will be granted with a "Finished hosting: Success" once the anchor has been hosted successfully. It will then appear on every other attendee's AR session.

Here are two different points of view with two different iPhone: one host and one attendee:

Host         				    |  Attendee
:-------------------------:|:-------------------------:
![](/Users/cedric/Downloads/IMG_2523.PNG)  |  ![](/Users/cedric/Downloads/IMG_0015.PNG)

More to come, stay tuned!