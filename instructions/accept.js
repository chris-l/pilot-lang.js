/*jslint node:true,indent:2*/
'use strict';

module.exports = function (instruction) {
  var self = this;

  self.waiting = true;
  self.input(function (answer) {
    if (instruction.identifier) {
      if (instruction.identifier.element === 'string_ident') {
        self.identifiers.strings[instruction.identifier.value] = answer;
      }
    }
    self.accept = answer;
    self.waiting = false;
  });
};
