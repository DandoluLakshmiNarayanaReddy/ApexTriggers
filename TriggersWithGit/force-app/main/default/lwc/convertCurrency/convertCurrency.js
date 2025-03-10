import { LightningElement } from 'lwc';

export default class ConvertCurrency extends LightningElement {
    ConvertedValue="";
    showOutput=false;
    toCurrency="";
    fromCurrency="";
    enteredAmount="";
    currencyOptions=[];
   
    connectedCallback(){
       this.fetchSymbols();
    }
    changeHandler(event){
      let {name,value}=event.target;
        if(name==="Amount") this.enteredAmount=value;
        if(name==="fromcurr") this.fromCurrency==value;
        if(name==="tocurr") this.toCurrency=value;
        //this.currencyOptions=event.detail.value;
    }
    async fetchSymbols()
    {
        let endpoint=`https://api.frankfurter.dev/v1/currencies`;
        try{
            let response=await fetch(endpoint);
            if(!response.ok)
            {
                throw new Error("Network Issues");
            }
            else
            {
                const data= await response.json();
                console.log("API Response:", data); // Debugging: 
                let options=[];
                for(let symbol in data)
                {
                    options=[...options,{label:symbol,value:symbol}];
                }
                this.currencyOptions=[...options];
            }
        }
        catch(error)
        {
           console.log(error);
        }
    }

    clickHandler(){

    }


}