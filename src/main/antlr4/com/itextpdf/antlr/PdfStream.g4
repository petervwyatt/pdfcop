/*
    Copyright (c) 2023 iText Group NV

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License version 3
    as published by the Free Software Foundation with the addition of the
    following permission added to Section 15 as permitted in Section 7(a):
    FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY
    ITEXT GROUP. ITEXT GROUP DISCLAIMS THE WARRANTY OF NON INFRINGEMENT
    OF THIRD PARTY RIGHTS

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Affero General Public License for more details.
    You should have received a copy of the GNU Affero General Public License
    along with this program; if not, see http://www.gnu.org/licenses or write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA, 02110-1301 USA, or download the license from the following URL:
    http://itextpdf.com/terms-of-use/

    The interactive user interfaces in modified source and object code versions
    of this program must display Appropriate Legal Notices, as required under
    Section 5 of the GNU Affero General Public License.

    In accordance with Section 7(b) of the GNU Affero General Public License,
    a covered work must retain the producer line in every PDF that is created
    or manipulated using iText.
 */
grammar PdfStream;

// PARSER RULES --------------------------------------------------------------


// Main entry point to parser.
// Represents any PDF content stream (page, Form XObject, Type 3 glyph description, DA entry of annotations and fields, etc.)
// See Table 50 and Figure 9 in ISO 32000-2:2020.
content_stream : content_stream_level EOF
    ;

content_stream_level 
    : ( COMPATIBILITY | generalGraphicsState | specialGraphicsState | color | textState | shading | dobject | textObject | pathObject | comment | inlineImageObject | markedContent )*
    ;

textObject
    : BEGIN_TEXT ( COMPATIBILITY | generalGraphicsState | color | textState | textShowing | textPositioning | comment | markedContent )* END_TEXT
    ;

pathObject
    : ( moveTo | rectangle ) COMPATIBILITY | pathConstruction pathClipping? pathPainting
    ;

dobject
    : PDF_NAME XOBJECT
    ;

shading
    : PDF_NAME SHADING_PATTERN
    ;

generalGraphicsState
    : ( COMPATIBILITY | lineCap | lineJoin | lineWidth | miter | dashPattern | flatness | graphicsState | renderingIntent | saveState | restoreState | comment )+
    ;

        // >= 0.0
        lineWidth
            : POSITIVE_NUMBER LINE_WIDTH
            ;

        lineCap
            : ('0' | '1' | '2') LINE_CAP
            ;

        lineJoin
            : ('0' | '1' | '2') LINE_JOIN
            ;

        // should be strictly > 0
        miter
            : POSITIVE_NUMBER MITER_LIMIT
            ;

        dashPattern
            : numberArray NUMBER DASH_PATTERN
            ;

        // should be strictly > 0
        flatness
            : POSITIVE_NUMBER FLATNESS_TOLERANCE
            ;

        graphicsState
            : PDF_NAME GRAPHICS_STATE
            ;

        renderingIntent
            : PDF_NAME COLOUR_RENDERING_INTENT
            ;

        saveState
            : SAVE
            ;

        restoreState
            : RESTORE
            ;

specialGraphicsState
    : ( COMPATIBILITY | currentMatrix | comment )+
    ;

        currentMatrix
            : NUMBER NUMBER NUMBER NUMBER NUMBER NUMBER CURRENT_TRANSFORMATION_MATRIX
            ;

color
    : ( COMPATIBILITY | cs | sc | gray | rgb | cmyk | comment )+
    ;

        cs
            : PDF_NAME (NON_STROKE_COLOUR_SPACE | STROKE_COLOUR_SPACE)
            ;

        sc
            : NUMBER+ PDF_NAME (STROKE_COLOUR_DEVICE_EXTRA | NON_STROKE_COLOUR_DEVICE_EXTRA )
            | NUMBER+ ( STROKE_COLOUR_DEVICE | STROKE_COLOUR_DEVICE_EXTRA | NON_STROKE_COLOUR_DEVICE | NON_STROKE_COLOUR_DEVICE_EXTRA )
            ;

        gray
            : NUMBER ( STROKE_COLOUR_DEVICE_GRAY | NON_STROKE_COLOUR_DEVICE_GRAY )
            ;

        rgb
            : RGB_TOKEN
            ;

        cmyk
            : NUMBER NUMBER NUMBER NUMBER ( STROKE_COLOUR_DEVICE_CMYK | NON_STROKE_COLOUR_DEVICE_CMYK )
            ;

