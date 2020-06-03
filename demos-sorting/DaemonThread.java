
class DaemonThread extends Thread {
  public DaemonThread() {
    super();
    setDaemon(true);
  }
}
