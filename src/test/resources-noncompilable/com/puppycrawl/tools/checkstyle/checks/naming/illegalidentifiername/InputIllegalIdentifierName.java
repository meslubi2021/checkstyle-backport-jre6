/*
IllegalIdentifierName
format = (default)(?i)^(?!(record|yield|var|permits|sealed|_)$).+$
tokens = (default)CLASS_DEF, INTERFACE_DEF, ENUM_DEF, ANNOTATION_DEF, ANNOTATION_FIELD_DEF, \
         PARAMETER_DEF, VARIABLE_DEF, METHOD_DEF, ENUM_CONSTANT_DEF, PATTERN_VARIABLE_DEF, \
         RECORD_DEF, RECORD_COMPONENT_DEF, LAMBDA


*/

//non-compiled with javac: Compilable with Java14
package com.puppycrawl.tools.checkstyle.checks.naming.illegalidentifiername;

import java.util.logging.LogRecord;

public class InputIllegalIdentifierName {
    public Class<Record[]> getRecordType() { // ok
        return Record[].class;
    }

    private static void record(LogRecord... logArray) { // violation, method def
        for (LogRecord record : logArray) { // violation, foreach variable
            record.getLevel();
        }
    }

    class yieldClass { // ok
        int yield = 6; // violation

        public void yield() { // violation

        }
    }

    enum Day {
        MON,
        TUE,
        WED,
        THU,
        FRI,
        SAT,
        SUN,
    }

    int yield(Day day) { // violation, method def
        return switch (day) {
            case MON, TUE -> Math.addExact(0, 1);
            case WED -> Math.addExact(1, 1);
            case THU, SAT, FRI, SUN -> 0;
            default -> {
                yield Math.addExact(2, 1); // ok, yield statement
            }
        };
    }

    public static void main(String... args) {
        var var = 4; // violation, "var" should not be used as an identifier.

        int record = 15; // violation, "record" should not be used as an identifier.

        String yield = "yield"; // violation, "yield" should not be used as an identifier.

        record Record // violation, "Record" should not be used as an identifier.
                (Record record) { // violation, "record" should not be used as an identifier.
        }

        String yieldString = "yieldString"; // ok, part of another word
        record MyRecord() {} // ok, part of another word
        var variable = 2; // ok, part of another word

        String recordString = "record"; // ok
        recordString = recordString.substring(record, 20); // ok

        record MyOtherRecord(String record, String yield, String... var) { // violation x3
        }
    }
}
