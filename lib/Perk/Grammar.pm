# This Parrot implementation of a Java parser is adapted from
#   http://www.antlr.org/grammar/1152141644268/Java.g
# Initial implementation by Chris Dolan.

# The following license comes from that ANTLR grammar:

#  [The "BSD licence"]
#  Copyright (c) 2007-2008 Terence Parr
#  All rights reserved.
# 
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  3. The name of the author may not be used to endorse or promote products
#     derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=begin overview

This is the grammar for perk written as a sequence of Perl 6 rules.

=end overview

grammar Perk::Grammar is PCT::Grammar;

rule TOP {
    <compilationUnit>
    [ $ || <panic: 'Syntax error'> ]
    {*}
}

token ws {
    | <!ww> <ws_all>+
    | <ws_all>*
}

token ws_all { 
    | \h+
    | \v+
    | '//' \N*
    | '/*' .*? '*/'
}

rule compilationUnit {
    | <annotation>+ [
      | <packageDeclaration> <importDeclaration>* <typeDeclaration>*
      | <classOrInterfaceDeclaration> <typeDeclaration>*
    ] {*}
    | <packageDeclaration>? <importDeclaration>* <typeDeclaration>* {*}
}

rule packageDeclaration {
    'package' $<package>=[<qualifiedName>] ';' {*}
}

rule importDeclaration {
    'import' 'static'? <qualifiedName> ['.' '*']? ';' {*}
}

rule typeDeclaration {
    | <classOrInterfaceDeclaration>
    | ';'
}

rule classOrInterfaceDeclaration {
    <classOrInterfaceModifiers> [ <classDeclaration> | <interfaceDeclaration> ] {*}
}

rule classOrInterfaceModifiers {
    <classOrInterfaceModifier>*
}

rule classOrInterfaceModifier {
    | <annotation>
    | 'public'<!before \w>
    | 'protected'<!before \w>
    | 'private'<!before \w>
    | 'abstract'<!before \w>
    | 'static'<!before \w>
    | 'final'<!before \w>
    | 'strictfp'<!before \w>
}

rule modifiers {
    <modifier>*
}

rule classDeclaration {
    | <normalClassDeclaration> {*} #= normalClassDeclaration
    | <enumDeclaration>        {*} #= enumDeclaration
}

rule normalClassDeclaration {
    'class' <Identifier> <typeParameters>?
    ['extends' <type>]?
    ['implements' <typeList>]?
    {*} #= start
    <classBody>
    {*} #= end
}

rule typeParameters {
    '<' <typeParameter> [ ',' <typeParameter> ]* '>'
}
rule typeParameter {
    <Identifier> ['extends' <typeBound>]?
}

rule typeBound {
    <type> [ '&' <type> ]*
}

rule enumDeclaration {
    <ENUM> <Identifier> ['implements' <typeList>]?
    <enumBody>
}

rule enumBody {
   '{' <enumConstants>? ','? <enumBodyDeclarations>? '}'
}

rule enumConstants {
   <enumConstant> [ ',' <enumConstant> ]*
}

rule enumConstant {
   <annotations>? <Identifier> <arguments>? <classBody>?
}

rule enumBodyDeclarations {
   ';' <classBodyDeclaration>*
}

rule interfaceDeclaration {
    | <normalInterfaceDeclaration>
    | <annotationTypeDeclaration>
}

rule normalInterfaceDeclaration {
   'interface' <Identifier> <typeParameters>? ['extends' <typeList>]?
    <interfaceBody>
}

rule typeList {
   <type> [ ',' <type> ]*
}

rule classBody {
   '{' <classBodyDeclaration>* '}' {*}
}

rule interfaceBody {
   '{' <interfaceBodyDeclaration>* '}'
}

rule classBodyDeclaration {
    | ';'
    | 'static'? <block>        {*} #= staticinit
    | <modifiers> <memberDecl> {*} #= member
}

rule memberDecl {
    | <genericMethodOrConstructorDecl>               {*} #= genericMethodOrConstructorDecl
    | 'void' <Identifier> <voidMethodDeclaratorRest> {*} #= voidMethodDeclaratorRest
    | <memberDeclaration>                            {*} #= memberDeclaration
    | <Identifier> <constructorDeclaratorRest>       {*} #= constructorDeclaratorRest
    | <interfaceDeclaration>                         {*} #= interfaceDeclaration
    | <classDeclaration>                             {*} #= classDeclaration
}

rule memberDeclaration {
   <type> [<methodDeclaration> | <fieldDeclaration>]
}

