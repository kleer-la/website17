'use strict';

/**
 * @ngdoc function
 * @name kleerApp.controller:HomeCtrl
 * @description
 * # HomeCtrl
 * Controller of the kleerApp
 */
angular.module('kleerApp')
  .controller('HomeCtrl', function ($scope) {
    this.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];

  $scope.myInterval = 5000;
  $scope.noWrapSlides = false;
  $scope.active = 0;
  var slides = $scope.slides = [
    {image: 'img/slide01.jpg', title:'Coaching', text: 'Co-Creamos nuevas realidades', id: 0 },
    {image: 'img/slide02.jpg', title:'Facilitación', text: 'Co-Creamos nuevas realidades', id: 1 },
    {image: 'img/slide03.jpg', title:'Cursos', text: 'Co-Creamos nuevas realidades', id: 2 }
  ];

  $scope.test= function(t){$scope.$parent.parentTest(t)};

  });
