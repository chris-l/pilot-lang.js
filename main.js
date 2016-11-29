/*jslint node:true,indent:2*/
'use strict';

module.exports = function (input, output) {
  var obj = {
    instructions  : {},
    matches       : 0,
    next          : 0,
    matchesList   : [],
    identifiers   : {
      strings : {},
      numeric : {}
    },
    input         : input,
    output        : output
  };
  require('./instructions')(obj);
  return obj;
};
