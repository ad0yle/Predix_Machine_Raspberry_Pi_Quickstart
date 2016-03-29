# ng-bind-polymer
Directive for binding Angular apps to Polymer components.

# Usage
When using your Polymer component in an Angular view, add ng-bind-polymer directive to the component to enable 2-way binding between Angular and Polymer.

	<my-polymer-component ng-bind-polymer my-polymer-attribute="{{myNgScopeParam}}"></my-polymer-component>

See sample usage in the Predix Seed app for the deck selector.
	
	<px-deck-selector ng-bind-polymer decks="{{decks}}" selected-deck-url="{{selectedDeckUrl}}"></px-deck-selector>

# Adding to your Angular app

If you use the latest Predix Seed, this is already done for you with the px-deck-selector on the Dashboards view.

1. Install
	- Add github.com/PredixDev/ng-bind-polymer.git to your bower.json & bower install
2. Add to RequireJS config
	- Add 'ng-bind-polymer': '../bower_components/ng-bind-polymer/ng-bind-polymer' to your config.js
3. Add as a dependency to your Angular app
    - Add 'ng-bind-polymer' to the define block in app.js
    - Add 'px.ngBindPolymer' as a dependency of your main module in app.js
4. Add to your web components that you want 2-way binding between Polymer and Angular
	- Add ng-bind-polymer to your web components, like the examples above