rule genericMethodOrConstructorDecl {
   <typeParameters> <genericMethodOrConstructorRest>
}

rule genericMethodOrConstructorRest {
    | [<type> | 'void'] <Identifier> <methodDeclaratorRest>
    | <Identifier> <constructorDeclaratorRest>
}

rule methodDeclaration {
   <Identifier> {*} <methodDeclaratorRest>
}

rule fieldDeclaration {
   <variableDeclarators> ';' {*}
}

rule interfaceBodyDeclaration {
    | <modifiers> <interfaceMemberDecl>
    | ';'
}

rule interfaceMemberDecl {
    | <interfaceMethodOrFieldDecl>
    | <interfaceGenericMethodDecl>
    | 'void' <Identifier> <voidInterfaceMethodDeclaratorRest>
    | <interfaceDeclaration>
    | <classDeclaration>
}

rule interfaceMethodOrFieldDecl {
   <type> <Identifier> <interfaceMethodOrFieldRest>
}

rule interfaceMethodOrFieldRest {
    | <constantDeclaratorsRest> ';'
    | <interfaceMethodDeclaratorRest>
}

rule methodDeclaratorRest {
   <formalParameters> [ '[' ']' ]*
        ['throws' <qualifiedNameList>]?
        [ <methodBody> | ';' ]
}

rule voidMethodDeclaratorRest {
   <formalParameters> ['throws' <qualifiedNameList>]?
        [ <methodBody> | ';' ]
   {*}
}

rule interfaceMethodDeclaratorRest {
   <formalParameters> [ '[' ']' ]* ['throws' <qualifiedNameList>]? ';'
}

rule interfaceGenericMethodDecl {
   <typeParameters> [<type> | 'void'] <Identifier>
        <interfaceMethodDeclaratorRest>
}

rule voidInterfaceMethodDeclaratorRest {
   <formalParameters> ['throws' <qualifiedNameList>]? ';'
}

rule constructorDeclaratorRest {
   <formalParameters> ['throws' <qualifiedNameList>]?
   <constructorBody>
}

rule constantDeclarator {
   <Identifier> <constantDeclaratorRest>
}

rule variableDeclarators {
   <variableDeclarator> [ ',' <variableDeclarator> ]*
}

rule variableDeclarator {
   <variableDeclaratorId> [ '=' <variableInitializer> ]?
}

rule constantDeclaratorsRest {
   <constantDeclaratorRest> [ ',' <constantDeclarator> ]*
}

rule constantDeclaratorRest {
   [ '[' ']' ]* '=' <variableInitializer>
}

rule variableDeclaratorId {
   <Identifier> [ '[' ']' ]*
}

rule variableInitializer {
    |   <arrayInitializer>
    |   <expression>
}

rule arrayInitializer {
   '{' [<variableInitializer> [ ',' <variableInitializer> ]* [',']? ]? '}'
}

rule modifier {
    |   <annotation>
    |   'public'<!before \w>
    |   'protected'<!before \w>
    |   'private'<!before \w>
    |   'static'<!before \w>
    |   'abstract'<!before \w>
    |   'final'<!before \w>
    |   'native'<!before \w>
    |   'synchronized'<!before \w>
    |   'transient'<!before \w>
    |   'volatile'<!before \w>
    |   'strictfp'<!before \w>
}

rule packageOrTypeName {
   <qualifiedName>
}

rule enumConstantName {
   <Identifier>
}

rule typeName {
   <qualifiedName>
}

rule type {
	| <primitiveType> [ '[' ']'  ]*
	| <classOrInterfaceType> [ '[' ']' ]*
}

rule classOrInterfaceType {
	<Identifier> <typeArguments>? [ '.' <Identifier> <typeArguments>? ]*
}

rule primitiveType {
    |   'boolean'<!before \w>
    |   'char'<!before \w>
    |   'byte'<!before \w>
    |   'short'<!before \w>
    |   'int'<!before \w>
    |   'long'<!before \w>
    |   'float'<!before \w>
    |   'double'<!before \w>
}

rule variableModifier {
    |   'final'<!before \w>
    |   <annotation>
}

rule typeArguments {
   '<' <typeArgument> [ ',' <typeArgument> ]* '>'
}

rule typeArgument {
    |   <type>
    |   '?' [ [ 'extends' | 'super' ] <type> ]?
}

rule qualifiedNameList {
   <qualifiedName> [ ',' <qualifiedName> ]*
}

rule formalParameters {
   '(' <formalParameterDecls>? ')'
}

