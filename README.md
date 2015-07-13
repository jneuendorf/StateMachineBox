# StateMachineBox

A lightweight web page popup based on a finite-state machine.

Based on the
[state machine framework](https://github.com/jakesgordon/javascript-state-machine)
from
[Jake Gordon](https://github.com/jakesgordon).

## Usage

Just include the script file on your web page:

```html
<script type="text/javascript" src="path/StateMachineBox.js"></script>
```

There are 3 files:

* StateMachineBox.js + css/StateMachineBox.css
    * uncompressed file
    * debug flag is set to true -> extra warning messages and errors
* StateMachineBox.min.js + css/StateMachineBox.min.css
    * compressed file
    * no nice warnings...plain brutal JavaScript errors :)
* StateMachineBox.all.min.js + css/StateMachineBox.min.css
    * compressed file
    * includes all required libraries
    * also no nice warnings

Also there are multiple themes coming the StateMachineBox.
They can be accessed directly after having included the StateMachineBox(.min).css.
Here are the themes:

* default


## API

The API is close to the one of [FancyBox](http://www.fancyapps.com/fancybox/) (but StateMachineBox is not singleton-like).
The same goes for callbacks, but there are a few more.

See the [wiki](...)

## Browser Support

* MSIE 9+
* Google Chrome
* Mozilla FireFox
* Opera
* Safari

## Requirements

### For using SMB

* [jQuery](http://jquery.com/)
* [jQuery UI](http://jqueryui.com/) (draggable)
* [Javascript Finite State Machine](http://github.com/jakesgordon/javascript-state-machine)

### For developing SMB

* [CoffeeScript](http://coffeescript.org/) (for building)
    * [Node.js](https://nodejs.org/)
* [Jasmine](http://jasmine.github.io/) (for testing)
* [Sass](http://sass-lang.com/) (for building)
    * Ruby
* [UglifyJS](https://github.com/mishoo/UglifyJS2) (for building / JS minization)
    * [Node.js](https://nodejs.org/)
* [YUI Compressor](https://github.com/yui/yuicompressor) (for building / CSS minization)
    * Java
* [YUIDoc](http://) (for building documentation)
    * [Node.js](https://nodejs.org/)
