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
      $scope.$on('save', (event) ->
        targetItem = event.targetScope.item
        targetIndex = $scope.items.indexOf targetItem
        if targetItem.$save?
          targetItem.$save()
        else if targetItem.text?
          $scope.items[targetIndex] = todoRes.save(targetItem)
        else
          $scope.items.splice targetIndex, 1
      )
      $scope.$on('remove', (event) ->
        targetItem = event.targetScope.item
        targetIndex = $scope.items.indexOf targetItem
        $scope.items.splice targetIndex, 1
        targetItem.$remove?()
      )
      $scope.create = ->
        $scope.items.push {}
  ])
  .controller('ItemCtrl', [
    '$scope'
    ($scope) ->
      $scope.editable = not $scope.item.text?
      $scope.edit = ->
        $scope.editable = true
      $scope.save = ->
        $scope.$emit('save')
        $scope.editable = false
      $scope.remove = ->
        $scope.$emit('remove')
  ])