textPositioning
    : ( COMPATIBILITY |textMoveToNextLineCurrentLeading | textMatrix | textMoveToNextLineWithOffset | comment )+
    ;

        textMoveToNextLineWithOffset
            : NUMBER NUMBER ( MOVE_TO_START_NEXT_LINE | MOVE_TO_START_NEXT_LINE_SET_LEADING )
            ;

        textMoveToNextLineCurrentLeading
            : MOVE_TO_START_NEXT_LINE_CURRENT_LEADING
            ;

        textMatrix
            : NUMBER NUMBER NUMBER NUMBER NUMBER NUMBER TEXT_MATRIX
            ;

textShowing
    : ( COMPATIBILITY | textShow | textShowWithNewLine | textShowWithNewLineAndSpacing | textShowWithGlyphPositioning | comment )+
    ;

        textShow
            : STRING TEXT_SHOW
            ;

        textShowWithNewLine
            : STRING TEXT_NEW_LINE_AND_SHOW
            ;

        textShowWithNewLineAndSpacing
            : NUMBER NUMBER STRING TEXT_NEW_LINE_AND_SHOW_WITH_SPACING
            ;

        textShowWithGlyphPositioning
            : stringPosArray TEXT_SHOW_GLYPH_POSITIONING
            ;

textState
    : ( COMPATIBILITY | characterSpace | wordSpace | textScale | leading | fontSize | textRenderMode | textRise | comment )+
    ;

        characterSpace
            : NUMBER TEXT_CHAR_SPACE
            ;

        wordSpace
            : NUMBER TEXT_WORD_SPACE
            ;

        // >0, percentage scale
        textScale
            : POSITIVE_NUMBER TEXT_SCALE
            ;

        leading
            : NUMBER TEXT_LEADING
            ;

        fontSize
            : PDF_NAME NUMBER TEXT_FONT_AND_SIZE
            ;

        textRenderMode
            : ('0' | '1' | '2' | '3' | '4' | '5' | '6' | '7') TEXT_RENDER_MODE 
            ;

        textRise
            : NUMBER TEXT_RISE
            ;

markedContent
    : markedContentPoint | markedContentSequence
    ;

// See subclause 14.6 in ISO 32000-2:2020
markedContentSequence
    : ( PDF_NAME ) ( BEGIN_MARKED_CONTENT | ( dictionary | PDF_NAME )  BEGIN_MARKED_CONTENT_WITH_PROPERTIES )
      content_stream_level 
      END_MARKED_CONTENT
    ;

// See subclause 14.6 in ISO 32000-2:2020
markedContentPoint
    : PDF_NAME ((MARKED_CONTENT_POINT) | ( dictionary ( MARKED_CONTENT_POINT_WITH_PROPERTIES )))
    ;

// See Table 58 in ISO 32000-2:2020
pathConstruction
    : ( COMPATIBILITY | moveTo | lineTo | curveTo | curveTo2 | curveTo3 | closePath | rectangle | comment )*
    ;

        moveTo
            : NUMBER NUMBER MOVE_TO
            ;

        lineTo
            : NUMBER NUMBER LINE_TO
            ;

        curveTo
            : NUMBER NUMBER NUMBER NUMBER NUMBER NUMBER BEZIER_CURVE
            ;

        curveTo2
            : NUMBER NUMBER NUMBER NUMBER BEZIER_CURVE_2
            ;

        curveTo3
            : NUMBER NUMBER NUMBER NUMBER BEZIER_CURVE_3
            ;

        closePath
            : CLOSE_BY_LINE_TO_START
            ;

        rectangle
            : NUMBER NUMBER NUMBER NUMBER RECTANGLE
            ;

