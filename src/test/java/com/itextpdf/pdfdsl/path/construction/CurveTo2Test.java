package com.itextpdf.pdfdsl.path.construction;

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
public class CurveTo2Test {
    @Rule
    public ExpectedException expectedException = ExpectedException.none();
    @Parameterized.Parameters
    public static Collection data() {
        return Arrays.asList(new Object[][] {
                { "0 1 2 3 v", true, new int[] {0, 1, 2, 3}, "v" },
                { "0 1 2 v", false, new int[] {0, 1, 2, 3}, "v" }
        });
    }

    private String syntaxToCheck;
    private boolean pass;
    private int[] operands;
    private String operator;

    public CurveTo2Test(String syntaxToCheck, boolean pass, int[] operands, String operator) {
        this.syntaxToCheck = syntaxToCheck;
        this.pass = pass;
        this.operands = operands;
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

        PdfStreamParser.CurveTo2Context  context = streamParser.curveTo2();
        int childCount = context.getChildCount();

        Assert.assertEquals(5, childCount);

        for ( int i = 0; i < 4; i++ ) {
            TerminalNode operand = (TerminalNode) context.getChild(i);
            String actual = operand.getSymbol().getText();
            Assert.assertEquals(this.operands[i], Integer.parseInt(actual));
        }

        TerminalNode operator = (TerminalNode) context.getChild(4);
        String actualOperator = operator.getSymbol().getText();
        Assert.assertEquals(this.operator, actualOperator);
    }

}