rule formalParameterDecls {
   <variableModifiers> <type> <formalParameterDeclsRest>
}

rule formalParameterDeclsRest {
    |   <variableDeclaratorId> [ ',' <formalParameterDecls> ]?
    |   '...' <variableDeclaratorId>
}

rule methodBody {
   <block> {*}
}

rule constructorBody {
   '{' <explicitConstructorInvocation>? <blockStatement>* '}'
}

rule explicitConstructorInvocation {
    |   <nonWildcardTypeArguments>? ['this' | 'super'] <arguments> ';'
    |   <primary> '.' <nonWildcardTypeArguments>? 'super' <arguments> ';'
}


rule qualifiedName {
   <Identifier> [ '.' <Identifier> ]*
}

rule literal {
    |   <HexLiteral>
    |   <OctalLiteral>
    |   <FloatingPointLiteral>
    |   <DecimalLiteral>
    |   <CharacterLiteral>
    |   <StringLiteral>
    |   <booleanLiteral>
    |   'null'<!before \w>
}

rule booleanLiteral {
    | 'true'<!before \w>
    | 'false'<!before \w>
}

# // ANNOTATIONS

rule annotations {
   <annotation>+
}

rule annotation {
   '@' <!before 'interface'\s><annotationName> {*} [ '(' [ <elementValuePairs> | <elementValue> ]? ')' ]?
}

rule annotationName {
   <Identifier> [ '.' <Identifier> ]*
}

rule elementValuePairs {
   <elementValuePair> [ ',' <elementValuePair> ]*
}

rule elementValuePair {
   <Identifier> '=' <elementValue>
}

rule elementValue {
    |   <conditionalExpression>
    |   <annotation>
    |   <elementValueArrayInitializer>
}

rule elementValueArrayInitializer {
   '{' [<elementValue> [ ',' <elementValue> ]*]? [',']? '}'
}

rule annotationTypeDeclaration {
   '@' 'interface' <Identifier> <annotationTypeBody>
}

rule annotationTypeBody {
   '{' [ <annotationTypeElementDeclaration> ]* '}'
}

rule annotationTypeElementDeclaration {
   <modifiers> <annotationTypeElementRest>
}

rule annotationTypeElementRest {
    |   <type> <annotationMethodOrConstantRest> ';'
    |   <normalClassDeclaration> ';'?
    |   <normalInterfaceDeclaration> ';'?
    |   <enumDeclaration> ';'?
    |   <annotationTypeDeclaration> ';'?
}

rule annotationMethodOrConstantRest {
    |   <annotationMethodRest>
    |   <annotationConstantRest>
}

rule annotationMethodRest {
   <Identifier> '(' ')' <defaultValue>?
}

rule annotationConstantRest {
   <variableDeclarators>
}

rule defaultValue {
   'default' <elementValue>
}

# // STATEMENTS / BLOCKS

rule block {
   '{' <blockStatement>* '}' {*}
}

rule blockStatement {
    |   <localVariableDeclarationStatement> {*} #= localVariableDeclarationStatement
    |   <classOrInterfaceDeclaration>       {*} #= classOrInterfaceDeclaration
    |   <statement>                         {*} #= statement
}

rule localVariableDeclarationStatement {
    <localVariableDeclaration> ';'
}

rule localVariableDeclaration {
   <variableModifiers> <type> <variableDeclarators> {*}
}

rule variableModifiers {
   <variableModifier>*
}

rule statement {
    |   <block>
    |   <ASSERT> <expression> [':' <expression>]? ';'
    |   'if' <parExpression> <statement> ['else'<!before \w> <statement>]?
    |   'for' '(' <forControl> ')' <statement>
    |   'while' <parExpression> <statement>
    |   'do'<!before \w> <statement> 'while' <parExpression> ';'
    |   'try' <block>
        [ <catches> 'finally' <block>
        | <catches>
        |   'finally' <block>
        ]
    |   'switch' <parExpression> '{' <switchBlockStatementGroups> '}'
    |   'synchronized' <parExpression> <block>
    |   'return'<!before \w> <expression>? ';'
    |   'throw'<!before \w> <expression> ';'
    |   'break'<!before \w> <Identifier>? ';'
    |   'continue'<!before \w> <Identifier>? ';'
    |   ';' 
    |   <statementExpression> ';' {*}
    |   <!before 'case'\s><Identifier> ':' <statement>
}

rule catches {
   [ <catchClause> ]+
}

rule catchClause {
   'catch' '(' <formalParameter> ')' <block>
}

