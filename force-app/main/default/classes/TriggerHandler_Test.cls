@IsTest
/*
Source Code: https://github.com/kevinohara80/sfdc-trigger-framework
*/

private class TriggerHandler_Test {
    private static final String TRIGGER_CONTEXT_ERROR = 'Trigger handler called outside of Trigger execution';

    private static String lastMethodCalled;

    private static TriggerHandler_Test.TestHandler handler;

    static {
        handler = new TriggerHandler_Test.TestHandler();
        // override its internal trigger detection
        handler.isTriggerExecuting = true;
    }

    /***************************************
     * unit tests
     ***************************************/

    // contexts tests

    @IsTest
    private static void testBeforeInsert() {
        beforeInsertMode();
        handler.run();
        Assert.areEqual(
            'beforeInsert',
            lastMethodCalled,
            'last method should be beforeInsert'
        );
    }

    @IsTest
    private static void testBeforeUpdate() {
        beforeUpdateMode();
        handler.run();
        Assert.areEqual(
            'beforeUpdate',
            lastMethodCalled,
            'last method should be beforeUpdate'
        );
    }

    @IsTest
    private static void testBeforeDelete() {
        beforeDeleteMode();
        handler.run();
        Assert.areEqual(
            'beforeDelete',
            lastMethodCalled,
            'last method should be beforeDelete'
        );
    }

    @IsTest
    private static void testAfterInsert() {
        afterInsertMode();
        handler.run();
        Assert.areEqual(
            'afterInsert',
            lastMethodCalled,
            'last method should be afterInsert'
        );
    }

    @IsTest
    private static void testAfterUpdate() {
        afterUpdateMode();
        handler.run();
        Assert.areEqual(
            'afterUpdate',
            lastMethodCalled,
            'last method should be afterUpdate'
        );
    }

    @IsTest
    private static void testAfterDelete() {
        afterDeleteMode();
        handler.run();
        Assert.areEqual(
            'afterDelete',
            lastMethodCalled,
            'last method should be afterDelete'
        );
    }

    @IsTest
    private static void testAfterUndelete() {
        afterUndeleteMode();
        handler.run();
        Assert.areEqual(
            'afterUndelete',
            lastMethodCalled,
            'last method should be afterUndelete'
        );
    }

    @IsTest
    private static void testNonTriggerContext() {
        try {
            handler.run();
            Assert.fail('the handler ran but should have thrown');
        } catch (TriggerHandler.TriggerHandlerException te) {
            Assert.areEqual(
                TRIGGER_CONTEXT_ERROR,
                te.getMessage(),
                'the exception message should match'
            );
        } catch (Exception e) {
            Assert.fail(
                'the exception thrown was not expected: ' +
                    e.getTypeName() +
                    ': ' +
                    e.getMessage()
            );
        }
    }

    // test bypass api

    @IsTest
    private static void testBypassAPI() {
        afterUpdateMode();

        // test a bypass and run handler
        TriggerHandler.bypass('TestHandler');
        handler.run();
        Assert.areEqual(
            null,
            lastMethodCalled,
            'last method should be null when bypassed'
        );
        Assert.isTrue(
            TriggerHandler.isBypassed('TestHandler'),
            'test handler should be bypassed'
        );
        resetTest();

        // clear that bypass and run handler
        TriggerHandler.clearBypass('TestHandler');
        handler.run();
        Assert.areEqual(
            'afterUpdate',
            lastMethodCalled,
            'last method called should be afterUpdate'
        );
        Assert.isFalse(
            TriggerHandler.isBypassed('TestHandler'),
            'test handler should be bypassed'
        );
        resetTest();

        // test a re-bypass and run handler
        TriggerHandler.bypass('TestHandler');
        handler.run();
        Assert.areEqual(
            null,
            lastMethodCalled,
            'last method should be null when bypassed'
        );
        Assert.isTrue(
            TriggerHandler.isBypassed('TestHandler'),
            'test handler should be bypassed'
        );
        resetTest();

        // clear all bypasses and run handler
        TriggerHandler.clearAllBypasses();
        handler.run();
        Assert.areEqual(
            'afterUpdate',
            lastMethodCalled,
            'last method called should be afterUpdate'
        );
        Assert.isFalse(
            TriggerHandler.isBypassed('TestHandler'),
            'test handler should be bypassed'
        );
        resetTest();
    }

    // instance method tests

