/*
 * PILOT parser
 * ==========================
 */

Begin
  = statements:Statement*
  {
    return statements.reduce(function (a, b) {
      return a.concat(b);
    }, []);
  }

Statement
  = RemarkBlock
  / TypesBlock
  / A
  / M
  / JM
  / J
  / E
  / U
  / C
  / Label

Text
  = txt:(Escaped / InternalIdentifier / IdentifierText / Char)*
  {
    return txt.reduce(function (arr, x) {
      var prev = arr.length - 1;
      if (prev > -1 && typeof x === 'string' && typeof arr[prev] === 'string') {
        arr[prev] += x;
        return arr;
      }
      arr.push(x);
      return arr;
    }, []);
  }

Escaped
  = '\\' char:[^\n]
  {
    return char;
  }

InternalIdentifier
  = '%' id:('answer')
  {
    return {
      element : 'internal_ident',
      value : id
    };
  }

Char
  = [^\n]

_ "whitespace"
  = [ \t]*

nl "newlines"
  = [\n\r]*

Assignment
  = AssignmentString
  / AssignmentNumeric

AssignmentString
  = id:StringIdent _ '=' text:Text nl
  {
    return {
      element : 'assignment',
      identifier : id,
      value : text
    };
  }

AssignmentNumeric
  = id:NumericIdent _ '=' _ value:NumericExpression _ nl
  {
    return {
      element     : 'assignment',
      identifier  : id,
      value       : value
    };
  }

BinaryOperation
  = left:Numeric _ operator:[+-\/\*%] _ right:NumericExpression
  {
    return {
      element   : 'BinaryOperation',
      left      : left,
      operator  : operator,
      right     : right
    };
  }

NumericParens
  = '(' _ out:NumericExpression _ ')'
  { return out; }

NumericExpression
  = BinaryOperation
  / Numeric

Numeric
  = NumericParens
  / Number
  / NumericIdent
  / InternalIdentifier

Conditioner
  = [YyNn]
  {
    return text().toUpperCase();
  }

Expression
  = '(' content:[^)]* ')'
  {
    return content.join('');
  }

Number
  = [0-9]+
  {
    return parseInt(text(), 10);
  }

AthruZ
  = [a-zA-Z]

LimitedChar
  = [a-zA-Z0-9_]

LimitedString
  = str:(LimitedChar LimitedChar? LimitedChar? LimitedChar? LimitedChar? LimitedChar? LimitedChar? LimitedChar? LimitedChar?)
  {
    return str.join('');
  }

StringIdent2
  =  '$' str:(AthruZ LimitedString) { return str; }
  / str:(AthruZ LimitedString) '$' { return str; }

StringIdent
  =  str:StringIdent2
  {
    return {
      element : 'string_ident',
      value : (str[0] + str[1]).toLowerCase()
    };
  }

NumericIdentHash
  = '#' str:(AthruZ LimitedString)
  { return (str[0] + str[1]).toLowerCase(); }

NumericIdentPlain
  = str:(AthruZ LimitedString)
  { return (str[0] + str[1]).toLowerCase(); }

NumericIdentText
  = varName:NumericIdentHash
  {
    return {
      element : 'numeric_ident',
      value : varName
    };
  }

NumericIdent
  = varName:( NumericIdentHash / NumericIdentPlain)
  {
    return {
      element : 'numeric_ident',
      value : varName
    };
  }

Identifier
  = NumericIdent
  / StringIdent

IdentifierText
  = NumericIdentText
  / StringIdent

R
  = ('Remark'i / 'R'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ text:[^\n]* nl
  { return {
      instruction : 'Remark',
      conditioner : conditioner || false,
      expression : expression || false,
      content : text.join('')
    }
  }

REmpty
  =  _ conditioner:Conditioner? _ expression:Expression? _ ':' text:[^\n]* nl
  { return {
      instruction : 'Remark',
      continuation : true,
      content : text.join('')
    };
  }

RemarkBlock
  = block:(R REmpty*)
  {
    return (block[1] || []).reduce(function (a, b) {
      b.conditioner = block[0].conditioner;
      b.expression = block[0].expression;
      return a.concat(b);
    }, [ block[0] ]);
  }

Y
  = ('Yes'i / 'Y'i) _ expression:Expression? _ ':' text:Text nl
  {
    text.push("\n");
    return {
      instruction : 'Type',
      conditioner : 'Y',
      expression : expression || false,
      text : text
    }
  }

N
  = ('No'i / 'N'i) _ expression:Expression? _ ':' text:Text nl
  {
    text.push("\n");
    return {
      instruction : 'Type',
      conditioner : 'N',
      expression : expression || false,
      text : text
    }
  }

T
  = ('Type'i / 'T'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' text:Text nl
  {
    text.push("\n");
    return {
      instruction : 'Type',
      conditioner : conditioner || false,
      expression : expression || false,
      text : text
    }
  }

TH
  = ('TypeHang'i / 'TH'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' text:Text nl
  {
    return {
      instruction : 'TypeHang',
      conditioner : conditioner || false,
      expression : expression || false,
      text : text
    }
  }

TEmpty
  =  _ conditioner:Conditioner? _ expression:Expression? _ ':' text:Text nl
  {
    return {
      instruction : 'Type',
      continuation : true,
      text : text
    };
  }

TypesBlock
  = block:((T / Y / N / TH) TEmpty*)
  {
    return (block[1] || []).reduce(function (a, b) {
      b.instruction = block[0].instruction;
      b.conditioner = block[0].conditioner;
      b.expression = block[0].expression;
      if (b.instruction !== 'TypeHang') {
        b.text.push("\n");
      }
      return a.concat(b);
    }, [ block[0] ]);
  }

A
  = ('Accept'i / 'A'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ identifier:Identifier? nl
  {
    return {
      instruction : 'Accept',
      conditioner : conditioner || false,
      expression : expression || false,
      identifier : identifier || false
    };
  }
M
  = ('Match'i / 'M'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ matches:[^\n]* nl
  {
     matches = matches.join('').split(/,\s*/).map(function (match) {
       return match.toLowerCase();
     });
     return {
       instruction : 'Match',
       conditioner : conditioner || false,
       expression : expression || false,
       matches : matches
     };
   }
commas
  = _ ',' _

JM
  = 'JM'i _ conditioner:Conditioner? _ expression:Expression? _ ':' _ labels:(Labl commas?)* nl
  {
     labels = labels.map(function (label) {
        return label[0];
     });
     return {
       instruction : 'JumpOnMatch',
       conditioner : conditioner || false,
       expression : expression || false,
       labels : labels
     };
   }
J
  = ('Jump'i / 'J'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ label:Labl nl
  {
    return {
      instruction : 'Jump',
      conditioner : conditioner || false,
      expression : expression || false,
      label : label
    };
  }
E
  = ('End'i / 'E'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ nl
  {
    return {
      conditioner : conditioner || false,
      expression : expression || false,
      instruction : 'End'
    };
  }
U
  = ('Use'i / 'U'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ label:Labl _ nl
  {
    return {
      instruction : 'Use',
      conditioner : conditioner || false,
      expression : expression || false,
      label : label
    };
  }
C
  = ('Compute'i / 'C'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ assignment:Assignment _ nl
  {
    return {
      instruction : 'Compute',
      conditioner : conditioner || false,
      expression : expression || false,
      assignment : assignment
    };
  }

Labl = '*' text:[^\n, \t]+
  { return text.join('').toLowerCase(); }

Label
  = text:Labl nl
  { return {
      instruction : 'Label',
      label : text
    };
  }
