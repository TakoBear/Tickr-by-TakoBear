README for Tickr made by TakoBear
=================

Tickr is a libre and opensource App.
You can use it to download image with Google API URL, drawing, or crop image
and send it to your messenger application.
Current version only support iOS, and we are now working on the other platforms.
To know detail of our team and iOS tutorials, just visit our webSite:

**TakoBear** : [http://www.takobear.tw](http://www.takobear.tw)

#### UI-Source

The main entry point for this application is IndexViewController.m
If you are interested to know our app flow, just start from this class.

#### JMDropMenu

This class is used in the following screenshot:


To know more, just check this class.

Follow the sample code to init and append to your view 
``` objective-c
    dropMenu= [[JMDropMenuView alloc] initWithViews:@[cameraDrop, albumDrop, searchDrop]];
    dropMenu.frame = CGRectMake(self.view.bounds.size.width - kAddMenuIconSize, 70, kAddMenuIconSize, kAddMenuIconSize *3);
    dropMenu.animateInterval = 0.15;
    dropMenu.delegate = self;
    dropMenu.userInteractionEnabled = NO;
    [self.view addSubview:dropMenu];
```

Note that property animateInterval can control the animate time.
We set the default time as 0.5 sec.
To dismiss the menu, use the following method after init..

``` objective-c
[dropMenu dismiss];
```

To pop out the menu, just use the method 

``` objective-c
[dropMenu popOut];
```

#### JMSpringMenuView

This class is used in the following screenshot:

#### The other opensource used in this App

Thanks to these opensource contributuion, we made this app close to our expectation.

GmailLoadingView  		: Nikhil Gohil, 2012
MBProgressHUD   (v0.8)	: Matej Bukovinski
WYPopoverController    : Nicolas CHENG, 2013
REMenu					: Roman Efimov [https://github.com/romaonthego](https://github.com/romaonthego) , 2013

RATreeView				: Rafał Augustyniak, 2013
SDWebImage				: [https://github.com/rs/SDWebImage](https://github.com/rs/SDWebImage)
ASIHttp				    : [http://allseeing-i.com/ASIHTTPRequest/](http://allseeing-i.com/ASIHTTPRequest/)

#### Thanks

Thanks everyone for giving us advice and help us to finish this app.
