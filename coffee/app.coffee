angular.module('todo', ['ngResource'])
  .factory('todoRes', [
    '$resource',
    ($resource) ->
      $resource '//localhost:8000/:id', {id: "@id"}
  ])
  .controller('TodoCtrl', [
    'todoRes', '$scope'
    (todoRes ,  $scope) ->
      $scope.items = todoRes.query()

      $scope.save = (item) ->
        index = $scope.items.indexOf item

        if item.$save?
          item.$save()
        else if item.text?
          $scope.items[index] = todoRes.save(item)
        else
          $scope.items.splice index, 1

      $scope.remove = (item) ->
        index = $scope.items.indexOf item
        $scope.items.splice index, 1
        item.$remove?()

      $scope.create = ->
        $scope.items.push {}
  ])