/*jslint node:true,indent:2*/
'use strict';

module.exports = function () {
  if (this.uselevel < 1) {
    this.next = Number.POSITIVE_INFINITY;
    return;
  }

  this.uselevel -= 1;
  this.next = this.levels.pop();
};

