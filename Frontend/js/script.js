
async function visitorCounter() {
    let n = await fetch('https://o88fs9koy5.execute-api.us-east-1.amazonaws.com/prod/WebsiteVisits');
    let count = await n.text();
    document.getElementById('CounterVisitor').innerHTML = "You Are Visitor Number: " + count.slice(1, -1) + "!";
}
