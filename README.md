# pdfCop

## Summary

pdfCop is a compiled/to-be-compiled Java project based on an ANTLR4 grammar file that describes how Content Streams are structured as per the PDF specification. pdfCop can tell you whether a content stream, a PDF file, or a snippet follows the specification or not and it will let you know where the provided syntax did go wrong.

## Building

This project is built using maven. After cloning, run the following command:

```bash
mvn package
```

After a successful build, your target folder should contain a `pdfCop-x.y.z.jar` which you can then use in your projects!

You can also use `mvn install` so that the artifact is automatically installed into your local maven repository!


## Usage

Add the pdfCop dependency to your project and you can start using the tool as a high level tool:

```java
new PdfCop().isDocumentFollowingTheRules(inputPdf)
```

`inputPdf` is a path to your input PDF file. It will return a boolean letting you know whether the provided document's content streams follow the specification or not.

You can also access the specific objects and their children through the generated API. Feel free to check some of the tests to look for more exhaustive examples. This is an area where we can add more convenience for the user.


## Troubleshooting

Some versions of IntelliJ IDEA might not be able to find the generated sources after a build. To remediate this, right-click on the root in the Project View, open the `Maven` submenu and click `Generate Sources and Update Folders`

## Command Line Usage

The following Linux bash command can be used to visualize the parse of a PDF content stream. Enter the content stream and then press CTRL+D to parse:

```bash
antlr4-parse ./src/main/antlr4/com/itextpdf/antlr/PdfStream.g4 content_stream -tokens
0 1%comment
1 rg
^D
```

Alternatively use the Linux bash `printf` command to more easily enter and confirm complex byte sequences before piping to `antlr4-parse`:

```bash
printf "0\n%%comment\r1\000 1 rg" | od -A n -w40 -v -t c
printf "0\n%%comment\r1\000 1 rg" | od -A n -w40 -v -t x1
printf "0\n%%comment\r1\000 1 rg" | antlr4-parse ./src/main/antlr4/com/itextpdf/antlr/PdfStream.g4 content_stream -trace -tokens
```

A Linux bash script `linux-antlr4-test/sh` is provided which reads individual lines of input from text files and runs each line through `antlr4-parse`. Note that the return code of PASS/FAIL reflects the ANTLR system and is **not** the validity of the PDF content stream! The token sequence needs to be examined to determine this (`-tokens`).

## Disclaimer

This is an experimental tool, not an iText product. It is provided to the
community under the terms of the AGPL (see [LICENSE](LICENSE.md)) on an as-is
basis.