async function visitorCounter() {
    const url = 'https://o88fs9koy5.execute-api.us-east-1.amazonaws.com/prod/WebsiteVisits';
    const counter = document.querySelector('#CounterVisitor');
    counter.innerText = "initializing visitor counter..."
    
    const n = await fetch(url);
    const count = await n.text();
    counter.innerText = `You Are Visitor Number ${count.slice(1, -1)}!`;
}
