/*jslint node:true,indent:2*/
'use strict';

module.exports = function (instruction) {
  if (this.matched === 0 || this.matched > instruction.labels.length) {
    return;
  }

  this.next = this.labels[instruction.labels[this.matched - 1]] - 1;
};