    @IsTest
    private static void testLoopCount() {
        beforeInsertMode();

        // set the max loops to 2
        handler.setMaxLoopCount(2);

        // run the handler twice
        handler.run();
        handler.run();

        // clear the tests
        resetTest();

        try {
            // try running it. This should exceed the limit.
            handler.run();
            Assert.fail(
                'the handler should throw on the 3rd run when maxloopcount is 3'
            );
        } catch (TriggerHandler.TriggerHandlerException te) {
            // we're expecting to get here
            Assert.areEqual(
                null,
                lastMethodCalled,
                'last method should be null'
            );
        } catch (Exception e) {
            Assert.fail(
                'the exception thrown was not expected: ' +
                    e.getTypeName() +
                    ': ' +
                    e.getMessage()
            );
        }

        // clear the tests
        resetTest();

        // now clear the loop count
        handler.clearMaxLoopCount();

        try {
            // re-run the handler. We shouldn't throw now.
            handler.run();
            Assert.areEqual(
                'beforeInsert',
                lastMethodCalled,
                'last method should be beforeInsert'
            );
        } catch (TriggerHandler.TriggerHandlerException te) {
            Assert.fail(
                'running the handler after clearing the loop count should not throw'
            );
        } catch (Exception e) {
            Assert.fail(
                'the exception thrown was not expected: ' +
                    e.getTypeName() +
                    ': ' +
                    e.getMessage()
            );
        }
    }

    @IsTest
    private static void testLoopCountClass() {
        TriggerHandler.LoopCount lc = new TriggerHandler.LoopCount();
        Assert.areEqual(5, lc.getMax(), 'max should be five on init');
        Assert.areEqual(0, lc.getCount(), 'count should be zero on init');

        lc.increment();
        Assert.areEqual(1, lc.getCount(), 'count should be 1');
        Assert.isFalse(lc.exceeded(), 'should not be exceeded with count of 1');

        lc.increment();
        lc.increment();
        lc.increment();
        lc.increment();
        Assert.areEqual(5, lc.getCount(), 'count should be 5');
        Assert.isFalse(lc.exceeded(), 'should not be exceeded with count of 5');

        lc.increment();
        Assert.areEqual(6, lc.getCount(), 'count should be 6');
        Assert.isTrue(lc.exceeded(), 'should not be exceeded with count of 6');
    }

    // private method tests

    @IsTest
    private static void testGetHandlerName() {
        Assert.areEqual(
            'TestHandler',
            handler.getHandlerName(),
            'handler name should match class name'
        );
    }

    // test virtual methods

    @IsTest
    private static void testVirtualMethods() {
        TriggerHandler h = new TriggerHandler();
        h.beforeInsert();
        h.beforeUpdate();
        h.beforeDelete();
        h.afterInsert();
        h.afterUpdate();
        h.afterDelete();
        h.afterUndelete();
    }

    /***************************************
     * testing utilities
     ***************************************/

    private static void resetTest() {
        lastMethodCalled = null;
    }

    // modes for testing

    private static void beforeInsertMode() {
        handler.setTriggerContext('before insert', true);
    }

    private static void beforeUpdateMode() {
        handler.setTriggerContext('before update', true);
    }

    private static void beforeDeleteMode() {
        handler.setTriggerContext('before delete', true);
    }

    private static void afterInsertMode() {
        handler.setTriggerContext('after insert', true);
    }

    private static void afterUpdateMode() {
        handler.setTriggerContext('after update', true);
    }

    private static void afterDeleteMode() {
        handler.setTriggerContext('after delete', true);
    }

    private static void afterUndeleteMode() {
        handler.setTriggerContext('after undelete', true);
    }

    // test implementation of the TriggerHandler

    private class TestHandler extends TriggerHandler {
        public override void beforeInsert() {
            TriggerHandler_Test.lastMethodCalled = 'beforeInsert';
        }

        public override void beforeUpdate() {
            TriggerHandler_Test.lastMethodCalled = 'beforeUpdate';
        }

        public override void beforeDelete() {
            TriggerHandler_Test.lastMethodCalled = 'beforeDelete';
        }

        public override void afterInsert() {
            TriggerHandler_Test.lastMethodCalled = 'afterInsert';
        }

        public override void afterUpdate() {
            TriggerHandler_Test.lastMethodCalled = 'afterUpdate';
        }

        public override void afterDelete() {
            TriggerHandler_Test.lastMethodCalled = 'afterDelete';
        }

        public override void afterUndelete() {
            TriggerHandler_Test.lastMethodCalled = 'afterUndelete';
        }
    }
}
