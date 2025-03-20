@isTest
global class MockExchangeRateResponse implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        // ✅ Mock exchange rate response
        String mockJson = '{ "base": "USD", "rates": { "TRY": 38.04, "EUR": 0.91, "USD": 1 } }';
        res.setBody(mockJson);

        return res;
    }
}
