/*jslint node:true,indent:2*/
'use strict';

module.exports = function (input, output) {
  var obj = {
    instructions  : {},
    input         : input,
    output        : output
  };
  require('./instructions')(obj);
  return obj;
};
