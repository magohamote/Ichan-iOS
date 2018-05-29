#Ichan - One step closer to one Goodpatch

Do you remember, two months ago, [this beautiful article](https://goodpatch.esa.io/posts/23621) about an app called Augpatch? You don't? Well go have a look then!

In Augpatch, I used my newly acquired AR skills to build an app showing two 3D characters talking together. The content of the chat bubbles is coming from Slack, which gives you the power of making those 3D characters say whatever you want. But that's it. It's a nice POC, but nothing really useful, neither really "fun".

With @sam, we decided to go further with this POC and to have a look at it. 

![](/Users/cedric/Desktop/2018-05-24 11.14.33.jpg)

We have a "problem": *How can we bridge the distance between our offices in a fun way and bring people together in a room to build our culture?*

This is not really a big problem, but it would be something really nice to solve and we thought that the *fun way* was a very important part of it. So, after brainstorming for a while and writing down our ideas we decided to go for the classic MVP and MLP solution! Here is what we came with:

![](/Users/cedric/Desktop/2018-05-24 10.58.12.jpg)

We already have a MVP (called Augpatch), and I'm currently working on a MLP, called Ichan!

In the MVP we have:

- A start screen
- 2 preset avatars (found on [Mixamo](https://www.mixamo.com/))
- Stock animations (found on [Mixamo](https://www.mixamo.com/))
- Multiple avatars on screen
- A Slack bot server
- Image recognition

This is cool, but this is barely a MVP and definitely not a MLP. Here is what we would need in order to have a MLP:

- Custom made avatars
- Avatars selector
- Turning on/off chat bubbles
- Fix avatars location over time
- Shared AR content with same geolocation
- Maximum distance until avatars are shown
- Chose where and how you put avatars in your environment
- Real life-sized avatars
- Speech bubbles connected to personal Slack channel

The most important point for me is the shared AR experience. This is what is really lacking in current smartphone AR apps, it's sharable content, community, live shared AR stuff. It first looked like a very big (but not impossible) challenge to achieve that by my own, but my dear friend Google just decided to give me a hand. Google just announced Cloud Anchor at its Google I/O, that is, live shared AR session! You will read about it very soon! ;)