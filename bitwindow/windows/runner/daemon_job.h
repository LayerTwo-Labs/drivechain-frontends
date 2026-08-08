#ifndef RUNNER_DAEMON_JOB_H_
#define RUNNER_DAEMON_JOB_H_

#include <windows.h>

#include <string>

// Name of this process's daemon job: "bitwindow-daemons-<pid>". Named so a test
// can open the exact job — an unnamed job can't be told apart from the job a CI
// runner already put every process in.
std::wstring DaemonJobName();

// Creates the job object that owns the daemon tree. Call once at startup.
void CreateDaemonJob();

// Puts a spawned daemon (and everything it spawns) in the job, so it dies with
// this process. Returns false when the pid could not be joined.
bool AssignPidToDaemonJob(DWORD pid);

#endif  // RUNNER_DAEMON_JOB_H_