rule formalParameter {
   <variableModifiers> <type> <variableDeclaratorId>
}

rule switchBlockStatementGroups {
   [ <switchBlockStatementGroup> ]*
}

# /* The change here (switchLabel -> switchLabel+) technically makes this grammar
#    ambiguous; but with appropriately greedy parsing it yields the most
#    appropriate AST, one in which each group, except possibly the last one, has
#    labels and statements. */
rule switchBlockStatementGroup {
   <switchLabel>+ <blockStatement>*
}

rule switchLabel {
    |   'case' <constantExpression> ':' {*} #= normal
    |   'case' <enumConstantName> ':'   {*} #= enum
    |   'default' ':'                   {*} #= default
}

rule forControl {
    |   <enhancedForControl>
    |   <forInit>? ';' <expression>? ';' <forUpdate>?
}

rule forInit {
    |   <localVariableDeclaration>
    |   <expressionList>
}

rule enhancedForControl {
   <variableModifiers> <type> <Identifier> ':' <expression>
}

rule forUpdate {
   <expressionList>
}

# // EXPRESSIONS

rule parExpression {
   '(' <expression> ')' {*}
}

rule expressionList {
   <expression> [ ',' <expression> ]*
}

rule statementExpression {
   <expression> {*}
}

rule constantExpression {
   <expression>
}

rule expression {
   <conditionalExpression> [<assignmentOperator> <expression>]? {*}
}

rule assignmentOperator {
    |   '='
    |   '+='
    |   '-='
    |   '*='
    |   '/='
    |   '&='
    |   '|='
    |   '^='
    |   '%='
    |   '<<='
    |   '>>>='
    |   '>>='
}

rule conditionalExpression {
   <conditionalOrExpression> [ '?' <expression> ':' <expression> ]?
}

rule conditionalOrExpression {
   <conditionalAndExpression> [ '||' <conditionalAndExpression> ]*
}

rule conditionalAndExpression {
   <inclusiveOrExpression> [ '&&' <inclusiveOrExpression> ]*
}

rule inclusiveOrExpression {
   <exclusiveOrExpression> [ '|' <exclusiveOrExpression> ]*
}

rule exclusiveOrExpression {
   <andExpression> [ '^' <andExpression> ]*
}

rule andExpression {
   <equalityExpression> [ '&' <equalityExpression> ]*
}

rule equalityExpression {
   <instanceOfExpression> [ ['==' | '!='] <instanceOfExpression> ]*
}

rule instanceOfExpression {
   <relationalExpression> ['instanceof' <type>]?
}

rule relationalExpression {
   <shiftExpression> [ <relationalOp> <shiftExpression> ]*
}

rule relationalOp {
    |   '<='
    |   '>='
    |   '<' 
    |   '>' 
}

rule shiftExpression {
   <additiveExpression> [ <shiftOp> <additiveExpression> ]*
}

rule shiftOp {
    |   '<<'
    |   '>>>'
    |   '>>'
}


rule additiveExpression {
   <multiplicativeExpression> [ ['+' | '-'] <multiplicativeExpression> ]*
}

rule multiplicativeExpression {
   <unaryExpression> [ [ '*' | '/' | '%' ] <unaryExpression> ]*
}

rule unaryExpression {
    |   '+' <unaryExpression>
    |   '-' <unaryExpression>
    |   '++' <unaryExpression>
    |   '--' <unaryExpression>
    |   <unaryExpressionNotPlusMinus>
}

rule unaryExpressionNotPlusMinus {
    |   '~' <unaryExpression>
    |   '!' <unaryExpression>
    |   <castExpression>
    |   <primary> <selector>* ['++'|'--']?
}

rule castExpression {
    |  '(' <primitiveType> ')' <unaryExpression>
    |  '(' [<type> | <expression>] ')' <unaryExpressionNotPlusMinus>
}

rule primary {
    |   <parExpression>
    |   'this'<!before \w> # added the 'before' to work around a longest-token problem
         [ '.' <!before 'new'\s> <Identifier> ]* <IdentifierSuffix>? {*}
    |   'super' <superSuffix>
    |   <literal>
    |   'new' <creator>
    |   <Identifier> [ '.'  <!before 'new'\s> <Identifier> ]* <IdentifierSuffix>?
    |   <primitiveType> [ '[' ']' ]* '.' 'class'
    |   'void' '.' 'class'
}

