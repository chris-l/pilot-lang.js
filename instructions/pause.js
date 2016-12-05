/*jslint node:true,indent:2*/
'use strict';

module.exports = function (instruction) {
  var self = this;

  self.waiting = true;
  setTimeout(function () {
    self.waiting = false;
  }, instruction.duration * 1000);
};
