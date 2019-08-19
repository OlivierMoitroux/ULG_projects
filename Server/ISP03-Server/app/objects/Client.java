package  objects;

import java.util.List;

public class Client {
	public int id;
	public String name;
	public String surname;
	public String email;
	public String password;
	public String work;
	public String username;

	public String homeAddress;
	public String homeZip;
	public String homeCountry;
	public String workAddress;
	public String workZip;
	public String workCountry;

	
	public Client() {}

	public Client(String _username, String _password){
		this.username = _username;
		this.password = _password;
	}
	
	public Client(int _id, String _username, String _name, String _surname, String _homeAddress, String _workAddress, String _email, String _password, String _work,
	String _homeCountry, String _workCountry, String _homeZip, String _workZip) {
		this.id = _id;
		this.name = _name;
		this.surname = _surname;
		this.username = _username;
		this.homeAddress = _homeAddress;
		this.workAddress = _workAddress;
		this.work = _work;
		this.email = _email;
		this.password = _password;
		this.homeCountry = _homeCountry;
		this.homeZip = _homeZip;
		this.workCountry = _workCountry;
		this.workZip =_workZip;
	}
	
	public void setName(String _name) {
		this.name = _name;
	}
	
	public String getName() {
		return this.name;
	}
	
	public void setSurname(String _surname) {
		this.surname = _surname;
	}
	
	public String getSurname() {
		return this.surname;
	}

	public void setUserName(String _username) {
		this.username = _username;
	}

	public String getUserName() {
		return this.username;
	}

	public void setHomeAddress(String _homeAddress) {
		this.homeAddress = _homeAddress;
	}

	public String getHomeAddress() {
		return this.homeAddress;
	}

	public void setHomeZip(String _homeZip){ this.homeZip = _homeZip;};

	public String getHomeZip(){ return this.homeZip;};

	public void setHomeCountry(String _homeCountry){ this.homeCountry = _homeCountry;};

	public String getHomeCountry(){ return this.homeCountry;};

	public void setWorkAddress(String _workAddress) {
		this.workAddress = _workAddress;
	}

	public String getWorkAddress() {
		return this.workAddress;
	}

	public void setWorkZip(String _workZip){ this.workZip = _workZip;};

	public String getWorkZip(){ return this.workZip;};

	public void setWorkCountry(String _workCountry){ this.workCountry = _workCountry;};

	public String getWorkCountry(){ return this.workCountry;};
	
	public void setEmail(String _email) {
		this.email = _email;
	}
	
	public String getEmail() {
		return this.email;
	}
	
	public void setId(int _id) {
		this.id = _id;
	}
	
	public int getId() {
		return this.id;
	}

	public void setPassW(String _password) {
		this.password = _password;
	}
	
	public String getPassW() { return this.password;}

	public void setWork(String _work) { this.work = _work; }

	public String getWork() { return  this.work; }
}
