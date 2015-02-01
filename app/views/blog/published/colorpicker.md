---
title:  "Colorpicker"
created_at: "2015-01-30"
author: "Ben Radler"
---

![](https://cloud.githubusercontent.com/assets/199422/2813893/6260da36-ce9b-11e3-9e54-3c86cc1f4f47.jpg)

<!--more-->

## Video Demo
<iframe width="1280" height="720" src="//www.youtube.com/embed/92aIxuRP2jo" frameborder="0" allowfullscreen></iframe>

## Backstory
My roommate works for Apple, and travels to China for work. He brought back a spool of LED lights, and hacked together a script for an Arduino that played a series of 12 lights on repeat.

We then installed the lights in the ceiling in the upstairs of our apartment in San Francisco.  It looked like this:

![](https://farm6.staticflickr.com/5338/8797261023_30e23e2e53_b_d.jpg)

## Criteria for Success

We decided we wanted to create a simple UI that could be used to pick colors.  Our criteria for success were as follows:

* set all banks of light a single color
* set colors individually on each bank of lights
* save color choices and be able to bring them back up
* same UI usable on desktop, tablet, and smartphone

## The UI

For the UI, I decided to base the design off of the awesome [Color by hailpixel](http://color.hailpixel.com/). This brilliant colorpicker interface allows you to adjust color on 3 axes:

* X axis: **hue**
* Y axis: **lightness**
* Z axis (scrolling): **saturation**

Clicking allows the user to save a color into a "bank". The color can also be adjusted after the fact. Each saved color gets added to the URL as its respective hex code.

## Architecture

There are two Node.js applications, a client and a server.

###[`colorpicker-server`](https://github.com/Lordnibbler/colorpicker-server)
Contains the Backbone application, and runs on a simple Node.js web host like Nodejitsu or Heroku.

#### Frontend
The frontend of the app uses [Backbone.js](http://backbonejs.org/) for simple client-side MVC. It connects to the backend [Node.js](http://nodejs.org) server using [socket.io](http://socket.io). I'll cover the details of my changes to the Color by Hailpixel backbone application below:

The entry point for the Backbone application is [`main.js`](https://github.com/Lordnibbler/colorpicker-server/blob/master/public/scripts/main.js), and connects to the socket on the Node.js side of the application with a simple `io.connect('http://some-server.com/some-socket-name);`.  It is **critical** that your server string contain a socket name.  For instance, in our app, we chose to have two socket names, `backbone` and `beaglebone`. These socket names make it easy for our Node.js server (the backend of this application) to easily distinguish messages from the `backbone` app or the `beaglebone` client.

We also save the `socket` and `dapp` backbone app under the `window` namespace so we can reference them elsewhere in the application.

In our `views/app.js` backbone view, we define a `colorChanged()` function which emits a `'colorChanged'` event over the socket to the `colorpicker-client` application.   The value for the `'colorChanged'` event is an RGB string of the currently selected color.

```javascript
colorChanged: function(color) {
  window.socket.emit('colorChanged', {
    color: this.colorToRgbString(color)
  });
}
```

In the `router.js`, we add define a `colorSet()` function which emits a `'colorSet'` event over the socket to the `colorpicker-client` application.  The value for the `'colorSet'` is a string of RGB color codes for each `color` record in the `app.Colors` collection.

```javascript
colorSet: function() {
  if(window.socket) {
    window.socket.emit('colorSet', {
      color: this.colorsToRgbString()
    });
  }
}
```

The `colorsToRgbString()` functions are pretty straightforward, and simply grabs each color's RGB value, and creates a `'r,g,b,a\n'` formatted string:

```javascript
/**
 * Converts colors to Halo's `r,g,b,a\n` format
 */
colorsToRgbString: function() {
  var rgbColors = "";
  app.Colors.each(function(color){
    rgbColors += color.rgb().r + ',' + color.rgb().g + ',' + color.rgb().b + ',' + color.rgb().a + '\n';
  });
  return rgbColors;
}
```


#### Backend

We start up a socket.io socket, and an anonymous function is passed as the startup callback.

Inside this function, we bind to the `connection` event of two sockets, `/backbone` `/beaglebone`.  `/backbone` represents the front end of this application, the backbone app. `/beaglebone` represents a client Node.js application running on our beaglebone computer.

An anonymous callback function is pased to the `connection` event of the `/backbone` socket. This function pushes the connected socket into the `backbones` array so we can keep track of it in the future.

We also listen for `colorChanged` and `colorSet` events from the connected backbone applications. If either of these events are fired, we pass the color data along to each of the connected `beagle` socket.io clients.

```coffeescript
# when backbone.js Client runs `io.connect('http://localhost:1337/backbone')`
sio.of('/backbone').on('connection', (socket) ->
  logger.info "/backbone CLIENT CONNECTED"
  backbones.push socket

  ######################################
  # colorChanged and colorSet both
  # writeColorDataToFile in our
  # beaglebone client node app.
  # backbone.js takes care of sending
  # all 4x 1 color, or 1x 4 colors
  ######################################

  # when Client is live-previewing color
  socket.on 'colorChanged', (data) ->
    # send colorChanged data to all beagles
    # logger.info "emitting colorChanged to #{beagles.length} beagles"
    beagle.emit('colorChanged', { color: data.color }) for beagle in beagles # where beagle is connected

  # when Client picks a new color
  socket.on 'colorSet', (data) ->
    # send colorSet data to all beagles
    beagle.emit('colorSet', { color: data.color }) for beagle in beagles
)
```

An anonymous callback function is pased to the `connection` event of the `/beaglebone` socket as well. This function pushes the connected socket into the `beagles` array so we can keep track of it in the future.

We also listen for the `disconnect` event from the connected beaglebone applications. If this event is fired, we remove the appropriate `beagle` socket from the `beagles` array.

```coffeescript
# when beaglebone Client runs `io.connect('http://localhost:1337/beaglebone')`
# push them into the beagles array
sio.of('/beaglebone').on('connection', (socket) ->
  logger.info "/beaglebone CLIENT CONNECTED"
  beagles.push socket

  # remove beaglebone client from beagles array
  # if disconnection event occurs
  socket.on('disconnect', (socket) ->
    logger.info "/beaglebone CLIENT DISCONNECTED"
    beagles.pop socket
  )
)
```


###[`colorpicker-client`](https://github.com/Lordnibbler/colorpicker-beaglebone)
A small Node.js client which receives socket.io `colorChanged` events, and writes the results to disk.

This application serves one specific purpose: receive `colorChanged` or `colorSet` events sent from our Node.js server, and write them to disk. Our PERL script on the beaglebone will read this file and send it to the Arduino which will ultimately be sent to the lights via UART.

The only trickery here is the `w+` mode of our `writeStream`. From the Node.js documentation of `createWriteStream()`, the `w+` mode will:

>Open file for reading and writing. The file is created (if it does not exist) or truncated (if it exists)

Here is the important code for this client application:

```coffeescript
socket.on "connect", ->
  console.log "socket connected"

# write our preformatted backbone.js
# color data to colors.txt
socket.on "colorChanged", @_write_colors_data_to_file
socket.on "colorSet",     @_write_colors_data_to_file

_write_colors_data_to_file: (data) ->
logger.debug JSON.stringify(data, null, 2)

ws = FS.createWriteStream("#{__dirname}/../colors.txt", {
  flags: "w+"
})
ws.write(data.color, (err, written) ->
  if err
    throw err
  ws.end()
)
```

### [`halo.pl`](https://github.com/Lordnibbler/halo)
**WARNING**: this PERL script is more unpolished than the Node.js applications, and has residual "dead code" from previous prototypes of the lighting system.  *Use at your own risk*

The entry point for the `Halo_Master.pl` PERL script is the `while` loop on line `388`.  This ultimately calls the `grabLiveData()` subroutine.

`grabLiveData()` is in charge of reading the `PREVIEW_DATA` RGB color data in the `colors.txt` file generated by the `colorpicker-client` application. It builds a `$rgb` array based on the `PREVIEW_DATA`, which is ultimately sent to the Arduino via the `sendColor()` subroutine:

```perl
sub sendColor {
  my($address,$r,$g,$b,$v)= @_;
  $address = $address + 1;
  print SERIAL "4,$address,$r,$g,$b,$v;";
}
```

### [Arduino Translation Code](https://github.com/Lordnibbler/halo_arduino_translation_code)

The Arduino Uno board acts as a UART to I2C interface.
The two arduino libraries used here are Wire and CmdMessenger.

[CmdMessenger](http://playground.arduino.cc/Code/CmdMessenger) acts as the UART interpreter. We set up 4 different commands, but for our application, we only use the `change_color` command.

```c
messengerCallbackFunction messengerCallbacks[] =
{
  change_color,            // 004 in this example
  read_light_color,
  check_status,
  change_all,
  NULL
};
```

`change_color()` then parses the remaining parameters which are read as `uint8`: Channel, Red, Green, Blue, Violet.

These are then sent out over the I2C bus using the [Wire](http://arduino.cc/en/reference/wire)

```c
uint8_t setColor(uint8_t address,uint8_t red,uint8_t green, uint8_t blue,uint8_t violet){
  char status;

  messageBuf[0] = 0xaf; //Command byte. 0xAF is change color
  messageBuf[1] = red ;
  messageBuf[2] = green ;
  messageBuf[3] = blue ;
  messageBuf[4] = violet;
  messageBuf[5] = checksum((unsigned char*)messageBuf,5); //Checksum for checking reliable transmission


  Wire.beginTransmission(address); // transmit to device #4
  Wire.write((uint8_t*)messageBuf,6);
  status = Wire.endTransmission();    // stop transmitting
  if(status != 0){
    return 0;
  }

  return 1;
}
```


### [Light Strip Code](https://github.com/Lordnibbler/halo_slave_strips)

Each light controller consists of an `ATTiny2113`. I chose this particular uController since it features an I2C capable serial interface, and 3 8-bit PWM blocks. Each PWM output is connected to an N-MOS transistor which pulls each LED String to ground. This way, we're able to control the brightness of each LED color(Red, Green, Blue) by just changing the PWM Duty Cycle.

In the current implementation, the I2C address is set by DIP switches on the controller board.

The code on each light controller initializes the PWM timers and the I2C driver, then goes into a loop awaiting I2C commands.

Only 2 commands are interpreted right now...I chose these command numbers just for ease of reading them on the oscilloscope :-):

```c
0XAF - Change Color
Changes the PWM value of each LED Color

0xAE - Color Status
Responds with current Red,Green,Blue values
```
