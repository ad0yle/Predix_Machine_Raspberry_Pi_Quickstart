# Px-card, Px-dashboard, Px-deck

This repository hold the px-card, px-dashboard, and px-deck components.

## Overview

Context is an object.  It can contain details about an asset, urls to fetch additional information from, user-specific information, etc.  A developer can define anything they want in the context.

Cards are web components with a standard API that are initialized with a context.  They are reusable and can be placed anywhere because they are passed in everything they need to render from the context.

* use <px-card> template for styling
* inherit px.card behaviors
* fetch data in an abstract way that is not tied to the type of application that the card is running n (the default implemenation is an Angular $http fetch)
* facilitate component-to-component communication within a card using data-binding
* facilitate card-to-card communication within a deck using card API methods

Deck is a collection of cards.

* initialize Cards after the deck is initialized
* enable card-to-card communication through the deck state object

Dashboard is a deck renderer, which renders a deck with the given url.  That url can either be to a file with a ```<px-deck>``` and cards or to a deck in the [Views service](https://www.predix.io/catalog/service.html?id=1186).  

In the [Dashboard Seed](https://github.com/PredixDev/predix-seed), there is an example of using the [Views service](https://www.predix.io/catalog/service.html?id=1186), px-dashboard, [px-context-browser](https://github.com/PredixDev/px-context-browser), and [px-deck-selector](https://github.com/PredixDev/px-deck-selector) to build a dynamically-rendering dashboard application.

## Usage

### Prerequisites
1. node.js
2. npm
3. bower
4. Install the [webcomponents-lite.js polyfill](https://github.com/webcomponents/webcomponentsjs) to add support for web components and custom elements to your application.

### Getting Started

First, install the px-card repo via bower on the command line.

```
bower install https://github.com/PredixDev/px-card.git --save
```
Second, import the component(s) you want to use in your application with the following tag(s) in your head.

```
<link rel="import" href="/bower_components/px-card/px-dashboard.html"/>
<link rel="import" href="/bower_components/px-card/px-deck.html"/>
<link rel="import" href="/bower_components/px-card/px-card.html"/>
```

Finally, use the component(s) in your application. See specific examples below.

<br />
<hr />

### px-card
Element providing basic styling and behaviors (API) for card

#### Usage
```
<dom-module id="demo-card">
    <template>
        <px-card icon='demo-icon' header-text='Demo Card' chevron>
            <h1>Hello World</h1>
            <p>{{context.name}}</p>
            <p>This is the bare minimum you need for a Predix Experience card.</p>
        </px-card>
    </template>
</dom-module>
<script>
    Polymer({
        is: 'demo-card',
        init: function(){
            // this is where you can do some initialization of your card
        },
        contextChanged: function(newContext, oldContext){
            // this is where you will receive updates to the context
        },
        deckStateChanged: function(newDeckState, oldDeckState){
            // this is where you will receive updates from other cards
        },
        behaviors: [px.card]
    });

</script>
```

##### properties

_context object being passed into the card from deck/dashboard_
```
context: {
    type: Object
}
```
_deck state object being passed from the deck, deck state object is a shared object between all cards within a deck_
```
deckState: {
    type: Object
}
```

##### methods

```
init: function () {
//instantiate your card here, you can safely use this.context or fetch data with this.getData method here
}

```

```
contextChanged: function(newContext, oldContext){
//this is where you will receive updates to the context
}

```

```
deckStateChanged: function(newDeckState, oldDeckState){
//this is where you will receive updates from other cards
}

```

```
updateDeck: function (object) {
//broadcast an object to other cards within the deck
},

// Example:
this.updateDeck({
    count: this.count
});
```

```
showCard: function () {
//show this card
},

// Example:
document.querySelector('demo-card').showCard();
```

```
hideCard: function () {
//hide this card
},

// Example:
document.querySelector('demo-card').hideCard();
```

```
getData: function (url, httpConfig) {
//getData from web resources with url, config is optional
}

// Example:
this.getData('http://weather.com/sanramon').then(function(data) {
    // on fulfillment
    self.currentTemperature = data.value;
}, function(reason) {
    // on rejection
    console.error('ERROR', reason);
});

//getData with httpConfig
this.getData('http://weather.com/sanramon', {headers: {'my-header-name': 'my-header-value'}}).then(function(data) {
    // on fulfillment
    self.currentTemperature = data.value;
}, function(reason) {
    // on rejection
    console.error('ERROR', reason);
});

px card's getData method is a handly method for http GET call. If you need more than http GET, you can call a lower level method px.dealer.httpRequest in px.dealer.
px.dealer.httpRequest method is a low level method that takes a httpConfig object and returns a promise
For details about the httpConfigObject, please reference Angular $http method config
//Example
px.dealer.httpRequest({
    url: 'http://weather.com/sanramon,
    method: 'JSONP',
    headers: {'my-header-name': 'my-header-value'},
}).then(function(data){
    // on fulfillment
    self.currentTemperature = data.value;
});;

```

```
getAttributes : function(){
    // get all properties values of a card and return a property key : value map
}
```

```
save: function() {
   //retrive card properties values and persist the attributes in card service if url attribute is set on card
}

```

##### initialization

If you are not using px-deck, you will need to initialize your card yourself.  Example:
```
document.querySelector('demo-card').addEventListener('px-card-ready', function(e){
    //when card is ready set context
    var demoCard = e.target;
    demoCard.context = {
        name: 'Turbine 123'
    };
    demoCard.init();
});

```

### px-deck
A collection of cards which has an API

#### Usage
```
<px-deck context="{{context}}">
    <vibration-card id="card2"></vibration-card>
    <temperature-card id="card3"></temperature-card>
</px-deck>

```

##### properties

context object which will then be passed into the deck's cards
```
context: {
    type: Object
}
```

##### methods

```
addCard: function(cardName, cardId) {
//add card to the deck by passing card name (the element name) and card id
}

// Example:
document.querySelector('#my-deck').addCard('sample-card', new Date().getTime());
```

```
removeCardById: function(cardId){
//remove card from the deck by card id

// Example:
document.querySelector('#my-deck').removeCardById('sample-card-1');
}
```

### px-dashboard
Deck renderer with an API

#### Usage
```
//if using with predix view service
<px-dashboard view-service-base-url="{{viewServiceBaseUrl}}" selected-deck-id="{{selectedDeck.id}}" context="{{context}}"></px-dashboard>

//if you would like to render your deck from html file. you can put the url of the deck html in selected-deck-url attribute
<px-dashboard selected-deck-url="{{selectedDeck}}" context="{{context}}"></px-dashboard>
```

##### properties

context object being passed into the deck & cards from dashboard
```
context: {
    type: Object
}
```

deck id to pass to dashboard which will be used to load the deck that should be displayed
currently, this is just a url
```
selectedDeckUrl: {
    type: String
}
```

if using with view service, you can put view service base url here
```
viewServiceBaseUrl: {
    type: String
}
```

deck id in view service
```
selectedDeckId: {
    type: String,
    observer: "deckIdChanged"
}
```

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

Please use [Github Issues](https://github.com/PredixDev/px-card/issues) to submit any bugs you might find.
