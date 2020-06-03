
class Foobar {

  static int xField = 78;
  
  static public void foo(int kCnt) {
    int cnt=0;
    long start = System.currentTimeMillis();
    for(int i=0; i<kCnt*500000; i++)
      cnt++;
    System.out.println("foo cnt " + cnt + " " + (System.currentTimeMillis() - start));
  }

  static public void spin(int kCnt) {
    int cnt=0;
    long start = System.currentTimeMillis();
    for(int i=0; i<kCnt*1000000; i++)
      cnt++;
    System.out.println("spin cnt " + cnt + " " + (System.currentTimeMillis() - start));
  } 

  static public void main(String[] args) {
    long t = System.currentTimeMillis();
    for(int i=0; i<Integer.parseInt(args[0]); i++)
    {
      foo(i);
      spin(i);
    }
    System.out.println("" + ((System.currentTimeMillis() - t) / 1000.0) + " secs");
  }
}
