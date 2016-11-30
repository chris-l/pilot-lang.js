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
      if (instruction.identifier.element === 'numeric_ident') {
        answer = parseInt(answer, 10);
        self.identifiers.numeric[instruction.identifier.value] = answer;
      }
    }
    if (!instruction.identifier && /^0-9$/.test(answer)) {
      answer = parseInt(answer, 10);
    }
    self.answer = answer;
    self.waiting = false;
  });
};
