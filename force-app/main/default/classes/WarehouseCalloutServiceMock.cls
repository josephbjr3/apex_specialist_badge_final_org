/**
 * * This mock callout class is used in testing the WarehouseCalloutService test. It is used in the WarehouseCalloutServiceTest class.
 */
@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock {
  //TODO create method takes in a request and returns a respone
  global static HttpResponse respond(HttpRequest req) {
    //TODO check the req
    system.assertEquals(
      'https://th-superbadge-apex.herokuapp.com/equipment',
      req.getEndpoint()
    );
    system.assertEquals('GET', req.getMethod());

    //TODO create fake response
    HttpResponse fakeRes = new HttpResponse();
    fakeRes.setHeader('Content-Type', 'application/json');
    fakeRes.setBody(
      '[{"_id": "55d66226726b611100aaf741", "replacement": false, "quantity": 5, "name": "Generator 1000 kW", "maintenanceperiod": 365, "lifespan": 120, "cost": 5000, "sku": "100003"}]'
    );
    fakeRes.setStatusCode(200);

    //TODO return fake resonse
    return fakeRes;
  }
}
