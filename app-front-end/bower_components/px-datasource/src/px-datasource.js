define(['angular', 'restangular'], function(angular) {

    'use strict';

    var module = angular.module('predix.datasource', ['restangular']);

    module.factory('PxDatasource', ['Restangular', function(Restangular) {
        return Restangular;
    }]);

    return module;
});
