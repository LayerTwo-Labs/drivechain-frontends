#include "daemon_job.h"

namespace {

// Held for the process lifetime and never closed: KILL_ON_JOB_CLOSE then fires
// exactly when we die, however we die, and reaps every daemon in the job.
HANDLE g_daemon_job = nullptr;

}  // namespace

std::wstring DaemonJobName() {
  return L"bitwindow-daemons-" + std::to_wstring(::GetCurrentProcessId());
}

void CreateDaemonJob() {
  if (g_daemon_job != nullptr) {
    return;
  }
  const std::wstring name = DaemonJobName();
  HANDLE job = ::CreateJobObjectW(nullptr, name.c_str());
  if (job == nullptr) {
    return;
  }
  JOBOBJECT_EXTENDED_LIMIT_INFORMATION info{};
  info.BasicLimitInformation.LimitFlags =
      JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE |
      JOB_OBJECT_LIMIT_DIE_ON_UNHANDLED_EXCEPTION;
  if (!::SetInformationJobObject(job, JobObjectExtendedLimitInformation, &info,
                                 sizeof(info))) {
    ::CloseHandle(job);
    return;
  }
  g_daemon_job = job;
}

bool AssignPidToDaemonJob(DWORD pid) {
  if (g_daemon_job == nullptr || pid == 0) {
    return false;
  }
  HANDLE process =
      ::OpenProcess(PROCESS_SET_QUOTA | PROCESS_TERMINATE, FALSE, pid);
  if (process == nullptr) {
    return false;
  }
  const BOOL assigned = ::AssignProcessToJobObject(g_daemon_job, process);
  ::CloseHandle(process);
  return assigned != FALSE;
}
