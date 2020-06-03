
public class Semaphore {
	int counter = 0;
	
	public Semaphore(int m) {
		counter = m;
	}
	
	public synchronized void signal() {
		counter++ ; 
		if (counter <= 0) notify() ;
	}
	
	//semaphore wait. "wait" is already used by the API.
	public synchronized void getLock() throws InterruptedException {
		counter-- ;
		if (counter < 0) wait(0);
	}
}
