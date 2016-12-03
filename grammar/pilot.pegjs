/*
 * PILOT parser
 * ==========================
 */
{
  function reduceText(str) {
    return str.reduce(function (arr, x) {
      var prev = arr.length - 1;
      if (prev > -1 && typeof x === 'string' && typeof arr[prev] === 'string') {
        arr[prev] += x;
        return arr;
      }
      arr.push(x);
      return arr;
    }, []);
  }
}

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
  = txt:(Escaped / InternalIdentifier / IdentifierText / IntraLineComment / Char)*
  {
    return reduceText(txt);
  }

Escaped
  = '\\' char:[^\n]
  {
    return char;
  }

InternalIdentifier
  = '%' id:('answer' / 'left' / 'match' / 'right' / 'matched')
  {
    return {
      element : 'internal_ident',
      value : id
    };
  }

Char
  = [^\n]

IntraLineComment
  = _ '//' Char*
  { return ''; }

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
  = str:(LimitedChar? LimitedChar? LimitedChar? LimitedChar? LimitedChar? LimitedChar? LimitedChar? LimitedChar? LimitedChar?)
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
  = ('Yes'i / 'Y'i) _ expression:Expression? _ ':' text:Text IntraLineComment? nl
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
  = ('No'i / 'N'i) _ expression:Expression? _ ':' text:Text IntraLineComment? nl
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
  = ('Type'i / 'T'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' text:Text IntraLineComment? nl
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
  = ('TypeHang'i / 'TH'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' text:Text IntraLineComment? nl
  {
    return {
      instruction : 'TypeHang',
      conditioner : conditioner || false,
      expression : expression || false,
      text : text
    }
  }

TEmpty
  =   _ ':' text:Text IntraLineComment? nl
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
  = ('Accept'i / 'A'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ identifier:Identifier? IntraLineComment? nl
  {
    return {
      instruction : 'Accept',
      conditioner : conditioner || false,
      expression : expression || false,
      identifier : identifier || false
    };
  }
M
  = ('Match'i / 'M'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ matches:(matchStr matches*) IntraLineComment? nl
  {
     matches[1].unshift(matches[0]);
     return {
       instruction : 'Match',
       conditioner : conditioner || false,
       expression : expression || false,
       matches : matches[1]
     };
   }
matchWildCard
  = [\\*\?]
  {
    return { wildcard:text() };
  }
matchStr
  = str:(Escaped / InternalIdentifier / IdentifierText / matchWildCard / [^,!\|\n])*
  {
    return reduceText(str);
  }
matches
  = [,!\|] str:matchStr { return str; }

commas
  = _ ',' _

JM
  = ('JumpMatch'i / 'JM'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ labels:(Labl commas?)* IntraLineComment? nl
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
  = ('Jump'i / 'J'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ label:Labl IntraLineComment? nl
  {
    return {
      instruction : 'Jump',
      conditioner : conditioner || false,
      expression : expression || false,
      label : label
    };
  }
E
  = ('End'i / 'E'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ IntraLineComment? nl
  {
    return {
      conditioner : conditioner || false,
      expression : expression || false,
      instruction : 'End'
    };
  }
U
  = ('Use'i / 'U'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ label:Labl _ IntraLineComment? nl
  {
    return {
      instruction : 'Use',
      conditioner : conditioner || false,
      expression : expression || false,
      label : label
    };
  }
C
  = ('Compute'i / 'C'i) _ conditioner:Conditioner? _ expression:Expression? _ ':' _ assignment:Assignment _ IntraLineComment? nl
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
  = text:Labl IntraLineComment? nl
  { return {
      instruction : 'Label',
      label : text
    };
  }
