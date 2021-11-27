({

    findAccount: function (component, event, helper) {
        var action = component.get('c.fetchAccount');
        action.setParams({
            searchKeyWord: component.get("v.keywordHolder")

        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            var response1 = response.getReturnValue();

            if (state === "SUCCESS") {

                var pageSize = component.get("v.pageSize");
                component.set("v.accountList", response1);
                component.set("v.totalSize", response1.length);
                component.set("v.start", 0);
                
                if (response1.length >= pageSize)
                	component.set("v.end", pageSize);
                else
                    component.set("v.end", response1.length);

                var paginationList = [];

                for (var i = 0; i < component.get("v.end"); i++) {
                    	paginationList.push(response1[i]);                	
                }

                component.set("v.paginationList", paginationList);
                if (response1.length > 0) {
                    component.set("v.existRecords", true);
                }
                else {
                    component.set("v.existRecords", false);

                }
            }

        });


        $A.enqueueAction(action);
    },
    
    
    updatePagination: function (component, event, helper) {

        var selected = component.get('v.pageSize');
        var paginationList = [];
        var accList = component.get("v.accountList");
		
        component.set("v.start", 0);
        
        if (selected >= accList.length)
            component.set("v.end", accList.length)
        
        else
            component.set("v.end", selected);


        for (var i = 0; i < component.get("v.end"); i++) {
            	paginationList.push(accList[i]);
        }

        component.set('v.paginationList', paginationList);

    },

    
 

    next: function (component, event, helper) {

        var accList = component.get("v.accountList");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];

        
        start = Number(start) + Number(pageSize);
        end = Number(end) + Number(pageSize);
       
        if (end > accList.length - 1){
            end = accList.length;
        }
      
        for (var i = start; i < end; i++) {

            paginationList.push(accList[i]);

        }
        
        component.set("v.start", start);
        component.set("v.end", end);
        component.set('v.paginationList', paginationList);

    },

    previous: function (component, event, helper) {

        var accList = component.get("v.accountList");

        var end = component.get("v.end");

        var start = component.get("v.start");

        var pageSize = component.get("v.pageSize");

        var paginationList = [];

        
        start = Number(start) - Number(pageSize);
        end = Number(end) - Number(pageSize);
        
        if (end  < pageSize){
            end = pageSize;
        }
       
        

        for (var i = start ; i < end; i++) {
                paginationList.push(accList[i]);
        }

        component.set("v.start", start);
        component.set("v.end", end);
        console.log('Start : ' + start +  '  End: ' + end);
        component.set('v.paginationList', paginationList);

    }


})