/*
 * PILOT parser
 * ==========================
 */

Begin
  = Instruction*

Instruction
  = R
  / T
  / A
  / M
  / JM
  / J
  / E
  / Label

Char
  = [a-zA-Z0-9] { return text(); }

_ "whitespace"
  = [ \t]*

nl "newlines"
  = [\n\r]*




ConditionerExpression
  = Conditioner _ Expression

Conditioner
  = ('Y' / 'N')

Expression
  = '(' [^)]* ')'

R
  = 'R' _ ConditionerExpression? _ ':' _ text:[^\n]* nl
  { return {
      type : 'Remark',
      content : text.join('')
    }
  }

T
  = 'T' _ ConditionerExpression? _ ':' _ text:[^\n]* nl
  { return {
      type : 'Type',
      content : text.join('')
    }
  }

A
  = 'A' _ ConditionerExpression? _ ':' _ variable:[^\n]* nl
  {
    var output = {
      type : 'Accept',
      variable : false
    };
    if (variable.length > 0) {
      output.variable = variable.join('');
    }
    return output;
  }
M
  = 'M' _ ConditionerExpression? _ ':' _ matches:[^\n]* nl
  {
     matches = matches.join('').split(/,\s*/);
     return {
       type : 'Match',
       matches : matches
     };
   }
commas
  = _ ',' _

JM
  = 'JM' _ ConditionerExpression? _ ':' _ labels:(Lab commas?)* nl
  {
     labels = labels.map(function (label) {
        return label[0];
     });
     return {
       type : 'JumpOnMatch',
       labels : labels
     };
   }
J
  = 'J' _ ConditionerExpression? _ ':' _ label:Lab nl
  {
    return {
      type : 'Jump',
      label : label
    };
  }
E
  = 'E' _ ConditionerExpression? _ ':' _ nl
  {
    return {
      type : 'End'
    };
  }

Lab = '*' text:[^\n, \t]+
  { return text.join(''); }

Label
  = text:Lab nl
  { return {
      type : 'Label',
      label : text
    };
  }