pathPainting
    : (stroke | strokeAndClose | fill | fillAndStroke | fillStrokeAndClose | endPath | comment)
    ;

        stroke
            : STROKE_PATH
            ;

        strokeAndClose
            : CLOSE_AND_STROKE_PATH
            ;

        fill
            : FILL_PATH_NON_ZERO | FILL_PATH_NON_ZERO_2 | FILL_PATH_EVEN_ODD
            ;

        fillAndStroke
            : FILL_STROKE_PATH_EVEN_ODD | FILL_STROKE_PATH_NON_ZERO
            ;

        fillStrokeAndClose
            : CLOSE_FILL_STROKE_PATH_NON_ZERO | CLOSE_FILL_STROKE_PATH_ODD_EVEN
            ;

        endPath
            : END_PATH_NO_STROKE_OR_FILL
            ;

pathClipping
    : CLIP_PATH_EVEN_ODD | CLIP_PATH_NON_ZERO
    ;

// Inline images always require certain keys (so never zero keys!). See subclause 8.9.7 in ISO 32000-2:2020
inlineImageObject
    : BEGIN_INLINE_IMAGE (PDF_NAME (PDF_NAME | NUMBER | STRING | dictionary | array | 'true' | 'false' | 'null'))+ INLINE_DATA
    ;

number
    : NUMBER
    ;

// See subclause 7.3.6 in ISO 32000-2:2020
// Note that strings in arrays can be any type of string (ASCII, byte, PDFDocEncoding, UTF-16BE, UTF-8).
// Indirect references are not permitted in PDF content streams. 
array
    : '[' (NUMBER | STRING | PDF_NAME | dictionary | array | 'true' | 'false' | 'null' )* ']'
    ;

// See subclause 7.3.7 in ISO 32000-2:2020 
// Note that strings in dictionaries can be any type of string (ASCII, byte, PDFDocEncoding, UTF-16BE, UTF-8).
// Indirect references are not permitted in PDF content streams. 
dictionary
    : LDOUBLEANGLE (PDF_NAME (PDF_NAME | NUMBER | STRING | dictionary | array | 'true' | 'false' | 'null' ))* RDOUBLEANGLE
    ;

numberArray
    : LSQUARE NUMBER* RSQUARE
    ;

string
    : STRING
    ;

comment
    : COMMENT
    ;


stringPosArray
    : LSQUARE ((STRING NUMBER) | STRING | NUMBER)* RSQUARE
    ;

RGB_TOKEN
    : NUMBER WS NUMBER WS NUMBER WS (STROKE_COLOUR_DEVICE_RGB | NON_STROKE_COLOUR_DEVICE_RGB)
    ;

// LEXER TOKENS --------------------------------------------------------------

// Inline image operators
INLINE_DATA    : BEGIN_INLINE_IMAGE_DATA WS .*? END_INLINE_IMAGE; 

// General Graphics State operators
LINE_WIDTH                              : 'w';
LINE_JOIN                               : 'j';
LINE_CAP                                : 'J';
MITER_LIMIT                             : 'M';
DASH_PATTERN                            : 'd';
COLOUR_RENDERING_INTENT                 : 'ri';
FLATNESS_TOLERANCE                      : 'i';
GRAPHICS_STATE                          : 'gs';

// Special Graphics State operators
SAVE                                    : 'q'; 
RESTORE                                 : 'Q';
CURRENT_TRANSFORMATION_MATRIX           : 'cm';

// Path Construction operators
MOVE_TO                                 : 'm';
LINE_TO                                 : 'l';
BEZIER_CURVE                            : 'c';
BEZIER_CURVE_2                          : 'v';
BEZIER_CURVE_3                          : 'y';
CLOSE_BY_LINE_TO_START                  : 'h';
RECTANGLE                               : 're';

// Path Painting operators
STROKE_PATH                             : 'S';
CLOSE_AND_STROKE_PATH                   : 's';
FILL_PATH_NON_ZERO                      : 'f';
FILL_PATH_NON_ZERO_2                    : 'F';
FILL_PATH_EVEN_ODD                      : 'f*';
FILL_STROKE_PATH_NON_ZERO               : 'B';
FILL_STROKE_PATH_EVEN_ODD               : 'B*';
CLOSE_FILL_STROKE_PATH_NON_ZERO         : 'b';
CLOSE_FILL_STROKE_PATH_ODD_EVEN         : 'b*';
END_PATH_NO_STROKE_OR_FILL              : 'n';

// Clipping Path operators
CLIP_PATH_NON_ZERO                      : 'W';
CLIP_PATH_EVEN_ODD                      : 'W*';

