/*
-------------------------------------------------------

Sentinel Evidence System (SES)

Module:
Experimental Feature

Purpose:
Emergency evidence collection architecture

Current Phase:
Architecture Preparation

Status:
TEST MODE

Safe Removal:
Delete sentinel_evidence folder and
remove integration points.

-------------------------------------------------------
*/

/// Test-mode logger. Prints only the `[SENTINEL]` prefix for now.
library;

class SentinelLogger {
  const SentinelLogger();

  void log(String message) {
    // ignore: avoid_print
    print('[SENTINEL] $message');
  }

  void info(String message) => log(message);

  void warn(String message) => log('WARN: $message');

  void error(String message) => log('ERROR: $message');
}
