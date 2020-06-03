import java.util.*;

class Sorter {
  
  Semaphore newWorkSemaphore = new Semaphore(0);
  Semaphore threadDoneSemaphore = new Semaphore(0);
  
  List workQueue = new LinkedList();
  List threads = new ArrayList();
  int workingThreadCount = 0;
  
  static class WorkUnit {
    Object[] arr;
    int l, r;
    public WorkUnit(Object[] arr, int l, int r) {
      this.arr = arr;
      this.l = l;
      this.r = r;
    }
  }

  class WorkerThread extends DaemonThread {
    int id;
    public WorkerThread(int id) {
      this.id = id;
    }
    public void run() {
      try
      {
        while(true) {
          newWorkSemaphore.getLock();
          workingThreadCount++;
          processWork(dequeue());
          workingThreadCount--;
          threadDoneSemaphore.signal();
        }
      }
      catch(InterruptedException ex) { throw new UnexpectedException(ex); }
    }

    public void processWork(WorkUnit work) {
      if ((work.r-work.l)>1)
      {
        //System.out.println("process " + id + " : " + work.l + " " + work.r);
        int[] ij = shallowQuickSort(work.arr, work.l, work.r);
        enqueue(new WorkUnit(work.arr, ij[1]+1, work.r));
        processWork(new WorkUnit(work.arr, work.l, ij[0]));
      }
    }
  }

  public Sorter(int threadCount) {
    //assert(threadCount > 0);
    for(int i=0; i<threadCount; i++)
      threads.add(new WorkerThread(i));
    for(int i=0; i<threadCount; i++)
    {
      ((Thread)threads.get(i)).start();
    }
  }

  private synchronized void enqueue(WorkUnit work) {
    workQueue.add(0, work);
    //System.out.println("thread count: " + workingThreadCount + "  queue size: " + workQueue.size());
    newWorkSemaphore.signal();
  }

  private synchronized WorkUnit dequeue() {
    //System.out.println("thread count: " + workingThreadCount + "  queue size: " + workQueue.size());
    return (WorkUnit)workQueue.remove(0);
  }

  public void parallelQuickSort(Object[] arr) {
    parallelQuickSort(arr, 0, arr.length-1);
  }

  public void parallelQuickSort(Object[] arr, int l, int r) {
    try
    {
      enqueue(new WorkUnit(arr, l, r));
      while(workingThreadCount > 0 || workQueue.size() > 0)
        threadDoneSemaphore.getLock();
    } catch(InterruptedException ex) { throw new UnexpectedException(ex); }
  }

  private static int[] shallowQuickSort(Object[] arr, int l, int r) {
    int i;
    int j;
    Object v;

    i = (r+l)/2;
    
    if (isGreaterThan(arr[l], arr[i])) swap(arr, l, i);     // Tri-Median Methode!
    if (isGreaterThan(arr[l], arr[r])) swap(arr, l, r);
    if (isGreaterThan(arr[i], arr[r])) swap(arr, i, r);
    
    j = r-1;
    swap(arr, i, j);
    i = l;
    v = arr[j];
    for(;;) {
      while(isLessThan(arr[++i], v));
      while(isGreaterThan(arr[--j], v));
      if (j<i) break;
      swap(arr, i, j);
    }
    swap(arr, i, r-1);
    return new int[] { i, j };
  } 
  public static void quickSort(Object[] arr) {
    quickSort(arr, 0, arr.length-1);
  }

  public static void quickSort(Object[] arr, int l, int r) {
    if ((r-l)>1)
    {
      int[] ij = shallowQuickSort(arr, l, r);
      quickSort(arr, l, ij[0]);
      quickSort(arr, ij[1]+1, r);
    }
  }

  protected static boolean isGreaterThan(Object a, Object b) {
    return ((Integer)a).intValue() > ((Integer)b).intValue();
  }

  protected static boolean isLessThan(Object a, Object b) {
    return ((Integer)a).intValue() < ((Integer)b).intValue();
  }

  protected static void swap(Object[] arr, int index1, int index2) {
    Object temp = arr[index1];
    arr[index1] = arr[index2];
    arr[index2] = temp;
  }

