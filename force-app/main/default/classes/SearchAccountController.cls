public class SearchAccountController {

    @AuraEnabled
    public static List < account > fetchAccount(String searchKeyWord) {

        String searchKey = '%' + searchKeyWord + '%';
        List < Account > returnList = new List < Account > ();
        List < Account > lstOfAccount = [SELECT Name, AnnualRevenue, NumberOfEmployees, Priority__c, (Select FirstName, LastName, Email FROM Contacts) 
                                        FROM account WHERE Name LIKE: searchKey];

        for (Account acc: lstOfAccount) {
            returnList.add(acc);
        }

        return returnList;
    }
    
}