rule IdentifierSuffix {
    |   [ '[' ']' ]+ '.' 'class'
    |   [ '[' <expression> ']' ]+ # // can also be matched by selector, but do here
    |   <arguments>
    |   '.' 'class'
    |   '.' <explicitGenericInvocation>
    |   '.' 'this'
    |   '.' 'super' <arguments>
    |   '.' 'new' <innerCreator>
}

rule creator {
    |   <nonWildcardTypeArguments> <createdName> <classCreatorRest>
    |   <createdName> [<arrayCreatorRest> | <classCreatorRest>]
}

rule createdName {
    | <primitiveType>
    | <classOrInterfaceType>
}

rule innerCreator {
   <nonWildcardTypeArguments>? <Identifier> <classCreatorRest>
}

rule arrayCreatorRest {
   '['
        [   ']' [ '[' ']' ]* <arrayInitializer>
        | <expression>  {*} ']' [ '[' <expression> ']' ]* [ '[' ']' ]*
        ]
}

rule classCreatorRest {
   <arguments> <classBody>?
}

rule explicitGenericInvocation {
   <nonWildcardTypeArguments> <Identifier> <arguments>
}

rule nonWildcardTypeArguments {
   '<' <typeList> '>'
}

rule selector {
    |   '.' 'this'
    |   '.' 'super' <superSuffix>
    |   '.' 'new' <innerCreator>
    |   '.' <Identifier> <arguments>?
    |   '[' <expression> ']'
}

rule superSuffix {
   <arguments>
    |   '.' <Identifier> <arguments>?
}

rule arguments {
   '(' <expressionList>? ')'
}

# // LEXER

token HexLiteral {
   '0' ['x'|'X'] [
      | '.' <HexDigit>+ <HexExponent>? <FloatTypeSuffix>?
      | <HexDigit>+ [ '.' <HexDigit>* <HexExponent>? <FloatTypeSuffix>? | <IntegerTypeSuffix>? ]
    ]
}
token HexDigit { \d|<[a..f]>|<[A..F]> }
token HexExponent { ['p'|'P'] ['+'|'-']? \d+ }

token OctalLiteral { '0' <[0..7]>+ <IntegerTypeSuffix>? }

token DecimalLiteral { ['0'<!before \d> | <[1..9]> \d*] <IntegerTypeSuffix>? }
token IntegerTypeSuffix { 'l'|'L' }

token FloatingPointLiteral {
    |   \d+ '.' \d* <Exponent>? <FloatTypeSuffix>?
    |   '.' \d+ <Exponent>? <FloatTypeSuffix>?
    |   \d+ <Exponent> <FloatTypeSuffix>?
    |   \d+ <FloatTypeSuffix>
}
token Exponent { ['e'|'E'] ['+'|'-']? \d+ }
token FloatTypeSuffix { 'f'|'F'|'d'|'D' }

token CharacterLiteral { '\'' [ <EscapeSequence> | <-esc_single_quote> ] '\'' }
token StringLiteral    { '"'  [ <EscapeSequence> | <-esc_double_quote> ]* '"' }
token esc_single_quote { '\\' | '\'' }
token esc_double_quote { '\\' | '"'  }

token EscapeSequence {
    |   '\\' ['b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\']
    |   <UnicodeEscape>
    |   <OctalEscape>
}

token OctalEscape {
 '\\' [
    | <[0..3]> <[0..7]> <[0..7]>
    | <[0..7]> <[0..7]>
    | <[0..7]>
 ]
}

token UnicodeEscape { '\\u' <HexDigit>**{4} }

token ENUM { 'enum'<!before \w> }
token ASSERT { 'assert'<!before \w> }

token Identifier { <!before <Perk::Grammar::keyword>\W><.ident> }
token keyword {
        # from http://java.sun.com/docs/books/jls/third_edition/html/lexical.html#3.9
        'abstract'    | 'continue'    | 'for'           | 'new'          | 'switch'
        'assert'      | 'default'     | 'if'            | 'package'      | 'synchronized'
        'boolean'     | 'do'          | 'goto'          | 'private'      | 'this'
        'break'       | 'double'      | 'implements'    | 'protected'    | 'throw'
        'byte'        | 'else'        | 'import'        | 'public'       | 'throws'
        'case'        | 'enum'        | 'instanceof'    | 'return'       | 'transient'
        'catch'       | 'extends'     | 'int'           | 'short'        | 'try'
        'char'        | 'final'       | 'interface'     | 'static'       | 'void'
        'class'       | 'finally'     | 'long'          | 'strictfp'     | 'volatile'
        'const'       | 'float'       | 'native'        | 'super'        | 'while'                     
}
