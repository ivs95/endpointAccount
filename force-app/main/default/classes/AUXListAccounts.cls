public  class AUXListAccounts {
	
    public List<AUXAccount> accounts;

	public static AUXListAccounts parse(String json) {
		return (AUXListAccounts) System.JSON.deserialize(json, AUXListAccounts.class);
	}
}
