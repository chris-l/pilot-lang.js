/*jslint node:true,indent:2*/
'use strict';

module.exports = function (instruction) {
  var matchesList, self = this;

  matchesList = instruction.matches.reduce(function (list, item, index) {
    if (self.accept.toLowerCase().indexOf(item) > -1) {
      list.push(index);
    }
    return list;
  }, []);

  self.matches = matchesList.length > 0 ? 1 : 0;
};

