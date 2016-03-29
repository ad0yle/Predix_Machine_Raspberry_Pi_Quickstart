px-datasource
=============

Restful communication brought to you by Predix.  Px-datasource is a simple wrapper (Angular module and factory) around [Restangular](https://github.com/mgonto/restangular).

### Usage
Add predix.datasource as a dependency to your Angular app.

    var predixApp = angular.module('myApp', [
        'predix.datasource'
        ...
    ]);

You now have full access to Restangular functionality; just replace "Restangular" in the [Restangular docs](https://github.com/mgonto/restangular) with PxDatasource.

