async function visitorCounter() {
    const counter = document.querySelector('#CounterVisitor');
    counter.innerText = "initializing visitor counter..."
    if(!localStorage.getItem("Visitor Number")) { // checks to see if visitor has already been assigned a number
        const url = 'https://o88fs9koy5.execute-api.us-east-1.amazonaws.com/prod/WebsiteVisits';
        const data = await fetch(url);
        const count = await data.text();
        localStorage.setItem("Visitor Number", count.slice(1, -1)) // adds their number to localStorage
    } 
    counter.innerText = `You Are Visitor Number ${localStorage.getItem("Visitor Number")}!` 
}
