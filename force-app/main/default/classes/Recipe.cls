public with sharing class Recipe {

    //class variables defined here
    
    public Decimal activeMinutes;
    public Double activeTime;
    public String activeTimeUnits;
    public String description;
    public String name;
    public String season;
    public Double servingCount;
    public String sObjectID;
    public String source;
    public List < Ingredient__c > ingredientList;

    //First Constructor, allows you to instantiate a new Recipe with no pre-set values
    public Recipe() {
    }

    // Second Constructor, allows you to instantiate a new Recipe with some pre-set values
    // Active Time Unit options are : Minutes, Hours
    public Recipe(Integer activeTime, String activeTimeUnits, String name, Integer servingCount) {
        this.activeTime = activeTime;
        this.activeTimeUnits = activeTimeUnits;
        this.name = name;
        this.servingCount = servingCount;
    
    }

    //Third Constructor, allows you to instantiate a new Recipe based on an existing Recipe__c SObject ID
    public Recipe(String sObjectId) {

        Recipe__c recipeSObject = [SELECT ID, Active_Time__c,Active_Time_Units__c, Description__c, Duration__c, Name__c, Season__c, Servings__c,Source__c FROM Recipe__c WHERE ID=:sObjectId];
        // Assign the values
        this.sObjectID = recipeSObject.ID;
        this.activeTime = recipeSObject.Active_Time__c;
        this.activeTimeUnits = recipeSObject.Active_Time_Units__c;
        this.description = recipeSObject.Description__c;
        this.name = recipeSObject.Name__c;
        this.season = recipeSObject.Season__c;
        this.servingCount = recipeSObject.Servings__c;
        this.source = recipeSObject.Source__c;

        //Calculate the active minutes (if there is an active time value and a recognized unit)
        if (recipeSObject.Active_Time__c>0) {
            if (this.activeTimeUnits=='minutes') {
                this.activeMinutes = recipeSObject.Active_Time__c;
            } else if (this.activeTimeUnits=='hours') {
                this.activeMinutes = recipeSObject.Active_Time__c/60;
            } 
        }
        
    }


    //public methods
    public Boolean create() {

        //First, verify the StockItem does not already have an ID (it's not an existing record)
        if (String.isBlank(this.sObjectID)) {

            //verify that we have required fields
            if (this.allRequiredFieldsValid() && this.compliesWithAppropriateStyleRules()) {
                Recipe__c newRecipeSObject = new Recipe__c();
                newRecipeSObject.Active_Time__c = this.activeTime;
                newRecipeSObject.Active_Time_Units__c = this.activeTimeUnits;
                newRecipeSObject.Description__c = this.description;
                newRecipeSObject.Name__c = this.name;
                newRecipeSObject.Season__c = this.season;
                newRecipeSObject.Servings__c = this.servingCount;
                newRecipeSObject.Source__c = this.source;
                insert newRecipeSObject;
                //assign the ID to the in-memory Recipe
                this.sObjectID = newRecipeSObject.ID;
                                
                return true;

            } else {
                return false;
            }
            
        } else {
            return false;
        }

    }

    public Boolean updateValues() {
        //First, verify the Recipe has an SFID (it's and existing item that we can update)
        if (String.isNotBlank(this.sObjectID)) {

            //Validate all required fields
            if (this.allRequiredFieldsValid() && this.compliesWithAppropriateStyleRules()) {
                // the line below is an example of instantiating an SObject, and passing the ID into the constructor
                Recipe__c updateRecipe = new Recipe__c(ID=this.sObjectID);
                updateRecipe.Active_Time__c = this.activeTime;
                updateRecipe.Active_Time_Units__c = this.activeTimeUnits;
                updateRecipe.Description__c = this.description;
                updateRecipe.Name__c = this.name;
                updateRecipe.Season__c = this.season;
                updateRecipe.Servings__c = this.servingCount;
                updateRecipe.Source__c = this.source;

                update updateRecipe;
                return true;

            } else {
                return false;
            }
            
        } else {
            return false;
        }
    }

    public void addIngredient (Ingredient__c ing) {
        // Add this ingredient to the list of ingredients for this recipe
    }

    public void generateGroceryList() {
        //Based on the recipe and ingredients, generate a shopping list for all items
    }

    public void scaleRecipeForServings (Integer desiredServings) {
        // based on the desired servings, scale the recipe ingredients up or down.
    }


    //Private Methods
    private Boolean allRequiredFieldsValid () {
        if (String.isNotBlank(this.name) && String.isNotBlank(this.description) && this.activeTime!=NULL && String.isNotBlank(this.activeTimeUnits)) {
            return true;
        } else {
            return false;
        }
    }

    //Private Methods
    private Boolean compliesWithAppropriateStyleRules () {
        // based on the stage of recipe, there are special requirements
        // A print-ready recipe must be more complete than a draft
        
        //Not sure what the criteria is yet, so returning true for now
        return true;
    }

}