// Text Objects operators
BEGIN_TEXT                              : 'BT';
END_TEXT                                : 'ET';

// Text State operators
TEXT_CHAR_SPACE                         : 'Tc';
TEXT_WORD_SPACE                         : 'Tw';
TEXT_SCALE                              : 'Tz';
TEXT_LEADING                            : 'TL';
TEXT_FONT_AND_SIZE                      : 'Tf';
TEXT_RENDER_MODE                        : 'Tr';
TEXT_RISE                               : 'Ts';

// Text Positioning operators
MOVE_TO_START_NEXT_LINE                 : 'Td';
MOVE_TO_START_NEXT_LINE_SET_LEADING     : 'TD';
TEXT_MATRIX                             : 'Tm';
MOVE_TO_START_NEXT_LINE_CURRENT_LEADING : 'T*';

// Text Showing operators
TEXT_SHOW                               : 'Tj';
TEXT_SHOW_GLYPH_POSITIONING             : 'TJ';
TEXT_NEW_LINE_AND_SHOW                  : '\'';
TEXT_NEW_LINE_AND_SHOW_WITH_SPACING     : '"';

// Type 3 Fonts operators
TYPE3_SET_WIDTH_AND_SHAPE_AND_COLOUR    : 'd0';
TYPE3_SET_WIDTH_AND_SHAPE               : 'd1';

// Color operators
STROKE_COLOUR_SPACE                     : 'CS';
NON_STROKE_COLOUR_SPACE                 : 'cs';
STROKE_COLOUR_DEVICE                    : 'SC';
STROKE_COLOUR_DEVICE_EXTRA              : 'SCN';
NON_STROKE_COLOUR_DEVICE                : 'sc';
NON_STROKE_COLOUR_DEVICE_EXTRA          : 'scn';
STROKE_COLOUR_DEVICE_GRAY               : 'G';
NON_STROKE_COLOUR_DEVICE_GRAY           : 'g';
STROKE_COLOUR_DEVICE_RGB                : 'RG';
NON_STROKE_COLOUR_DEVICE_RGB            : 'rg';
STROKE_COLOUR_DEVICE_CMYK               : 'K';
NON_STROKE_COLOUR_DEVICE_CMYK           : 'k';

// Shading Patterns operators
SHADING_PATTERN                         : 'sh';

// Inline Images operators
BEGIN_INLINE_IMAGE                      : 'BI';
BEGIN_INLINE_IMAGE_DATA                 : 'ID';
END_INLINE_IMAGE                        : 'EI';

// XObject operator
XOBJECT                                 : 'Do';

// Marked Content operators
MARKED_CONTENT_POINT                    : 'MP';
MARKED_CONTENT_POINT_WITH_PROPERTIES    : 'DP';
BEGIN_MARKED_CONTENT                    : 'BMC';
BEGIN_MARKED_CONTENT_WITH_PROPERTIES    : 'BDC';
END_MARKED_CONTENT                      : 'EMC';

// Compatibility section operators
fragment BEGIN_COMPATIBILITY_SECTION    : 'BX';
fragment END_COMPATIBILITY_SECTION      : 'EX';

// See subclause 7.3.5 in ISO 32000-2:2020
// Note that "/" (i.e. an empty name object) is valid! 
PDF_NAME     : '/' (('#' HEXDIGIT HEXDIGIT) | REGULAR_CHAR )*;

// PDF delimiters (Table 2, ISO 32000-2:2020)
// Note that '{' and '}' ONLY apply as delimiters inside PostScript Type 4 functions and are not needed here!
fragment LPAREN       : '(';
fragment RPAREN       : ')';
fragment LANGLE       : '<';
fragment RANGLE       : '>';
LSQUARE               : '[';
RSQUARE               : ']';
LDOUBLEANGLE          : '<<';
RDOUBLEANGLE          : '>>';

// PDF string object escape character
fragment REVERSE_SOLIDUS: '\\';

// PDF decimal point for real numbers
fragment DOT            : '.';

// PDF string object
STRING         : STRING_LITERAL | STRING_HEX;

// PDF numeric object
NUMBER         : INTEGER_NUMBER | REAL_NUMBER;

// Zero hex digits is valid empty hex string.
// Implicit zero is appended for odd numbers of hex digits (see subclause 7.3.4.3 Hexadecimal strings)
fragment STRING_HEX : LANGLE (HEXDIGIT)* RANGLE;

