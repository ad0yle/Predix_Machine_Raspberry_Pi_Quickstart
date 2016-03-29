angular.module('px.ngBindPolymer', []).directive('ngBindPolymer', ['$parse', function($parse) {

    function slugify(key) {
        var noCapitals = key.replace(/([a-z])([A-Z])/g, '$1 $2');
        var allLowercase = noCapitals.toLowerCase();
        var out = allLowercase.replace(/\s/g, '-');
        return out;
    }

    return {
      restrict: 'A',
      scope : false,
      compile: function bindPolymerCompile(el, attr) {
        var attrMap = {};

        for (var prop in attr) {
          if (angular.isString(attr[prop])) {
            var _match = attr[prop].match(/\{\{\s*([\.\w]+)\s*\}\}/);
            if (_match) {
              attrMap[prop] = $parse(_match[1]);
            }
          }
        }
        return function bindPolymerLink(scope, element, attrs) {
          Object.keys(attrMap).forEach(function(key) {
            var slugKey = slugify(key);
            element.on(slugKey + '-changed', function(event) {
              scope.$evalAsync(function() {
                if (attrMap[key](scope) === event.originalEvent.detail.value) return;
                attrMap[key].assign(scope, event.originalEvent.detail.value);
              });
            });
          });
        };
      }
    };
}]);