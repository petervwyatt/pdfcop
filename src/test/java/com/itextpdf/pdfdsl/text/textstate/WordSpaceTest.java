package com.itextpdf.pdfdsl.text.textstate;

import com.itextpdf.antlr.PdfStreamLexer;
import com.itextpdf.antlr.PdfStreamParser;
import com.itextpdf.pdfdsl.ThrowingErrorListener;

import java.util.Arrays;
import java.util.Collection;

import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.misc.ParseCancellationException;
import org.antlr.v4.runtime.tree.TerminalNode;
import org.junit.Assert;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

@RunWith(Parameterized.class)
public class WordSpaceTest {
    @Rule
    public ExpectedException expectedException = ExpectedException.none();

    @Parameterized.Parameters
    public static Collection data() {
        return Arrays.asList(new Object[][] {
                { "0 Tw", true, 0, "Tw" },
                { "1 Tw", true, 1, "Tw" },
                { "20 Tw", true, 20, "Tw" },
                { "Abcde Tw", false, 0, "Tw" }
        });
    }

    private String syntaxToCheck;
    private boolean pass;
    private int operand;
    private String operator;

    public WordSpaceTest(String syntaxToCheck, boolean pass, int operand, String operator) {
        this.syntaxToCheck = syntaxToCheck;
        this.pass = pass;
        this.operand = operand;
        this.operator = operator;
    }

    @Test
    public void test() {
        if (! this.pass) {
            this.expectedException.expect(ParseCancellationException.class);
        }

        PdfStreamLexer streamLexer = new PdfStreamLexer(CharStreams.fromString(this.syntaxToCheck));
        streamLexer.removeErrorListeners();
        streamLexer.addErrorListener(ThrowingErrorListener.INSTANCE);

        CommonTokenStream tokens = new CommonTokenStream(streamLexer);
        PdfStreamParser streamParser = new PdfStreamParser(tokens);
        streamParser.removeErrorListeners();
        streamParser.addErrorListener(ThrowingErrorListener.INSTANCE);

        PdfStreamParser.WordSpaceContext context = streamParser.wordSpace();
        int childCount = context.getChildCount();

        Assert.assertEquals(2, childCount);

        TerminalNode operand = (TerminalNode) context.getChild(0);
        TerminalNode operator = (TerminalNode) context.getChild(1);

        String actual = operand.getSymbol().getText();
        String actualOperator = operator.getSymbol().getText();

        Assert.assertEquals(this.operand, Integer.parseInt(actual));
        Assert.assertEquals(this.operator, actualOperator);
    }

}