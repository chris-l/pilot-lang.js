/*jslint node:true,indent:2*/
'use strict';

module.exports = function (instruction) {
  this.next = this.labels[instruction.label] - 1;
};

