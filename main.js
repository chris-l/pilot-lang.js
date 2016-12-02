/*jslint node:true,indent:2*/
'use strict';

module.exports = function (input, output) {
  var obj = {
    instructions  : {},
    matched       : 0,
    match         : '',
    left          : '',
    right         : '',
    next          : 0,
    uselevel      : 0,
    levels        : [],
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
