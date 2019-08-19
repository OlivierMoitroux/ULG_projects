package be.ac.ulg.montefiore.oop; //.exception ?

public class MSException extends Exception {
	
	private static final long serialVersionUID = 1L;

	public MSException(){
		super();
    }
    public MSException(String s) 
    {
    	super(s);
    }
}