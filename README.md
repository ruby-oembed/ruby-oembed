Changed From The Original
=========================
This is defenitly the "embedly" fork. I replaced everything I could from oohembed.com with embedly. oohembed.com has been running into rate issued with google app engine, so I am just trying to relive the pressure. 

All the supported embedly urls are built from the embeddly json file of simple regexps, which can be found at [http://api.embed.ly/static/data/embedly_regex.json](http://api.embed.ly/static/data/embedly_regex.json)

Adding a folder for testing all the possible urls. I am not sure what the best way to do this is, if some one who is more familiar with ruby can explain a better way of doing that I would be much appreciated.

I also included a url file, provided by embedlly as well, so that the library can check for urls that work or not. 

There should probably two types of url checks, one for wellformedness, that doesn't make an HTTP call, and then one to see if the actual url works. 





