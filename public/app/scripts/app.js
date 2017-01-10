'use strict';

/**
 * @ngdoc overview
 * @name kleerApp
 * @description
 * # kleerApp
 *
 * Main module of the application.
 */
angular
  .module('kleerApp', [
    'ngAnimate',
    'ngCookies',
    'ngResource',
    'ngRoute',
    'ngSanitize',
    'ngTouch',
    'ui.bootstrap'
  ])
  .config(function ($routeProvider, $locationProvider) {
    $routeProvider
      .when('/', {
        templateUrl: 'app/views/home.html',
        controller: 'HomeCtrl',
        controllerAs: 'home'
      });
      //.otherwise({
      //  redirectTo: '/'
      //});
    //$locationProvider.hashPrefix('');
  });
