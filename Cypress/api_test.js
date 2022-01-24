describe('API Return Test', () => {
    it('Returns', () => {
        cy.request("https://o88fs9koy5.execute-api.us-east-1.amazonaws.com/prod/WebsiteVisits")
        .should((response) => {
            expect(response.status).to.eq(200)
        })
        .then((response) => {
            cy.log(JSON.stringify(response.body))
        })
})
})