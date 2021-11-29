@RestResource(urlMapping='/Account/*')
global with sharing class AccountEndPoint {

    @HttpPut
    global static void doPost(String json){
        
        AUXListAccounts listAccounts = AUXListAccounts.parse(json);
        Set<String> uuids = createSetUuids(listAccounts.accounts);
        List<Account> oldAccounts = [SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE uuid__c IN :uuids];
        deleteOldContacts(oldAccounts);
        insertNewData(listAccounts);


    }
    
    private static Set<String> createSetUuids(List<AUXAccount> accounts){
        
        Set<String> uuids = new Set<String>();

        for (AUXAccount a : accounts){
            uuids.add(a.uuid);
        }

        return uuids;
    }

    private static void deleteOldContacts(List<Account> oldAccounts){
        
        List<Contact> oldContacts = new List<Contact>();
        
        for (Account a : oldAccounts){
            oldContacts.addAll(a.Contacts);
        }

        delete oldContacts;
    }

    private static void insertNewData(AUXListAccounts accs){
        
        User lowAgent = [SELECT Id from User WHERE Name =: AccountHelper.LOW_AGENT_NAME LIMIT 1];
        User medAgent = [SELECT Id from User WHERE Name =: AccountHelper.MED_AGENT_NAME LIMIT 1];
        User highAgent = [SELECT Id from User WHERE Name =: AccountHelper.HIGH_AGENT_NAME LIMIT 1];


        List<Account> accountsToUpsert = new List<Account>();
        List<Contact> contactsToInsert = new List<Contact>();

        for (AUXAccount a : accs.accounts){

            Account newAccount = new Account(uuid__c = a.uuid, Name = a.company_name, AnnualRevenue=a.annual_revenue, NumberOfEmployees=a.number_employees);
            List<Contact> newContacts = new List<Contact>();
            
            for (AUXContact c : a.contacts ){
                Contact newContact = new Contact(FirstName = c.first_name, LastName = c.last_name, Email = c.email, Account = newAccount);
                newContacts.add(newContact);
            }


            setPriorityAndAgent(newAccount, newContacts, lowAgent, medAgent, highAgent);

            accountsToUpsert.add(newAccount);
            contactsToInsert.addAll(newContacts);
            
        }
        
        upsert accountsToUpsert uuid__c;

        for (Contact c : contactsToInsert){
            c.AccountId = c.Account.Id;
        }
        insert contactsToInsert;
    }


    private static void setPriorityAndAgent(Account account, List<Contact> contacts, User low, User med, User high){
        if (account.AnnualRevenue <= AccountHelper.LOW_ANNUAL_MAXVALUE){
            account.Priority__c = AccountHelper.LOW_PRIORITY_VALUE;
            account.OwnerId = low.Id;
            for (Contact c : contacts){
                c.OwnerId = low.Id;
            }
        }
        else if (account.AnnualRevenue <= AccountHelper.MED_ANNUAL_MAXVALUE) {
            account.Priority__c = AccountHelper.MED_PRIORITY_VALUE;
            account.OwnerId = med.Id;
            for (Contact c : contacts){
                c.OwnerId = med.Id;

            }
        }
        else {
            account.Priority__c = AccountHelper.HIGH_PRIORITY_VALUE;
            account.OwnerId = high.Id;
            for (Contact c : contacts){
                c.OwnerId = high.Id;
            }
        }
    }

}