  public static void main(String[] args) {
    
    int[] ints = new int[] 
      {
        6964, 2663, 5656, 9661, 2201, 2642, 8632, 1463, 7754, 6458, 8065, 140, 2709, 4296, 4813, 2286,
        8449, 9235, 8216, 8492, 3379, 3524, 9289, 4513, 8589, 8537, 8887, 1913, 4934, 9896, 4768, 1899,
        2559, 6776, 1560, 1113, 9418, 6545, 8928, 3525, 3003, 6993, 3665, 2064, 1289, 4831, 4350, 9738,
        4066, 2566, 4583, 7446, 2442, 3872, 8311, 7384, 2409, 3550, 9297, 3696, 3446, 4065, 5595, 6005,
        7193, 3507, 3470, 2964, 6404, 2398, 6489, 9407, 9392, 6506, 1471, 7033, 1337, 2174, 3124, 5404,
        1092, 7707, 9202, 3535, 7931, 3865, 7271, 6692, 7415, 6568, 388, 861, 6986, 2335, 3218, 4179,
        2195, 6689, 7143, 8599, 9087, 9984, 4359, 4831, 6491, 2182, 8217, 4180, 4356, 7693, 9584, 1801,
        1752, 5138, 1688, 9683, 9003, 8959, 2727, 2770, 1879, 9468, 3631, 8865, 1803, 6850, 3045, 350,
        9891, 6540, 8950, 5330, 6525, 3309, 6514, 3016, 1843, 1083, 7196, 6200, 8776, 3133, 8001, 528,
        4623, 6041, 6563, 9979, 5000, 9290, 2749, 6879, 8758, 6381, 5745, 6914, 9583, 5142, 3616, 5826,
        1682, 2566, 1156, 4559, 2227, 4022, 7575, 4071, 5105, 1124, 6623, 3881, 609, 976, 761, 1584,
        7017, 7324, 1563, 8369, 2967, 4313, 5248, 8077, 7046, 7345, 1343, 2981, 8839, 4960, 8807, 6874,
        3878, 6315, 1433, 2458, 338, 5361, 6529, 1795, 2837, 9504, 2029, 3446, 6832, 2790, 5030, 3849,
        6467, 2946, 2218, 9434, 7259, 3818, 7511, 657, 7516, 8855, 3638, 6355, 3815, 2445, 9581, 7693,
        5112, 1015, 6503, 1802, 2728, 3032, 3598, 5565, 8888, 1979, 5363, 5720, 1121, 6745, 5921, 7588,
        9691, 4491, 7022, 3302, 8310, 886, 3959, 2178, 9741, 3949, 8533, 9908, 6394, 8115, 3953, 7859,
        5482, 457, 9661, 8210, 9841, 3259, 127, 8730, 1590, 5490, 802, 2712, 2235, 6724, 300, 8279,
        1215, 3675, 7933, 5877, 4561, 1893, 8055, 654, 5842, 2941, 562, 8589, 7408, 4515, 6448, 2890,
        1324, 2461, 7452, 1166, 2073, 7579, 6248, 3663, 9421, 3402, 6375, 8008, 126, 3028, 6287, 7694,
        6703, 4221, 9923, 7616, 2466, 7979, 8270, 4660, 7272, 5184, 9601, 4680, 6051, 2401, 3922, 7376,
        4863, 7726, 4894, 6936, 1657, 7494, 599, 1078, 896, 6975, 9086, 1023, 6355, 1726, 5069, 3058,
        2299, 4992, 7026, 1117, 9323, 1648, 5777, 6595, 6832, 5379, 7627, 2883, 7780, 7901, 6611, 2643,
        1979, 1505, 5931, 3636, 8999, 6531, 4714, 9896, 9858, 153, 7271, 6213, 8231, 8692, 5623, 530,
        3684, 2649, 1647, 9360, 4297, 3776, 5955, 7481, 5507, 9935, 364, 3288, 4188, 3328, 2283, 6168,
        4833, 8215, 9804, 185, 1098, 871, 6433, 956, 7376, 56, 3521, 5607, 8748, 5496, 2489, 8784,
        4497, 488, 8144, 5146, 4264, 452, 2627, 9772, 387, 9343, 9412, 927, 2671, 8047, 7095, 3857,
        2614, 3252, 394, 64, 475, 3179, 7372, 4203, 3235, 893, 9810, 8335, 2741, 8651, 7119, 7238,
        9139, 5264, 2384, 9755, 5716, 1363, 5879, 2455, 707, 5291, 9734, 9730, 9691, 3182, 3587, 2305,
        6434, 333, 2370, 3261, 3512, 6094, 7464, 3099, 6988, 3626, 1434, 9729, 8629, 8554, 3320, 7768,
        3818, 5704, 7523, 5886, 7068, 3403, 4693, 4127, 5046, 4427, 3857, 4737, 7609, 3797, 3395, 395,
        4130, 2117, 3656, 3995, 8211, 7472, 7094, 1551, 7450, 8529, 7633, 6079, 7083, 953, 199, 7253,
        3009, 7723, 9491, 6429, 7478, 4184, 556, 8876, 8611, 4414, 9966, 2573, 4563, 9713, 2968, 8693,
        8182, 2977, 9040, 2745, 6801, 6135, 4297, 4252, 1016, 8282, 331, 4451, 5587, 531, 1704, 8596,
        4606, 7547, 1378, 8436, 1731, 1934, 3664, 6694, 2700, 3630, 9267, 7263, 3343, 2236, 2309, 7877,
        5213, 1349, 623, 2014, 3836, 1272, 2618, 4852, 9554, 9302, 9303, 1493, 9833, 7359, 6441, 791,
        4906, 7819, 5579, 6637, 9754, 9243, 3332, 8806, 2874, 8951, 6070, 2569, 1187, 8379, 447, 2752,
        6080, 7422, 1119, 9917, 8694, 3737, 4769, 4600, 9391, 425, 6093, 5576, 4136, 2534, 6367, 9043,
        6706, 1946, 2032, 6460, 7542, 1716, 1618, 6768, 668, 7688, 9337, 8207, 2419, 6136, 960, 8500,
        3558, 8431, 8417, 8604, 8520, 9538, 3204, 7912, 9963, 9297, 3488, 452, 8184, 6208, 9495, 4890,
        4506, 1527, 7702, 2048, 9596, 9320, 8816, 264, 7009, 4506, 8471, 9428, 6994, 5783, 7928, 553,
        566, 2697, 5509, 9087, 8588, 8714, 6999, 4903, 8011, 6839, 5355, 6195, 3047, 4850, 7437, 7554,
        2730, 5139, 5954, 2326, 4460, 1123, 8942, 1469, 5629, 3765, 7249, 2623, 9549, 1530, 9528, 6467,
        4227, 5038, 5554, 2815, 3752, 8905, 7719, 8115, 2097, 3074, 663, 5144, 4277, 8100, 9050, 7007,
        3240, 1357, 5685, 4052, 2480, 979, 5521, 8109, 4744, 9122, 7084, 645, 652, 6613, 7113, 1232,
        8003, 2667, 399, 8107, 7925, 4470, 6222, 22, 3897, 3237, 1518, 4526, 1338, 569, 1533, 930,
        8278, 3570, 4982, 758, 4549, 6855, 5219, 9293, 5977, 2303, 6291, 2982, 5268, 3404, 566, 3271,
        2423, 7317, 7730, 348, 1788, 3953, 370, 2037, 7190, 8241, 6563, 4880, 5162, 4448, 2162, 3440,
        8018, 7144, 4198, 8919, 351, 9417, 4564, 6329, 8072, 855, 5663, 3341, 4259, 2581, 2964, 3035,
        9898, 695, 3383, 1686, 1000, 106, 75, 4542, 8347, 6638, 5775, 3509, 1086, 7937, 3301, 5456,
        5082, 7499, 4375, 1785, 3268, 5292, 8114, 1340, 6147, 129, 1033, 6759, 2710, 350, 9794, 2609,
        1045, 9529, 647, 8397, 5987, 723, 2939, 686, 3713, 8714, 547, 1152, 3004, 3848, 6608, 8086,
        7699, 7336, 9871, 7319, 2628, 4338, 8660, 5127, 819, 6045, 1886, 9882, 6395, 8032, 8843, 3792,
        3914, 9490, 2189, 9901, 6565, 1481, 6940, 6631, 195, 7487, 7783, 3199, 7688, 743, 7637, 5387,
        8079, 3861, 9059, 7059, 4551, 7719, 2187, 1722, 116, 4073, 1604, 2864, 8458, 447, 6656, 2372,
        6290, 8846, 8625, 9207, 327, 5565, 5838, 6874, 9405, 9973, 6426, 3445, 717, 415, 5184, 8796,
        4276, 4243, 5856, 5179, 8314, 8043, 6902, 8431, 8468, 4858, 1295, 3278, 5306, 4303, 5650, 7948,
        3149, 628, 7155, 9828, 6193, 9346, 3055, 1950, 9319, 5833, 5395, 36, 6248, 580, 5185, 6877,
        4823, 1041, 2056, 3138, 5436, 5310, 7921, 256, 169, 5568, 3535, 1827, 9871, 5537, 6127, 9373,
        6165, 9634, 5553, 8711, 8980, 8608, 661, 4652, 4441, 2409, 1040, 7042, 2989, 6225, 3919, 4164,
        3618, 2327, 3654, 5406, 7638, 7927, 5663, 4159, 3495, 5550, 2338, 3367, 1087, 8465, 2740, 7253,
        8099, 8293, 2316, 3432, 3254, 2977, 4436, 4047, 5386, 5476, 1089, 4727, 8054, 5008, 5244, 1672,
        7336, 5250, 3431, 1326, 3178, 5446, 5485, 6673, 996, 4175, 40, 8435, 2640, 9132, 2040, 7091,
        7426, 4356, 523, 7032, 3686, 1311, 1079, 5424
      };

    int threadCount = Integer.parseInt(args[0]);
    int intCount = Integer.parseInt(args[1]);
    Object[] bigInts = new Object[intCount];
    for(int i=0; i<bigInts.length; i++)
      bigInts[i] = new Integer(ints[i % ints.length]);
    
    (new Sorter(threadCount)).parallelQuickSort(bigInts);
    
    //System.out.println("--> " + bigInts[0]);
    for(int i=1; i<bigInts.length; i++)
    {
//      assert ((Integer)bigInts[i-1]).intValue() <= ((Integer)bigInts[i]).intValue() :
//        "" + ((Integer)bigInts[i-1]).intValue() + " " + ((Integer)bigInts[i]).intValue();
      //System.out.println("--> " + bigInts[i]);
    }
  }
}
