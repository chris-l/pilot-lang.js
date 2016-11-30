/*jslint node:true,indent:2*/
'use strict';
var prepareText = require('../lib/prepareText');

module.exports = function (instruction) {
  var text, self = this;

  text = prepareText(self, instruction.text);
  self.output(text);
};
