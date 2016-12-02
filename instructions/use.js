/*jslint node:true,indent:2*/
'use strict';

module.exports = function (instruction) {
  this.uselevel += 1;
  this.levels.push(this.next);
  this.next = this.labels[instruction.label] - 1;
};