// Constrain to 0.0 <= input <= 1.0
ZERO_TO_ONE_NUMBER : '+'? ( ('0' (DOT DIGIT*)?) | (DOT DIGIT+) | ('1' (DOT '0'*)?) );

// >= 0
POSITIVE_NUMBER: POSITIVE_INTEGER | POSITIVE_REAL;

// Any integer
INTEGER_NUMBER : ('-' | '+' )? DIGIT+;

// >= 0
fragment POSITIVE_INTEGER : '+'? DIGIT+;

// >= 0.0
fragment POSITIVE_REAL  : '+'? ( (DIGIT+ DOT DIGIT*) | (DIGIT* DOT DIGIT+) );

// Any real number. No exponential or scientific formats allowed.
fragment REAL_NUMBER    : ('-' | '+')? ( (DIGIT+ DOT DIGIT*) | (DIGIT* DOT DIGIT+) );

// Hexadecimal digit (case insensitive)
fragment HEXDIGIT       : 'a'..'f' | 'A'..'F' | DIGIT;

// Decimal digit
fragment DIGIT          : '0'..'9';

// Table 3, ISO 32000-2:2020 literal string escape sequences (start with REVERSE SOLIDUS '\') and subsequent text.
// Note this does **NOT** restrict input to 1-3 octal digits only as per ISO 32000-2:2020!
fragment STRING_LITERAL_ESCAPE :
                    REVERSE_SOLIDUS 
                    ( 'r' | 't' | 'b' | 'f' | '(' | ')' | REVERSE_SOLIDUS | '0'..'7'+ | EOL )
                    ;

// See subclause 7.3.4.2 Literal strings, ISO 32000-2:2020
// Note also that all strings (ASCII, text, byte, PDFDocEncoding, UTF-16BE and UTF-8) are all valid by this regex.
// BCP-47 escape sequences in Unicode strings are also valid by this regex.
// Internal matching pairs of LPAREN and RPAREN do not need escaping.
// ANTLR4 ~ operator doesn't allow lexer rules so need to inline RPAREN.
fragment STRING_LITERAL : LPAREN
               (
               '\u0000'..'\u0027'
               | ('\u005c' '\u0028')
               | '\u0029'..'\uffff'
               )*
               RPAREN
               ;

// See subclause 7.3.5 Name objects, ISO 32000-2:2020. 
// Excludes all PDF delimiters, EOL and PDF whitespace characters.
// ANTLR4 '~' operator doesn't allow using other lexer token names so need to inline everything.
fragment REGULAR_CHAR : ('\u0001'..'\u0008'   // exclude NUL, HT, LF
               | '\u000B'              // exclude CR, FF
               | '\u000E'..'\u0019'    // exclude SPACE
               | '\u0021'..'\u0024'    // exclude '%'
               | '\u0026'..'\u0027'    // exclude '(', ')'
               | '\u002A'..'\u002E'    // exclude '/'
               | '\u0030'..'\u003B'    // exclude '<'
               | '\u003D'              // exclude '>'
               | '\u003F'
               | '\u0040'              // avoid ANTLR4 warning "... probably contains not implied characters @. Both bounds should be defined in lower or UPPER case"
               | '\u0041'..'\u005A'    // exclude '['
               | '\u005C'              // exclude ']'
               | '\u005D'..'\u007A'    // exclude '{' - only for Type 4 PostScript functions
               | '\u007C'              // exclude '}'  - only for Type 4 PostScript functions
               | '\u007E'..'\u00ff'
               );

// Table 33, ISO 32000-2:2020. It's the wild west beween BX and EX.
COMPATIBILITY  : BEGIN_COMPATIBILITY_SECTION .*? END_COMPATIBILITY_SECTION;

// PDF comments start with '%' and finish at next EOL
COMMENT        : '%' ~[\r\n]* EOL -> skip; 

// PDF has special EOLs (text below Table 1 in ISO 32000-2:2020)
EOL : ( '\r' | '\n' | ('\r' '\n') ) -> skip;

// PDF has special white space characters (Table 1 in ISO 32000-2:2020)
WS : [ \t\r\n\u0000\u000C]+ -> skip;
