Px-Data-Table
-----------------------------------------------

## Overview

Px-Data-Table is a Predix Experience ('Px') component that defines a data table, optionally using a sub-element for advanced column settings.

## Usage

### Prerequisites

1. node.js
2. npm
3. bower
4. [webcomponents-lite.js polyfill](https://github.com/webcomponents/webcomponentsjs)

Node, npm and bower are necessary to install the component and dependencies. webcomponents.js adds support for web components and custom elements to your application.

### Getting Started

First, install the component via bower on the command line.

```
bower install https://github.com/PredixDev/px-data-table.git --save
```

Second, import the component to your application with the following tag in your head.

```html
<link rel="import" href="bower_components/px-data-table/px-data-table.html"/>
```

Finally, use the component in your application:

```html
Minimum:

    <px-data-table table-data="{{data}}"></px-data-table>

Advanced:

    <px-data-table filterable selectable table-data="{{data}}"></px-data-table>

    <px-data-table selected-rows="{{mySelectedItems}}" filterable selectable striped table-data="{{data}}">
      <px-data-table-column
        name="first"
        sortable
        filter-function-name="filterWholeWord"
        sort-function-name="sortByEmailDomain">
      </px-data-table-column>
      <px-data-table-column name="last" ...></px-data-table-column>
      <px-data-table-column name="color" ...></px-data-table-column>
      <px-data-table-column name="date" ...></px-data-table-column>
    </px-data-table>
```

Integrating with other frameworks (ex: Angular):

You may not be able to use 2-way binding with the objects/arrays in other frameworks such as Angular.

We suggest instead to use events and selectors, for example:

```
document.getElementById("myDataTable").addEventListener("px-row-click", function(e) {
    ...
});

document.getElementById("myDataTable").addEventListener("px-select-all-click", function(e) {
    ...
});

$scope.doSomethingWithSelectedRows = function() {
    $scope.allSelectedRows = document.getElementById("myDataTable").selectedRows;
};
```

<br />
<hr />

## px-data-table

### Attributes

##### tableData

*Type:* **Array** - (*Required*)

Data for the table to display.

Expected data format is just a json array. Each object in the array represents a row in the table.

Each item in an object will be displayed as a separate column, unless px-data-table-columns are defined to limit which columns are displayed.

```html
<px-data-table table-data="{{data}}"></px-data-table>
```

```js
[
  {
   "index": 0,
   "name": "Liz Grimes",
   "image": "https://s3.amazonaws.com/uifaces/faces/twitter/enda/73.jpg",
   "date": "Sun Aug 14 1994 03:27:03 GMT-0700 (PDT)"
 },
 {
   "index": 1,
   "name": "Frazier Lara",
   "image": "https://s3.amazonaws.com/uifaces/faces/twitter/guillogo/73.jpg",
   "date": "Tue May 24 1988 14:10:20 GMT-0700 (PDT)",
 }
]
```

##### filterable

*Type:* **Boolean** - (*Optional*) - *Default:* false

Use the filterable attribute if the table has filtering functionality per column turned on.

If columns are specified with px-data-table-column, they must have a filterable attribute to be able to be filtered.

```html
<px-data-table filterable table-data="{{data}}"></px-data-table>
```

##### selectable

*Type:* **Boolean** - (*Optional*) - *Default:* false

Use the selectable attribute if the table rows should be able to be selected.

```html
<px-data-table selectable table-data="{{data}}"></px-data-table>
```

##### striped

*Type:* **Boolean** - (*Optional*) - *Default:* false

Use the striped attribute if the table rows are striped

```html
<px-data-table striped table-data="{{data}}"></px-data-table>
```

##### tableColumns

*Type:* **Boolean** - (*Optional*) - *Default:* false

Use the table-columns attribute if the table should be displayed as columns, instead of a grid.

```html
<px-data-table table-columns table-data="{{data}}"></px-data-table>
```

##### tableRows

*Type:* **Boolean** - (*Optional*) - *Default:* false

Use the table-rows attribute if the table should be displayed as rows, instead of a grid.

```html
<px-data-table table-rows table-data="{{data}}"></px-data-table>
```

##### selectedRows

*Type:* **Array** - (*Optional*)

Selected rows in the data table setup for binding.

This property is read only.

```html
<px-data-table selected-rows="{{mySelectedItems}}" table-data="{{data}}"></px-data-table>
```

##### customFunctions

*Type:* **Object** - (*Optional*) - *Default:* {}

Custom function declarations for any custom filtering/sorting functions.

These are just the declarations of the functions; to use the functions for a column you must pass in the filter-function-name / sort-function-name to px-data-table-column.

```html
<px-data-table customFunctions="{{myCustomFunctions}}" table-data="{{data}}"></px-data-table>
```

```js
myCustomFunctions = {
  sortByEmailDomain: function(a, b) {
    var aDomain = a.value.substring(a.value.indexOf("@")+1, a.value.indexOf("."));
    var bDomain = b.value.substring(b.value.indexOf("@")+1, b.value.indexOf("."));
    return this.descending
      ? (aDomain < bDomain ? 1 : -1)
       : (aDomain > bDomain ? 1 : -1);
  },
  filterWholeWord: function(searchString, cellValue) {
    if(searchString === undefined || searchString === null || searchString === "") {
      return true;
    }
    return (searchString.toString().toLowerCase() === cellValue.toString().toLowerCase());
  }
};
```

### Events

#### px-row-click

Fired when table row is clicked (selected or unselected)

```js
document.getElementById("mytable").addEventListener("px-row-click", function(e) {
  var clickedRow = e.detail.row;
  console.log("Row clicked", clickedRow, " _selected: ", clickedRow._selected);
});
```

#### px-select-all-click 

Fired when the select all button is clicked (selected or unselected)

```js
document.getElementById("mytable").addEventListener("px-select-all-click", function(e) {
  var allSelectedRows = e.detail;
  console.log("Select/unselect all", allSelectedRows);
});
```

### Functions

No functions are exposed by px-data-table.

<br />
<hr />

## px-data-table-column

Element that defines a columns in a data table.

```html
<px-data-table-column name="first"></px-data-table-column>
```

### Attributes

##### name

*Type:* **String** - (*Required*)

Required.

Name of the item in a row object to display.

```html
<px-data-table-column name="first" ...></px-data-table-column>
```

##### type

*Type:* **String** - (*Optional*) - *Default:* string

Required.

Type of the item in a row object to display.

Supported options: string, html

WARNING! Potential XSS vulnerability if html comes from an untrusted source.  This component does NOT do any sanitizing, it will execute whatever you pass it.

Unsupported: date, time, datetime, choice

```html
<px-data-table-column type="html" ...></px-data-table-column>
```

##### label

*Type:* **String** - (*Optional*) - *Default:* capitalized name

Label in table heading for column. Optional, will use capitalized name attribute by default.

```html
<px-data-table-column label="The First Name" ...></px-data-table-column>
```

##### filterable

*Type:* **Boolean** - (*Optional*) - *Default:* false

If column is filterable for filtering.

```html
<px-data-table-column filterable ...></px-data-table-column>
```

##### sortable

*Type:* **Boolean** - (*Optional*) - *Default:* false

If column is sortable.

```html
<px-data-table-column sortable ...></px-data-table-column>
```

##### maxColumnCharacterWidth

*Type:* **Number** - (*Optional*) - *Default:* no maximum, will make row as wide as necessary to display all content

Maximum number of characters in a column. Optional.

```html
<px-data-table-column max-column-character-width="10" ...></px-data-table-column>
```

##### ellipsisClipPosition

*Type:* **String** - (*Optional*) - *Default:* false

Where to clip the data and put ellipsis for the maximum characters in the column.

Options: center, left, right

```html
<px-data-table-column ellipsis-clip-position="center" ...></px-data-table-column>
```

##### filterFunctionName

*Type:* **String** - (*Optional*) - *Default:* filter on the typed in string

Name of the custom function to filter this row with.

A custom function with this name must be the px-data-table customFunctions attribute. If not, the column falls back to default filtering behavior.

```html
<px-data-table-column filter-function-name="filterWholeWord" ...></px-data-table-column>
```

##### sortFunctionName

*Type:* **String** - (*Optional*) - *Default:* sort in increasing/decreasing alphanumerical

Name of the custom function to sort this row with.

A custom function with this name must be the px-data-table customFunctions attribute. If not, the column falls back to default sorting behavior.

```html
<px-data-table-column sort-function-name="sortByEmailDomain" ...></px-data-table-column>
```

##### default

Unsupported

##### editable

Unsupported

##### hint

Unsupported

##### options

Unsupported

##### required

Unsupported

##### searchplaceholder

Unsupported

### Events

No events are fired by px-data-table-column.

### Functions

No functions are exposed by px-data-table-column.

<br />
<hr />

## Using Events

Events follow the [Polymer data-binding standards](https://www.polymer-project.org/1.0/docs/devguide/data-binding.html).

You can can attach listeners by using one of the methods below:

1. Polymer Event listener
2. "on-x" annotated event listener
3. addEventListener vanilla Javascript method
<br />
<hr />

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
