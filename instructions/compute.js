/*jslint node:true,indent:2*/
'use strict';
var prepareText = require('../lib/prepareText'),
  doMath = require('../lib/math');

module.exports = function (instruction) {
  var self = this, id, value;

  id = instruction.assignment.identifier;
  value = instruction.assignment.value;

  if (id.element === 'string_ident') {
    value = prepareText(self, value);
    self.identifiers.strings[id.value] = value;
  }

  if (id.element === 'numeric_ident') {
    self.identifiers.numeric[id.value] = doMath(self)(value);
  }
};

