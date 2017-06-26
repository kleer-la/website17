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
    {image: 'app/img/slide01.jpg', title:'Coaching', text: 'Acompañamos mejoras integrales', id: 0 },
    {image: 'app/img/slide02.jpg', title:'Facilitación', text: 'Diseñamos ambientes para potenciar la innovación colectiva', id: 1 },
    {image: 'app/img/slide03.jpg', title:'Cursos', text: 'Capacitamos a profesionales y equipos', id: 2 }
  ];

  $scope.test= function(t){$scope.$parent.parentTest(t)};

  });
