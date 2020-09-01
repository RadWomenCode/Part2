// Author: Niki Vankerk
// Date: 10/2019

public with sharing class Ingredient {

    //class variables defined here
    public Double measurement;
    public String measurementType;
    public String description;
    public String name;
    public String notes;
    public String preparation;
    public String sObjectID;
    public String type;
    public Id recipeId;

    //First Constructor, allows you to instantiate a new Ingredient with no pre-set values
    public Ingredient() {
    }

    // Second Constructor, allows you to instantiate a new Ingredient with some pre-set values
    public Ingredient(Id recipeId, String name, Decimal measurement, String measurementType) {
        this.recipeId = recipeId;
        this.measurement = measurement;
        this.measurementType = measurementType;
        this.name = name;
    }

    //Third Constructor, allows you to instantiate a new Ingredient object based on an existing Ingredient__c SObject ID
    public Ingredient(String sObjectId) {

        Ingredient__c ingredientSObject = [SELECT ID, Name, Notes__c, Type__c, Preparation__c, measurement__c, measurement_type__c, description__c, Recipe__c 
            FROM Ingredient__c WHERE ID=:sObjectId];
        // Assign the values
        this.sObjectID = ingredientSObject.ID;
        this.Name = ingredientSObject.Name;
        this.notes = ingredientSObject.Notes__c;
        this.type = ingredientSObject.Type__c;
        this.preparation = ingredientSObject.Preparation__c;
        this.measurement = ingredientSObject.measurement__c;
        this.measurementType = ingredientSObject.measurement_type__c;
        this.description = ingredientSObject.description__c;
        this.recipeId = ingredientSObject.Recipe__c;

       
    }

    //public methods
    public Boolean create() {

        //First, verify the Ingredient does not already have an ID (it's not an existing record)
        if (String.isBlank(this.sObjectID)) {

            //verify that we have required fields
            if (this.allRequiredFieldsValid()) {
                Ingredient__c newIngredientSObject = new Ingredient__c();
                newIngredientSObject.Name = this.Name;
                newIngredientSObject.Notes__c = this.notes;
                newIngredientSObject.Type__c =  this.type;
                newIngredientSObject.Preparation__c =  this.preparation;
                newIngredientSObject.measurement__c = this.measurement;
                newIngredientSObject.measurement_type__c = this.measurementType;
                newIngredientSObject.description__c = this.description;
                newIngredientSObject.Recipe__c = this.recipeId;
                insert newIngredientSObject;
                 //assign the ID to the in-memory Ingredient
                this.sObjectID = newIngredientSObject.ID;

                // Call the asynchronout future method to load nutrition information from our external service
                Ingredient.getNutritionInformation(this.sObjectID, this.Name);
                return true;

            } else {
                return false;
            }
            
        } else {
            return false;
        }

    }

    public Boolean updateValues() {
        //First, verify the Ingredient has an SFID (it's and existing item that we can update)
        if (String.isNotBlank(this.sObjectID)) {

            //Validate all required fields
            if (this.allRequiredFieldsValid()) {
                // the line below is an example of instantiating an SObject, and passing the ID into the constructor
                Ingredient__c updateIngredient = new Ingredient__c(ID=this.sObjectID);
                updateIngredient.Name = this.Name;
                updateIngredient.Notes__c = this.notes;
                updateIngredient.Type__c =  this.type;
                updateIngredient.Preparation__c =  this.preparation;
                updateIngredient.measurement__c = this.measurement;
                updateIngredient.measurement_type__c = this.measurementType;
                updateIngredient.description__c = this.description;

                update updateIngredient;
                return true;

            } else {
                return false;
            }
            
        } else {
            return false;
        }
    }


    //Private Methods
    private Boolean allRequiredFieldsValid () {
        if (String.isNotBlank(this.name) && 
            String.isNotBlank(this.description) && 
            this.measurement!=NULL && 
            String.isNotBlank(this.measurementType)) {
            return true;
        } else {
            return false;
        }
    }
    
    /* Added in @Future sample callout - Melissa Hansen 10/2019

    Call out to an external service that will get us nutrition information
    The service is still being built so reults are currently mocked */
    @future (callout=true)
    public static void getNutritionInformation (String ingredientSobjectId, String ingredientName) {

        // Sample callout syntax
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://exampleNutritionINfo.com/example/test');
        req.setMethod('GET');
        req.setBody('{"ingredient_name":"'+ingredientName+'"}');
        System.debug('req: '+req);

        HttpResponse res = Ingredient.getNutritionInfo(req);
        System.debug('res.getStatus: '+res.getStatusCode());
        
        // IF we got a good response, get the nutrition data out and update our SObject
        if (res.getStatusCode()==200) {

            // convert the response body to a jsonObject
            String resBody = res.getBody();
            Map<String, Object> responseBodyJsonMap = (Map<String, Object>)JSON.deserializeUntyped(resBody);

            // Load the SObject with the id and update nutrition information
            Ingredient__c ingredientSobject = new Ingredient__c(ID=ingredientSobjectId);
            ingredientSobject.Calories__c = Integer.valueOf(responseBodyJsonMap.get('calories'));
            ingredientSobject.Protein_Grams__c = Double.valueOf(responseBodyJsonMap.get('protein_grams'));
            ingredientSobject.Fat_Grams__c = Double.valueOf(responseBodyJsonMap.get('fat_grams'));
            ingredientSobject.Carbohydrate_Grams__c = Double.valueOf(responseBodyJsonMap.get('carb_grams'));
            ingredientSobject.Nutrition_Base_Type__c = String.valueOf(responseBodyJsonMap.get('unit_type')); 
            ingredientSobject.Nutrition_Base_Unit__c = Double.valueOf(responseBodyJsonMap.get('unit_amount'));

            System.debug('Here are the values we are updating on this Ingredient: '+ingredientSobject);

            // Finally, upate the SObject
            update ingredientSobject;

        }
        
    }


    // Mock response for nutrition info.  Always returns the nutritional value of an apple=
    private static HttpResponse getNutritionInfo (HttpRequest incomingReq) {
        // This is a mocked response to test our architecture.  
        // Will later be replaced by callouts to a real service

        String reqBody = incomingReq.getBody();
        Map<String, Object> requestBodyJsonMap = (Map<String, Object>)JSON.deserializeUntyped(reqBody);
        String ingredientName = String.valueOf(requestBodyJsonMap.get('ingredient_name'));
        String sampleJsonResponse = '{ "name":"'+ingredientName+'","calories":"52","protein_grams":".3","carb_grams":"13.8","fat_grams":".2","unit_amount":"1","unit_type":"Whole"}';

        HttpResponse res = new HttpResponse();
        res.setBody(sampleJsonResponse);
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        return res;

    }


}
