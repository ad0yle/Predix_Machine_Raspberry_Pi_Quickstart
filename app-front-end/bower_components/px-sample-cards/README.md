# Sample cards repository

This repository has many sample card examples which demonstrate how to make cards.

For details on what Cards and Decks are, see [px-card](https://github.com/PredixDev/px-card).

## Overview

This repository stores a bunch of card examples.

### Card structure
The first place to look at it is demo-card.html.  This card demonstrates and describes the basic stucture for creating cards.

### Simple cards
Next, take a look at some very simple cards, which are found in their respective card-name.html files.  These cards just have simple card titles and some basic static content in their templates.
* blank-card  -  just a card header
* gist-card  -  just a card header and a few sentences/links
* hide-card  -  just a card header (used with toggle-card, below)

### Cards with static content
Examples of cards that contain more web components inside of them:
* datagrid-card  -  shows static data in a px-data-table
* toggle-card  -  shows/hides the hide-card

### Cards with attributes
The description-card shows how cards can be passed attributes, just like any other web component.

### Cards with widgets layouts
The widgets-card shows the px-simple-line-chart and px-simple-bar-chart components in a px-twoup layout.  For more widget layouts see [px-widget-layouts](https://github.com/PredixDev/px-widget-cards).

### Communication within card (between widgets/components)
The widget-to-widget-card and temperature-card show how components/widgets within a card can communicate through basic Polymer 2-way data binding.  The temperature-card does logic and work within the card itself, while the widget-to-widget-card leaves the logic to the widgets and just enables the 2-way data binding at the card level.

### Communication within deck (between cards)
The deck facilitates communication between cards within it.  The sample-card2 demo shows two cards which increment their count individually and broadcast this change to the other cards in the deck via the updateDeck() api.  The card-to-card demo shows the same concept but buries the count deeper inside a shared object to show how cards could share a large object with many properties if necessary.

### Fetching data in card
Cards fetch their data using API methods like getData(), which allow them to be run in many different applications without knowledge of exactly how the data will be fetched.  Currently, the getData() method will only work in an Angular application, since it is only implemented for Angular $http.  The card will get a url from the context (something like this.context.url) and then fetch data from that url.  fetch-data-card and time-series-card show examples of how this can be done.

## Usage

### Prerequisites
1. node.js
2. npm
3. bower
4. Install the [webcomponents-lite.js polyfill](https://github.com/webcomponents/webcomponentsjs) to add support for web components and custom elements to your application.

### Getting Started

First, install the sample cards via bower on the command line.

```
bower install https://github.com/PredixDev/px-sample-cards.git --save
```
Second, import the cards/decks to your application with tags in your head like the following.  You will also need either:
* px-deck and px.min.js if you are using ```<px-deck>``` manually around your cards
* px-dashboard and ps-deck if you are using ```<px-dashboard>``` to render your decks

```
<!-- The px javascript library & px-deck are needed for using px-deck -->
<script type='application/javascript' src='bower_components/px/dist/px.min.js'></script>
<link rel="import" href="../px-card/px-deck.html"/>
<!-- or -->
<link rel="import" href="bower_components/px-card/px-dashboard.html"/>
<link rel="import" href="bower_components/px-card/px-deck.html"/>

<link rel="import" href="/bower_components/px-sample-cards/gist-card.html"/>
<link rel="import" href="/bower_components/px-sample-cards/datagrid-card.html"/>
<link rel="import" href="bower_components/px-sample-cards/sample-deck.html"/>
```

Finally, use the cards/decks in your application, either by:

Manually wrapping your cards in a px-deck and pass in the context
```
<px-deck context="{{context}}">
	<gist-card></gist-card>
	<datagrid-card></datagrid-card>
</px-deck>
```

Using px-dashboard and Views service to make a dynamic dashboard of your cards.  See [px-card documentation](https://github.com/PredixDev/px-card) for more information.

## Local Development

From the component's directory...

```
$ npm install
$ bower install
$ grunt sass
```

From the component's directory, to start a local server run:

```
$ grunt depserve
```

Navigate to the root of that server (e.g. http://localhost:8080/) in a browser to open the API documentation page, with link to the "Demo" / working examples.

### LiveReload

By default grunt watch is configured to enable LiveReload and will be watching for modifications in your root directory as well as `/css`.

Your browser will also need to have the LiveReload extension installed and enabled. For instructions on how to do this please refer to: [livereload.com/extensions/](http://livereload.com/extensions/).

Disable LiveReload by removing the `livereload` key from the configuration object or explicitly setting it to false.


### DevMode
Devmode runs `grunt depserve` and `grunt watch` concurrently so that when you make a change to your source files and save them, your preview will be updated in any browsers you have opened and turned on LiveReload.
From the component's directory run:

```
$ grunt devmode
```

### GE Coding Style Guide
[GE JS Developer's Guide](https://github.com/GeneralElectric/javascript)

<br />
<hr />

## Known Issues

Please use [Github Issues](https://github.com/PredixDev/COMPONENT/issues) to submit any bugs you might find.